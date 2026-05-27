library task_notification_bell;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';
import 'task_notification_service.dart';
import '../views/task_viewmodel.dart';

part 'task_notification_bell/task_notification_bell_parts.dart';

class TaskNotificationBellButton extends StatefulWidget {
  final String userId;
  final Color iconColor;
  final Color badgeColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final BoxConstraints constraints;

  const TaskNotificationBellButton({
    super.key,
    required this.userId,
    this.iconColor = AppColors.textSecondary,
    this.badgeColor = AppColors.high,
    this.iconSize = 24,
    this.padding = const EdgeInsets.all(10),
    this.constraints = const BoxConstraints.tightFor(width: 44, height: 44),
  });

  @override
  State<TaskNotificationBellButton> createState() =>
      _TaskNotificationBellButtonState();
}

class _TaskNotificationBellButtonState extends State<TaskNotificationBellButton> {
  static const String _dismissedEntryPrefsKey =
      'task_notification_bell_dismissed_entries';

  static const Duration _dueSoonWindow = Duration(minutes: 10);
  static const Duration _recentCompletionWindow = Duration(hours: 24);

  Set<String> _dismissedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDismissedKeys();
  }

  Future<void> _loadDismissedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_dismissedEntryPrefsKey) ?? <String>[];
    if (!mounted) return;
    setState(() => _dismissedKeys = keys.toSet());
  }

  String _entryKey(_NotificationEntry entry) {
    return '${entry.kind.name}:${entry.taskId}:${entry.timestamp.millisecondsSinceEpoch}';
  }

  List<_NotificationEntry> _applyDismissedFilter(
    List<_NotificationEntry> entries,
  ) {
    return entries.where((entry) => !_dismissedKeys.contains(_entryKey(entry))).toList();
  }

  Future<void> _clearAllFromBell(List<_NotificationEntry> entries) async {
    if (entries.isEmpty) return;

    final nextKeys = Set<String>.from(_dismissedKeys)
      ..addAll(entries.map(_entryKey));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedEntryPrefsKey, nextKeys.toList());
    await TaskNotificationService.instance.clearAllNotifications();

    if (!mounted) return;
    setState(() => _dismissedKeys = nextKeys);
  }

  bool _isCompleted(TaskViewModel task) => task.stat == 'Hoàn thành';

  bool _isOverdue(TaskViewModel task, DateTime now) {
    if (_isCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return false;
    return dueAt.isBefore(now);
  }

  bool _isDueSoon(TaskViewModel task, DateTime now) {
    if (_isCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return false;

    final remaining = dueAt.difference(now);
    return remaining > Duration.zero && remaining <= _dueSoonWindow;
  }

  List<_NotificationEntry> _buildUrgentEntries(
    List<MapEntry<String, TaskViewModel>> tasks,
    DateTime now,
  ) {
    final entries = <_NotificationEntry>[];

    for (final entry in tasks) {
      final task = entry.value;
      final dueAt = task.dueAt?.toDate();
      if (dueAt == null || _isCompleted(task)) {
        continue;
      }

      final overdue = _isOverdue(task, now);
      final dueSoon = _isDueSoon(task, now);
      if (!overdue && !dueSoon) {
        continue;
      }

      entries.add(
        _NotificationEntry(
          taskId: entry.key,
          title: task.title,
          timestamp: dueAt,
          overdue: overdue,
          kind: overdue ? _NotificationKind.urgentOverdue : _NotificationKind.dueSoon,
        ),
      );
    }

    entries.sort((left, right) {
      if (left.overdue != right.overdue) {
        return left.overdue ? -1 : 1;
      }
      return left.timestamp.compareTo(right.timestamp);
    });

    return entries;
  }

  List<_NotificationEntry> _buildCompletionEntries(
    List<MapEntry<String, TaskViewModel>> tasks,
    DateTime now,
  ) {
    final entries = <_NotificationEntry>[];

    for (final entry in tasks) {
      final task = entry.value;
      if (!_isCompleted(task)) continue;

      final completedAt =
          task.completedAt?.toDate() ?? task.timestamp?.toDate() ?? task.createdAt?.toDate();
      if (completedAt == null) continue;
      if (now.difference(completedAt) > _recentCompletionWindow) continue;

      entries.add(
        _NotificationEntry(
          taskId: entry.key,
          title: task.title,
          timestamp: completedAt,
          overdue: false,
          kind: _NotificationKind.completed,
        ),
      );
    }

    entries.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return entries;
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString().padLeft(4, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  Future<void> _openUrgentTasksSheet(
    BuildContext context,
    List<_NotificationEntry> urgentEntries,
    List<_NotificationEntry> completionEntries,
    List<TaskNotificationItem> reminderTasks,
  ) async {
    await showTaskNotificationsSheet(
      context,
      badgeColor: widget.badgeColor,
      urgentEntries: urgentEntries,
      completionEntries: completionEntries,
      reminderTasks: reminderTasks,
      onClearAll: _clearAllFromBell,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId.isEmpty) {
      return IconButton(
        padding: widget.padding,
        constraints: widget.constraints,
        icon: Icon(
          Icons.notifications_outlined,
          color: widget.iconColor,
          size: widget.iconSize,
        ),
        onPressed: null,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final entries = snapshot.hasData
            ? snapshot.data!.docs
                  .map(
                    (doc) =>
                        MapEntry(doc.id, TaskViewModel.fromMap(doc.data())),
                  )
                  .toList()
            : <MapEntry<String, TaskViewModel>>[];
        final urgentEntries = _buildUrgentEntries(entries, now);
        final completionEntries = _buildCompletionEntries(entries, now);
        final reminderTasks = entries
            .where(
              (entry) =>
                  entry.value.dueAt != null &&
                  entry.value.stat != 'Hoàn thành',
            )
            .map(
              (entry) => TaskNotificationItem(
                id: entry.key,
                title: entry.value.title,
                dueAt: entry.value.dueAt!.toDate(),
              ),
            )
            .toList();
        final filteredUrgentEntries = _applyDismissedFilter(urgentEntries);
        final filteredCompletionEntries =
            _applyDismissedFilter(completionEntries);
        final totalCount =
            filteredUrgentEntries.length + filteredCompletionEntries.length;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              padding: widget.padding,
              constraints: widget.constraints,
              icon: Icon(
                Icons.notifications_outlined,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
              onPressed: () => _openUrgentTasksSheet(
                context,
                filteredUrgentEntries,
                filteredCompletionEntries,
                reminderTasks,
              ),
            ),
            if (totalCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.badgeColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              )],
        );
      },
    );
  }

}
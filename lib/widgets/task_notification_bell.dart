library task_notification_bell;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../views/task_viewmodel.dart';

part 'task_notification_bell/task_notification_bell_parts.dart';

class TaskNotificationBellButton extends StatelessWidget {
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

  static const Duration _dueSoonWindow = Duration(minutes: 10);

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
          dueAt: dueAt,
          overdue: overdue,
        ),
      );
    }

    entries.sort((left, right) {
      if (left.overdue != right.overdue) {
        return left.overdue ? -1 : 1;
      }
      return left.dueAt.compareTo(right.dueAt);
    });

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
    List<_NotificationEntry> entries,
  ) async {
    await showUrgentTasksSheet(
      context,
      badgeColor: badgeColor,
      entries: entries,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return IconButton(
        padding: padding,
        constraints: constraints,
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: null,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: userId)
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

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              padding: padding,
              constraints: constraints,
              icon: Icon(
                Icons.notifications_outlined,
                color: iconColor,
                size: iconSize,
              ),
              onPressed: () => _openUrgentTasksSheet(context, urgentEntries),
            ),
            if (urgentEntries.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      urgentEntries.length > 9
                          ? '9+'
                          : '${urgentEntries.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../views/task_viewmodel.dart';

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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: badgeColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông báo task',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            entries.isEmpty
                                ? 'Không có task quá hạn hoặc sắp đến hạn.'
                                : '${entries.length} task cần xử lý ngay',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (entries.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hiện tại chưa có task quá hạn hoặc task nào sắp đến hạn trong 10 phút tới.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: entry.overdue
                                ? AppColors.high.withValues(alpha: 0.08)
                                : AppColors.medium.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: entry.overdue
                                  ? AppColors.high.withValues(alpha: 0.18)
                                  : AppColors.medium.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: entry.overdue
                                      ? AppColors.high.withValues(alpha: 0.14)
                                      : AppColors.medium.withValues(
                                          alpha: 0.14,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  entry.overdue
                                      ? Icons.warning_rounded
                                      : Icons.schedule_rounded,
                                  color: entry.overdue
                                      ? AppColors.high
                                      : AppColors.medium,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.overdue
                                          ? 'Task quá hạn'
                                          : 'Task sắp đến hạn',
                                      style: TextStyle(
                                        color: entry.overdue
                                            ? AppColors.high
                                            : AppColors.medium,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.overdue
                                          ? 'Đã quá hạn từ ${_formatDateTime(entry.dueAt)}'
                                          : 'Còn lại rất ít thời gian, hạn vào ${_formatDateTime(entry.dueAt)}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _NotificationEntry {
  final String taskId;
  final String title;
  final DateTime dueAt;
  final bool overdue;

  const _NotificationEntry({
    required this.taskId,
    required this.title,
    required this.dueAt,
    required this.overdue,
  });
}

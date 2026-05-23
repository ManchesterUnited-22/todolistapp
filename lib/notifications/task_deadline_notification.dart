import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../views/task_viewmodel.dart';
import 'task_notification_service.dart';

class TaskDeadlineNotification extends StatefulWidget {
  final String userId;

  const TaskDeadlineNotification({super.key, required this.userId});

  @override
  State<TaskDeadlineNotification> createState() =>
      _TaskDeadlineNotificationState();
}

class _TaskDeadlineNotificationState extends State<TaskDeadlineNotification> {
  static const Duration _dueSoonWindow = Duration(minutes: 10);
  static const Duration _refreshInterval = Duration(seconds: 30);

  Timer? _timer;
  DateTime _now = DateTime.now();
  String _lastSignature = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_refreshInterval, (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isCompleted(TaskViewModel task) => task.stat == 'Hoàn thành';

  bool _isOverdue(TaskViewModel task) {
    if (_isCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return false;
    return dueAt.isBefore(_now);
  }

  bool _isDueSoon(TaskViewModel task) {
    if (_isCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return false;

    final remaining = dueAt.difference(_now);
    return remaining > Duration.zero && remaining <= _dueSoonWindow;
  }

  Future<void> _syncSystemNotifications(
    List<MapEntry<String, TaskViewModel>> tasks,
  ) async {
    final signature = tasks
        .where((entry) => !_isCompleted(entry.value))
        .map((entry) {
          final dueAt = entry.value.dueAt?.toDate().millisecondsSinceEpoch ?? 0;
          final stat = _isOverdue(entry.value)
              ? 'overdue'
              : (_isDueSoon(entry.value) ? 'dueSoon' : 'ok');
          return '${entry.key}:$dueAt:$stat';
        })
        .join('|');

    if (signature == _lastSignature) return;
    _lastSignature = signature;

    final notificationTasks = tasks
        .where(
          (entry) => !_isCompleted(entry.value) && entry.value.dueAt != null,
        )
        .map(
          (entry) => TaskNotificationItem(
            id: entry.key,
            title: entry.value.title,
            dueAt: entry.value.dueAt!.toDate(),
          ),
        )
        .toList();

    if (notificationTasks.isEmpty) return;

    await TaskNotificationService.instance.syncTaskReminders(
      tasks: notificationTasks,
      now: _now,
    );
  }

  String _labelForCount(int count, String singular, String plural) {
    return count == 1 ? singular : plural.replaceFirst('{count}', '$count');
  }

  Widget _buildBanner({
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!TaskNotificationService.instance.notificationsEnabled) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final tasks = snapshot.data!.docs
            .map((doc) => MapEntry(doc.id, TaskViewModel.fromMap(doc.data())))
            .where((entry) => entry.value.dueAt != null)
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _syncSystemNotifications(tasks);
          }
        });

        final overdueTasks = tasks
            .map((entry) => entry.value)
            .where(_isOverdue)
            .toList();
        if (overdueTasks.isNotEmpty) {
          final count = overdueTasks.length;
          final title = _labelForCount(
            count,
            '1 nhiệm vụ quá hạn',
            '{count} nhiệm vụ quá hạn',
          );
          final taskLabel = _labelForCount(
            count,
            '1 nhiệm vụ chưa được hoàn thành',
            '{count} nhiệm vụ chưa được hoàn thành',
          );

          return _buildBanner(
            icon: Icons.notification_important_rounded,
            accentColor: AppColors.high,
            backgroundColor: AppColors.high.withValues(alpha: 0.10),
            title: title,
            message:
                '$taskLabel. Hãy kiểm tra lại checkbox để cập nhật trạng thái.',
          );
        }

        final dueSoonTasks = tasks
            .map((entry) => entry.value)
            .where(_isDueSoon)
            .toList();
        if (dueSoonTasks.isNotEmpty) {
          final count = dueSoonTasks.length;
          final title = _labelForCount(
            count,
            '1 nhiệm vụ sắp đến hạn',
            '{count} nhiệm vụ sắp đến hạn',
          );
          final taskLabel = _labelForCount(
            count,
            'nhiệm vụ này',
            '{count} nhiệm vụ này',
          );

          return _buildBanner(
            icon: Icons.schedule_rounded,
            accentColor: AppColors.medium,
            backgroundColor: AppColors.medium.withValues(alpha: 0.14),
            title: title,
            message:
                'Còn khoảng 10 phút nữa đến hạn cho $taskLabel. Đây là cảnh báo nhẹ để bạn kịp xác nhận hoàn thành.',
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
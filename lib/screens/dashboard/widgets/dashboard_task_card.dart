import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/timer_service.dart';
import '../../../views/task_viewmodel.dart';
import '../dashboard_chip_style.dart';
import '../dashboard_colors.dart';
import 'dashboard_task_menu.dart';

class DashboardTaskCard extends StatelessWidget {
  final String docId;
  final TaskViewModel task;
  final bool isCompleted;
  final bool isOverdue;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTimerTap;

  const DashboardTaskCard({
    super.key,
    required this.docId,
    required this.task,
    required this.isCompleted,
    required this.isOverdue,
    required this.onToggle,
    required this.onDelete,
    this.onTimerTap,
  });

  String _formatTs(Timestamp? ts) {
    if (ts == null) return 'Chưa có';
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$hh:$mm - $dd/$mo';
  }

  bool get _isUrgent {
    if (isCompleted || isOverdue || task.dueAt == null) return false;
    final due = task.dueAt!.toDate();
    final diff = due.difference(DateTime.now());
    return diff.inMinutes > 0 && diff.inHours <= 2;
  }

  DashboardChipStyle _chipStyle() {
    final cat = (task.category ?? '').toLowerCase();
    if (cat.contains('sức khỏe') || cat.contains('health')) {
      return DashboardChipStyle(
        task.category ?? 'Sức khỏe',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      );
    } else if (cat.contains('cá nhân') || cat.contains('personal')) {
      return DashboardChipStyle(
        task.category ?? 'Cá nhân',
        DashboardColors.surfaceVariant,
        DashboardColors.outline,
      );
    } else {
      return DashboardChipStyle(
        task.category ?? 'Công việc',
        const Color(0xFFE0E7FF),
        const Color(0xFF4338CA),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _chipStyle();

    return Dismissible(
      key: ValueKey(task.title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: DashboardColors.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: DashboardColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Opacity(
        opacity: isCompleted ? 0.50 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted ? DashboardColors.surfaceContainerLow.withValues(alpha: 0.30) : DashboardColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? DashboardColors.outlineVariant.withValues(alpha: 0.30)
                  : isOverdue
                      ? DashboardColors.error.withValues(alpha: 0.25)
                      : DashboardColors.surfaceVariant.withValues(alpha: 0.20),
            ),
            boxShadow: isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: () => onToggle(!isCompleted),
                  child: isCompleted
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: DashboardColors.primary.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: DashboardColors.primary, size: 18),
                        )
                      : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: DashboardColors.outlineVariant, width: 2),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? DashboardColors.outline : DashboardColors.onSurface,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: DashboardColors.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.way == 'promodoro')
                          AnimatedBuilder(
                            animation: TimerService.instance,
                            builder: (context, _) {
                              final svc = TimerService.instance;
                              final isCurrentRunning =
                                  svc.taskDocId == docId &&
                                  svc.phase != TimerPhase.idle &&
                                  svc.phase != TimerPhase.stopped;
                              final icon = isCurrentRunning
                                  ? Icons.notifications_active_rounded
                                  : Icons.alarm_rounded;
                              final bgColor = isCurrentRunning
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFE1E0FF);
                              final fgColor = isCurrentRunning
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF4648D4);

                              return GestureDetector(
                                onTap: onTimerTap,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, size: 18, color: fgColor),
                                ),
                              );
                            },
                          ),
                        if (!isCompleted)
                          GestureDetector(
                            onTap: () => showDashboardTaskMenu(
                              context: context,
                              onDelete: onDelete,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.more_horiz_rounded, color: DashboardColors.outlineVariant, size: 20),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (task.way == 'promodoro' && (task.focusDuration != null || task.breakDuration != null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Làm ${task.focusDuration ?? 25} phút • Nghỉ ${task.breakDuration ?? 5} phút',
                          style: const TextStyle(
                            fontSize: 12,
                            color: DashboardColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_outlined, size: 15, color: DashboardColors.outline),
                            const SizedBox(width: 5),
                            Text(_formatTs(task.createdAt), style: const TextStyle(fontSize: 12, color: DashboardColors.outline)),
                          ],
                        ),
                        if (task.dueAt != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue ? Icons.alarm_outlined : Icons.schedule_outlined,
                                size: 15,
                                color: isOverdue || _isUrgent ? DashboardColors.error : DashboardColors.outline,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Hạn: ${_formatTs(task.dueAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isOverdue || _isUrgent ? FontWeight.w600 : FontWeight.w400,
                                  color: isOverdue || _isUrgent ? DashboardColors.error : DashboardColors.outline,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: chip.bg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            chip.label.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: chip.fg, letterSpacing: 0.6),
                          ),
                        ),
                        if (_isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DashboardColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ƯU TIÊN',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: DashboardColors.error, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../views/task_viewmodel.dart';
import '../calendar_colors.dart';

class CalendarTaskCard extends StatelessWidget {
  final TaskViewModel task;
  final bool isCompleted;
  final bool isOverdue;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const CalendarTaskCard({super.key, required this.task, required this.isCompleted, required this.isOverdue, required this.onToggle, required this.onDelete});

  String _formatTs(Timestamp? ts) {
    if (ts == null) return 'Chưa có';
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$hh:$mm - $dd/$mo';
  }

  _CardTheme _cardTheme() {
    final cat = (task.category ?? '').toLowerCase();
    if (isCompleted) {
      return _CardTheme(Icons.check_circle_rounded, CalendarColors.tertiary.withValues(alpha: 0.10), CalendarColors.tertiary);
    } else if (isOverdue) {
      return _CardTheme(Icons.priority_high_rounded, CalendarColors.error.withValues(alpha: 0.10), CalendarColors.error);
    } else if (cat.contains('sức')) {
      return _CardTheme(Icons.favorite_outline_rounded, CalendarColors.tertiary.withValues(alpha: 0.10), CalendarColors.tertiary);
    } else if (cat.contains('cá nhân')) {
      return _CardTheme(Icons.person_outline_rounded, CalendarColors.primaryContainer.withValues(alpha: 0.10), CalendarColors.primaryContainer);
    } else {
      return _CardTheme(Icons.work_outline_rounded, CalendarColors.primary.withValues(alpha: 0.10), CalendarColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _cardTheme();

    return Dismissible(
      key: ValueKey(task.title + (task.createdAt?.millisecondsSinceEpoch.toString() ?? '')),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: CalendarColors.error.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded, color: CalendarColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Opacity(
        opacity: isCompleted ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isOverdue ? CalendarColors.error.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.20)),
            boxShadow: isCompleted ? [] : [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: theme.iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(theme.icon, color: theme.iconFg, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? CalendarColors.outline : CalendarColors.onSurface,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: CalendarColors.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.done_all_rounded : Icons.schedule_outlined,
                          size: 14,
                          color: isCompleted ? CalendarColors.tertiary : isOverdue ? CalendarColors.error : CalendarColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'Đã hoàn thành' : isOverdue ? 'Quá hạn: ${_formatTs(task.dueAt)}' : _formatTs(task.dueAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                            color: isCompleted ? CalendarColors.tertiary : isOverdue ? CalendarColors.error : CalendarColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onToggle(!isCompleted),
                child: isCompleted
                    ? Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: CalendarColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      )
                    : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CalendarColors.outlineVariant, width: 2),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTheme {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  const _CardTheme(this.icon, this.iconBg, this.iconFg);
}

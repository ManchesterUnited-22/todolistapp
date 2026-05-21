import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../views/task_viewmodel.dart';
import '../charts_colors.dart';

class ChartsWeeklyChart extends StatelessWidget {
  final List<TaskViewModel> tasks;

  const ChartsWeeklyChart({super.key, required this.tasks});

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final tasksByDay = List.generate(7, (_) => <TaskViewModel>[]);

    for (final task in tasks) {
      final anchor = task.dueAt?.toDate() ?? task.createdAt?.toDate();
      if (anchor == null) continue;
      final dayOnly = DateTime(anchor.year, anchor.month, anchor.day);
      final diff = dayOnly.difference(monday).inDays;
      if (diff < 0 || diff > 6) continue;
      tasksByDay[diff].add(task);
    }

    final ratios = List.generate(7, (i) {
      final dayTasks = tasksByDay[i];
      if (dayTasks.isEmpty) return 0.0;
      final completed = dayTasks.where((t) => t.stat == 'Hoàn thành').length;
      return completed / dayTasks.length;
    });

    final maxVal = ratios.isEmpty ? 1.0 : ratios.reduce(math.max).clamp(0.01, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('Hiệu suất tuần', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ChartsColors.onSurface, letterSpacing: -0.2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Tuần này', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ChartsColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: glassCard,
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (dayIndex) {
                final ratio = ratios[dayIndex];
                final barFraction = maxVal > 0 ? (ratio / maxVal) : 0.0;
                final dayDate = monday.add(Duration(days: dayIndex));
                final completedCount = tasksByDay[dayIndex].where((t) => t.stat == 'Hoàn thành').length;
                final totalCount = tasksByDay[dayIndex].length;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onLongPress: () => _showDayTasks(context, dayIndex, dayDate, tasksByDay[dayIndex]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: barFraction.clamp(0.04, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: barFraction > 0.85 ? ChartsColors.primaryContainer : ChartsColors.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_dayLabels[dayIndex], style: const TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('$completedCount/$totalCount', style: const TextStyle(fontSize: 10, color: ChartsColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _showDayTasks(BuildContext context, int dayIndex, DateTime dayDate, List<TaskViewModel> dayTasks) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.only(top: 56),
          decoration: const BoxDecoration(
            color: ChartsColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${_dayLabels[dayIndex]} • ${dayDate.day.toString().padLeft(2, '0')}/${dayDate.month.toString().padLeft(2, '0')}/${dayDate.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ChartsColors.onSurface)),
                      ),
                      IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dayTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Không có nhiệm vụ trong ngày này.'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dayTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final task = dayTasks[idx];
                        final isCompleted = task.stat == 'Hoàn thành';
                        final iconColor = isCompleted ? ChartsColors.tertiary : ChartsColors.onSurfaceVariant;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_iconForCategory(task.category), color: iconColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ChartsColors.onSurface)),
                                    const SizedBox(height: 4),
                                    Text('${task.category.isEmpty ? 'Không có nhãn' : task.category} • ${isCompleted ? 'Hoàn thành' : 'Chưa hoàn thành'}', style: const TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? ChartsColors.tertiary : ChartsColors.onSurfaceVariant),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String label) {
    final n = label.toLowerCase();
    if (n.contains('sức') || n.contains('khỏe')) return Icons.favorite_rounded;
    if (n.contains('cá nhân') || n.contains('personal')) return Icons.person_rounded;
    if (n.contains('học')) return Icons.school_outlined;
    return Icons.work_rounded;
  }
}

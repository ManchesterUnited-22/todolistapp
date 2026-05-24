import 'package:flutter/material.dart';
import '../../../views/stats_viewmodel.dart';
import '../charts_colors.dart';
import '../charts_ring_painter.dart';

class ChartsKpiSection extends StatelessWidget {
  final StatsViewModel stats;

  const ChartsKpiSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final completionPct = (stats.dailyCompletionRate * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.timer_outlined,
                iconColor: ChartsColors.primary,
                label: 'Tập trung',
                value: stats.bestFocusWindowLabel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.local_fire_department_outlined,
                iconColor: ChartsColors.tertiary,
                label: 'Chuỗi ngày',
                value: stats.streakLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: glassCard,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: ChartsColors.secondary, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tỷ lệ hoàn thành', style: TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant, letterSpacing: 0.3)),
                    Text('$completionPct%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ChartsColors.secondary)),
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(
                  painter: ChartsRingPainter(value: stats.dailyCompletionRate),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _KpiCard({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: iconColor)),
        ],
      ),
    );
  }
}

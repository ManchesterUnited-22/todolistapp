import 'package:flutter/material.dart';
import '../../../views/stats_viewmodel.dart';
import '../charts_colors.dart';

class ChartsFocusSection extends StatelessWidget {
  final StatsViewModel stats;

  const ChartsFocusSection({super.key, required this.stats});

  String _formatFocus(int minutes) => minutes <= 0 ? '0h 0p' : '${minutes ~/ 60}h ${minutes % 60}p';
  String _formatBreak(int minutes) => minutes <= 0 ? '0h 0p' : '${minutes ~/ 60}h ${minutes % 60}p';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Chỉ số tập trung', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ChartsColors.onSurface, letterSpacing: -0.2)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _InsightTile(
                icon: Icons.psychology_outlined,
                iconColor: ChartsColors.tertiary,
                label: 'Tổng thời gian tập trung hôm nay',
                value: _formatFocus(stats.averageFocusMinutes),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InsightTile(
                icon: Icons.coffee_outlined,
                iconColor: ChartsColors.secondary,
                label: 'Tổng thời gian nghỉ hôm nay',
                value: _formatBreak(stats.breakMinutes),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InsightTile({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: glassCard,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ChartsColors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

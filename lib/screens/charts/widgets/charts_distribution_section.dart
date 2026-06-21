import 'package:flutter/material.dart';
import '../../../views/stats_viewmodel.dart';
import '../charts_colors.dart';

class ChartsDistributionSection extends StatelessWidget {
  final StatsViewModel stats;

  const ChartsDistributionSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    double healthRatio   = 0.0;
    double workRatio     = 0.0;
    double personalRatio = 0.0;
    double studyRatio    = 0.0;

    stats.categoryRatios.forEach((rawName, ratio) {
      final n = rawName.toLowerCase();
      if (n.contains('sức') || n.contains('khỏe') || n.contains('health')) {
        healthRatio += ratio;
      } else if (n.contains('học') || n.contains('study') || n.contains('education')) {
        studyRatio += ratio;
      } else if (n.contains('cá nhân') || n.contains('ca nhan') || n.contains('personal')) {
        personalRatio += ratio;
      } else {
        // "Công việc" và mọi thứ còn lại
        workRatio += ratio;
      }
    });

    // Chuẩn hóa nếu tổng > 1 do float
    final total = healthRatio + workRatio + personalRatio + studyRatio;
    if (total > 1.01) {
      healthRatio   /= total;
      workRatio     /= total;
      personalRatio /= total;
      studyRatio    /= total;
    }

    final categories = <Map<String, dynamic>>[
      {'name': 'Công việc', 'ratio': workRatio,     'icon': Icons.work_rounded,           'color': ChartsColors.secondary},
      {'name': 'Học tập',   'ratio': studyRatio,    'icon': Icons.school_rounded,          'color': ChartsColors.primary},
      {'name': 'Cá nhân',   'ratio': personalRatio, 'icon': Icons.person_rounded,          'color': ChartsColors.primaryContainer},
      {'name': 'Sức khỏe',  'ratio': healthRatio,   'icon': Icons.favorite_rounded,        'color': ChartsColors.tertiary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('Phân tích chi tiết', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ChartsColors.onSurface, letterSpacing: -0.2)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: categories.map((share) {
              final color = share['color'] as Color;
              final name = share['name'] as String;
              final ratio = (share['ratio'] as double).clamp(0.0, 1.0);
              final icon = share['icon'] as IconData;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _InsightRow(
                  icon: icon,
                  iconColor: color,
                  label: name,
                  value: '${(ratio * 100).round()}%',
                  ratio: ratio,
                  barColor: color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double ratio;
  final Color barColor;

  const _InsightRow({required this.icon, required this.iconColor, required this.label, required this.value, required this.ratio, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ChartsColors.onSurface)),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ChartsColors.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: ratio.clamp(0.0, 1.0),
                  backgroundColor: barColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../views/stats_viewmodel.dart';
import '../charts_colors.dart';

class ChartsSummaryBanner extends StatelessWidget {
  final StatsViewModel stats;

  const ChartsSummaryBanner({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = (stats.completionRate * 100).round();
    final String headline;
    final String subline;
    if (pct >= 80) {
      headline = 'Tuyệt vời!';
      subline = 'Bạn đã hoàn thành $pct% mục tiêu. Tiếp tục phát huy nhé!';
    } else if (pct >= 50) {
      headline = 'Cố lên nào!';
      subline = 'Bạn đã hoàn thành $pct% — đang đi đúng hướng!';
    } else if (pct > 0) {
      headline = 'Bắt đầu thôi!';
      subline = 'Chỉ mới $pct% — mỗi bước nhỏ đều quan trọng.';
    } else {
      headline = 'Hôm nay bắt đầu nào!';
      subline = 'Chưa có công việc nào. Hãy thêm nhiệm vụ đầu tiên!';
    }

    return Container(
      decoration: BoxDecoration(
        color: ChartsColors.primaryFixed.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ChartsColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ChartsColors.onPrimaryFixed, letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    Text(subline, style: const TextStyle(fontSize: 15, color: ChartsColors.onPrimaryFixedVar, height: 1.45)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.insights_rounded, color: ChartsColors.primary, size: 44),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

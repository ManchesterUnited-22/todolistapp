import 'package:flutter/material.dart';
import '../charts_colors.dart';

class ChartsMotivationCard extends StatelessWidget {
  const ChartsMotivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChartsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ChartsColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: ChartsColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Bạn có biết?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ChartsColors.primary, letterSpacing: -0.2)),
          const SizedBox(height: 8),
          const Text(
            'Nghỉ ngơi 5 phút sau mỗi 25 phút làm việc giúp tăng 20% hiệu suất não bộ.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: ChartsColors.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
}

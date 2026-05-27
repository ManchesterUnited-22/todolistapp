import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/stats_service.dart';
import '../../../views/stats_viewmodel.dart';
import '../dashboard_colors.dart';

class DashboardStreakCard extends StatelessWidget {
  final String userUid;

  const DashboardStreakCard({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    if (userUid.isEmpty) {
      return _StreakCard(
        streakLabel: '0 ngày',
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: StatsService.instance.watchUserStats(userUid),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final stats = data == null ? null : StatsViewModel.fromFirestore(data);
        final streakDays = stats?.streakDays ?? 0;
        final streakLabel = stats?.streakLabel ?? '0 ngày';

        return _StreakCard(
          streakLabel: streakLabel,
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String streakLabel;

  const _StreakCard({required this.streakLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DashboardColors.surfaceVariant.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EEE0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFB7791F),
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'CHUỖI NGÀY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DashboardColors.onSurfaceVariant.withValues(alpha: 0.88),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            streakLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DashboardColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

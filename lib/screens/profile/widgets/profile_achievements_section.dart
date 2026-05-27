import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../profile_badge.dart';
import '../profile_colors.dart';
import 'profile_badge_tile.dart';

class ProfileAchievementsSection extends StatelessWidget {
  final String userId;

  const ProfileAchievementsSection({super.key, required this.userId});

  String _unlockConditionText(ProfileBadge badge) {
    switch (badge.unlockField) {
      case 'earlyMorningSessions':
        return 'Hoàn thành ${badge.unlockThreshold} phiên tập trung buổi sáng (trước 8:00)';
      case 'focusStreakDays':
        return 'Duy trì streak ${badge.unlockThreshold} ngày liên tiếp';
      case 'totalFocusMinutes':
        final hours = badge.unlockThreshold ~/ 60;
        return 'Tích luỹ ${hours > 0 ? "$hours giờ" : "${badge.unlockThreshold} phút"} tập trung';
      case 'tasksCompleted':
        return 'Hoàn thành ${badge.unlockThreshold} nhiệm vụ';
      case 'lateNightSessions':
        return 'Hoàn thành ${badge.unlockThreshold} phiên tập trung buổi tối (sau 22:00)';
      default:
        return 'Hoàn thành ${badge.unlockThreshold} ${badge.unlockField}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Huy hiệu thành tích',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: ProfileColors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ProfileColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: userId.isNotEmpty
              ? FirebaseFirestore.instance
                    .collection('achievements')
                    .doc(userId)
                    .snapshots()
              : null,
          builder: (context, snap) {
            final data = snap.data?.data() as Map<String, dynamic>? ?? {};
            final cards = profileBadges.map((badge) {
              final fieldVal = (data[badge.unlockField] as num?)?.toInt() ?? 0;
              final isUnlocked =
                  !badge.locked || fieldVal >= badge.unlockThreshold;
              final progress = badge.unlockThreshold <= 0
                  ? 1.0
                  : (fieldVal / badge.unlockThreshold).clamp(0.0, 1.0);
              return ProfileBadgeTile(
                badge: badge,
                isUnlocked: isUnlocked,
                progress: progress,
                progressLabel: '${(progress * 100).round()}%',
                conditionText: _unlockConditionText(badge),
              );
            }).toList();

            return Column(
              children: cards
                  .map(
                    (badge) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: badge,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

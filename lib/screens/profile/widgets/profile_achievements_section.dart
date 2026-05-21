import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../profile_badge.dart';
import '../profile_colors.dart';
import 'profile_badge_tile.dart';

class ProfileAchievementsSection extends StatelessWidget {
  final String userId;

  const ProfileAchievementsSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'HUY HIỆU THÀNH TÍCH',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: ProfileColors.onSurfaceVariant,
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: userId.isNotEmpty ? FirebaseFirestore.instance.collection('achievements').doc(userId).snapshots() : null,
          builder: (context, snap) {
            final data = snap.data?.data() as Map<String, dynamic>? ?? {};
            return GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: profileBadges.map((badge) {
                final fieldVal = (data[badge.unlockField] as num?)?.toInt() ?? 0;
                final isUnlocked = !badge.locked || fieldVal >= badge.unlockThreshold;
                return ProfileBadgeTile(badge: badge, isUnlocked: isUnlocked);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

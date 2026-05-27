import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../notifications/task_notification_bell.dart';
import '../widgets/floating_bottom_navbar.dart';
import 'profile/profile_badge.dart';
import 'profile/profile_colors.dart';
import 'profile/widgets/profile_achievements_section.dart';

class AchievementsScreen extends StatefulWidget {
  final bool showBottomNav;

  const AchievementsScreen({super.key, this.showBottomNav = true});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ProfileColors.surface.withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: ProfileColors.surfaceContainerHigh.withValues(alpha: 0.30),
        ),
      ),
      title: const Text(
        'Thành tựu',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: ProfileColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        TaskNotificationBellButton(
          userId: _currentUserUid,
          iconColor: ProfileColors.primary,
          badgeColor: ProfileColors.error,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.surface,
      appBar: _buildAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _currentUserUid.isNotEmpty
            ? FirebaseFirestore.instance
                  .collection('achievements')
                  .doc(_currentUserUid)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final unlockedCount = profileBadges.where((badge) {
            final fieldVal = (data[badge.unlockField] as num?)?.toInt() ?? 0;
            return !badge.locked || fieldVal >= badge.unlockThreshold;
          }).length;
          final totalCount = profileBadges.length;
          final overallProgress = totalCount == 0
              ? 0.0
              : unlockedCount / totalCount;
          final percent = (overallProgress * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ProfileColors.primaryFixed.withOpacity(0.92),
                        ProfileColors.surface.withOpacity(0.96),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ProfileColors.primary.withOpacity(0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ProfileColors.primary.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: ProfileColors.surface.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: overallProgress,
                                  strokeWidth: 6,
                                  backgroundColor: const Color(0xFFE8EBF7),
                                  valueColor: const AlwaysStoppedAnimation(
                                    ProfileColors.primary,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                                Text(
                                  '$percent%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: ProfileColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Huy hiệu thành tích',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: ProfileColors.primary,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bạn đang theo dõi toàn bộ huy hiệu đã mở khóa.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: ProfileColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ProfileAchievementsSection(userId: _currentUserUid),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const FloatingBottomNavBar(currentIndex: 2, showFab: false)
          : null,
    );
  }
}

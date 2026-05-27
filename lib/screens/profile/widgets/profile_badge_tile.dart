import 'package:flutter/material.dart';
import '../profile_badge.dart';
import '../profile_colors.dart';

class ProfileBadgeTile extends StatelessWidget {
  final ProfileBadge badge;
  final bool isUnlocked;
  final double progress;
  final String progressLabel;
  final String conditionText;

  const ProfileBadgeTile({
    super.key,
    required this.badge,
    required this.isUnlocked,
    required this.progress,
    required this.progressLabel,
    required this.conditionText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeInfo(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? badge.iconColor.withOpacity(0.28)
                : ProfileColors.surfaceContainerHigh.withOpacity(0.85),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? badge.bgColor
                        : ProfileColors.surfaceContainer.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                      color: isUnlocked
                          ? badge.iconColor
                          : ProfileColors.outline,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              badge.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ProfileColors.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? badge.iconColor.withOpacity(0.12)
                                  : ProfileColors.surfaceContainer.withOpacity(
                                      0.75,
                                    ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              progressLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isUnlocked
                                    ? badge.iconColor
                                    : ProfileColors.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isUnlocked
                            ? 'Bạn đã đạt được huy hiệu này!'
                            : conditionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ProfileColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TIẾN ĐỘ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: ProfileColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: ProfileColors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? badge.iconColor : ProfileColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      progressLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? badge.iconColor
                            : ProfileColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _progressSuffix(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ProfileColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _progressSuffix() {
    switch (badge.unlockField) {
      case 'earlyMorningSessions':
        return 'phiên sáng';
      case 'focusStreakDays':
        return 'ngày';
      case 'totalFocusMinutes':
        return 'phút tập trung';
      case 'tasksCompleted':
        return 'nhiệm vụ';
      case 'lateNightSessions':
        return 'phiên tối';
      default:
        return 'mục tiêu';
    }
  }

  void _showBadgeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? badge.bgColor
                    : ProfileColors.surfaceVariant.withOpacity(0.30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isUnlocked
                  ? Icon(badge.icon, color: badge.iconColor, size: 36)
                  : const Icon(
                      Icons.lock_rounded,
                      color: ProfileColors.outline,
                      size: 32,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ProfileColors.onSurface,
              ),
            ),
           
            Text(
              isUnlocked
                  ? '✅ Bạn đã đạt được huy hiệu này!'
                  : '🔒 Điều kiện mở khoá:\n$conditionText',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isUnlocked
                    ? ProfileColors.tertiary
                    : ProfileColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Đóng',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: ProfileColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

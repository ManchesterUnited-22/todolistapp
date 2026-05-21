import 'package:flutter/material.dart';
import '../profile_badge.dart';
import '../profile_colors.dart';

class ProfileBadgeTile extends StatelessWidget {
  final ProfileBadge badge;
  final bool isUnlocked;

  const ProfileBadgeTile({super.key, required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeInfo(context),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isUnlocked ? 1.0 : 0.50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isUnlocked ? 0.50 : 0.0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.50),
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked ? badge.bgColor : ProfileColors.surfaceVariant.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isUnlocked
                    ? Icon(badge.icon, color: badge.iconColor, size: 24)
                    : const Icon(Icons.lock_outline_rounded, color: ProfileColors.outline, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                badge.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: ProfileColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeInfo(BuildContext context) {
    final conditionText = _unlockConditionText();
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
                color: isUnlocked ? badge.bgColor : ProfileColors.surfaceVariant.withOpacity(0.30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isUnlocked
                  ? Icon(badge.icon, color: badge.iconColor, size: 36)
                  : const Icon(Icons.lock_rounded, color: ProfileColors.outline, size: 32),
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
            const SizedBox(height: 8),
            Text(
              isUnlocked ? '✅ Bạn đã đạt được huy hiệu này!' : '🔒 Điều kiện mở khoá:\n$conditionText',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isUnlocked ? ProfileColors.tertiary : ProfileColors.onSurfaceVariant,
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

  String _unlockConditionText() {
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
}

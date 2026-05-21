import 'package:flutter/material.dart';
import 'profile_colors.dart';

class ProfileBadge {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final bool locked;
  final String unlockField;
  final int unlockThreshold;

  const ProfileBadge({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.locked,
    required this.unlockField,
    required this.unlockThreshold,
  });
}

const profileBadges = [
  ProfileBadge(
    icon: Icons.workspace_premium_rounded,
    label: 'Bình Minh',
    iconColor: ProfileColors.tertiary,
    bgColor: Color(0x1A006C49),
    locked: true,
    unlockField: 'earlyMorningSessions',
    unlockThreshold: 1,
  ),
  ProfileBadge(
    icon: Icons.bolt_rounded,
    label: 'Tự tại',
    iconColor: ProfileColors.secondary,
    bgColor: Color(0x1A0060AC),
    locked: true,
    unlockField: 'focusStreakDays',
    unlockThreshold: 3,
  ),
  ProfileBadge(
    icon: Icons.auto_awesome_rounded,
    label: 'Tập Trung',
    iconColor: ProfileColors.primary,
    bgColor: Color(0x1A4648D4),
    locked: true,
    unlockField: 'totalFocusMinutes',
    unlockThreshold: 60,
  ),
  ProfileBadge(
    icon: Icons.local_fire_department_rounded,
    label: 'Bền Bỉ',
    iconColor: Color(0xFFE65100),
    bgColor: Color(0x1AE65100),
    locked: true,
    unlockField: 'focusStreakDays',
    unlockThreshold: 7,
  ),
  ProfileBadge(
    icon: Icons.military_tech_rounded,
    label: 'Trưởng Thành',
    iconColor: Color(0xFFB8860B),
    bgColor: Color(0x1AB8860B),
    locked: true,
    unlockField: 'tasksCompleted',
    unlockThreshold: 20,
  ),
  ProfileBadge(
    icon: Icons.diamond_rounded,
    label: 'Thông tuệ',
    iconColor: Color(0xFF7B1FA2),
    bgColor: Color(0x1A7B1FA2),
    locked: true,
    unlockField: 'totalFocusMinutes',
    unlockThreshold: 600,
  ),
  ProfileBadge(
    icon: Icons.nights_stay_rounded,
    label: 'Đêm Thâu Tĩnh Lặng',
    iconColor: Color(0xFF1565C0),
    bgColor: Color(0x1A1565C0),
    locked: true,
    unlockField: 'lateNightSessions',
    unlockThreshold: 5,
  ),
  ProfileBadge(
    icon: Icons.emoji_events_rounded,
    label: 'Trọn vẹn',
    iconColor: Color(0xFFAD1457),
    bgColor: Color(0x1AAD1457),
    locked: true,
    unlockField: 'tasksCompleted',
    unlockThreshold: 100,
  ),
];

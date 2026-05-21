import 'package:flutter/material.dart';
import '../../../widgets/task_notification_bell.dart';
import '../dashboard_colors.dart';

class DashboardTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final String userUid;

  const DashboardTopBar({super.key, required this.onMenuTap, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: DashboardColors.surface.withValues(alpha: 0.60),
        border: Border(bottom: BorderSide(color: DashboardColors.surfaceVariant.withValues(alpha: 0.10))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(999)),
              child: const Icon(Icons.menu_rounded, color: DashboardColors.onSurface, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Serene Focus',
            style: TextStyle(color: DashboardColors.primary, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
          ),
          const Spacer(),
          TaskNotificationBellButton(userId: userUid, iconColor: DashboardColors.onSurfaceVariant, badgeColor: DashboardColors.error),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}

const List<_NavItemData> _items = [
    _NavItemData(Icons.home_rounded, 'Trang chủ'),
    _NavItemData(Icons.calendar_today_rounded, 'Lịch của tôi'),
    _NavItemData(Icons.bar_chart_rounded, 'Thống kê'),
    _NavItemData(Icons.person_rounded, 'Hồ sơ'),
];

// ─── Main widget ──────────────────────────────────────────────────────────────

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool showFab;
  final bool fabAtCorner;
  final ValueChanged<int>? onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.showFab = true,
    this.fabAtCorner = false,
  });

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    const routeMap = {
      0: '/dashboard',
      1: '/calendar',
      2: '/stats',
      3: '/profile',
    };

    final route = routeMap[index];
    if (route != null) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: _items[0].icon,
              label: _items[0].label,
              selected: currentIndex == 0,
              onTap: () => _handleTap(context, 0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: _items[1].icon,
              label: _items[1].label,
              selected: currentIndex == 1,
              onTap: () => _handleTap(context, 1),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: _items[2].icon,
              label: _items[2].label,
              selected: currentIndex == 2,
              onTap: () => _handleTap(context, 2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: _items[3].icon,
              label: _items[3].label,
              selected: currentIndex == 3,
              onTap: () => _handleTap(context, 3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav item widget ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brand : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: selected ? 40 : 36,
            height: selected ? 40 : 36,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.brand.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: selected ? 22 : 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
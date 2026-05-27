import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItemData(this.icon, this.label, this.color);
}

const List<_NavItemData> _items = [
  _NavItemData(Icons.home_rounded, 'Trang chủ', Colors.blue),
  _NavItemData(Icons.calendar_today_rounded, 'Lịch của tôi', Colors.green),
  _NavItemData(Icons.emoji_events_rounded, 'Thành tựu', Colors.amber),
  _NavItemData(Icons.person_rounded, 'Hồ sơ', Colors.black),
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
      2: '/achievements',
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
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            _items.length,
            (index) => Expanded(
              child: _NavItem(
                icon: _items[index].icon,
                label: _items[index].label,
                iconColor: _items[index].color,
                selected: currentIndex == index,
                onTap: () => _handleTap(context, index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav item widget ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? iconColor
        : iconColor.withValues(alpha: 0.70);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.brand.withValues(alpha: 0.06),
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon container ────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? iconColor.withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              // ── Label ────────────────────────────────────────────────
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: selected ? 0.1 : 0.0,
                ),
              ),
              const SizedBox(height: 4),
              // ── Active dot ───────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: selected ? iconColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
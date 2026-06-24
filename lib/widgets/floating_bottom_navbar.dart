import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';

class _NavItemData {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItemData(this.icon, this.label, this.color);
}

// 5 Tab theo yêu cầu AI-First
const List<_NavItemData> _items = [
  _NavItemData(Icons.home_rounded, 'Home', Color(0xFF6366F1)),           // AI Assistant
  _NavItemData(Icons.calendar_today_rounded, 'Timeline', Color(0xFF14B8A6)),
  _NavItemData(Icons.flag_rounded, 'Goals', Color(0xFF8B5CF6)),
  _NavItemData(Icons.insights_rounded, 'Insights', Color(0xFFEC4899)),
  _NavItemData(Icons.person_rounded, 'Profile', Color(0xFF64748B)),
];

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                onTap: () => onTap?.call(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    final textColor = selected ? iconColor : iconColor.withOpacity(0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.brand.withOpacity(0.06),
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? iconColor.withOpacity(0.10) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected ? iconColor : iconColor.withOpacity(0.75),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 20 : 0,
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
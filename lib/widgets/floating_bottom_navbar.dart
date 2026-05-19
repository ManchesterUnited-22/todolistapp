import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/ai/app_controller.dart';
import 'package:smart_app/ai/tour_keys.dart';

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
    if (AppController.instance.isTourActive) return;
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default navigation using named routes
    final routeMap = {
      0: '/dashboard',
      1: '/stats',
      2: '/calendar',
      3: '/profile',
    };

    final route = routeMap[index];
    if (route != null) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  void _openAddTaskSheet(BuildContext context) {
    // TODO: Implement your add task bottom sheet here
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          const Center(child: Text('Add Task Sheet - Implement here')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom Navigation Bar
        Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: showFab && !fabAtCorner
                ? [
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabHome,
                        icon: _items[0].icon,
                        label: _items[0].label,
                        selected: currentIndex == 0,
                        onTap: () => _handleTap(context, 0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabStats,
                        icon: _items[1].icon,
                        label: _items[1].label,
                        selected: currentIndex == 1,
                        onTap: () => _handleTap(context, 1),
                      ),
                    ),
                    const SizedBox(width: 54), // Space for FAB
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabCalendar,
                        icon: _items[2].icon,
                        label: _items[2].label,
                        selected: currentIndex == 2,
                        onTap: () => _handleTap(context, 2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabProfile,
                        icon: _items[3].icon,
                        label: _items[3].label,
                        selected: currentIndex == 3,
                        onTap: () => _handleTap(context, 3),
                      ),
                    ),
                  ]
                : [
                    // Full 4 items without FAB space
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabHome,
                        icon: _items[0].icon,
                        label: _items[0].label,
                        selected: currentIndex == 0,
                        onTap: () => _handleTap(context, 0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabStats,
                        icon: _items[1].icon,
                        label: _items[1].label,
                        selected: currentIndex == 1,
                        onTap: () => _handleTap(context, 1),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabCalendar,
                        icon: _items[2].icon,
                        label: _items[2].label,
                        selected: currentIndex == 2,
                        onTap: () => _handleTap(context, 2),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        key: TourKeys.neoTabProfile,
                        icon: _items[3].icon,
                        label: _items[3].label,
                        selected: currentIndex == 3,
                        onTap: () => _handleTap(context, 3),
                      ),
                    ),
                  ],
          ),
        ),

        // Floating Action Button
        if (showFab)
          fabAtCorner
              ? Positioned(
                  bottom: 96,
                  right: 24,
                  child: FloatingActionButton(
                    heroTag: 'floating_bottom_nav_add',
                    onPressed: AppController.instance.isTourActive
                        ? null
                        : () => _openAddTaskSheet(context),
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                )
              : Positioned(
                  bottom: 20,
                  child: FloatingActionButton(
                    heroTag: 'floating_bottom_nav_add',
                    onPressed: AppController.instance.isTourActive
                        ? null
                        : () => _openAddTaskSheet(context),
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                ),
      ],
    );
  }
}

// ==================== Private Widgets ====================

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

class _NavEntry {
  final IconData icon;
  final String label;
  const _NavEntry(this.icon, this.label);
}

const List<_NavEntry> _items = [
  _NavEntry(Icons.home_filled, 'Trang chủ'),
  _NavEntry(Icons.bar_chart_outlined, 'Thống kê'),
  _NavEntry(Icons.calendar_month_outlined, 'Lịch của tôi'),
  _NavEntry(Icons.person_outline, 'Hồ sơ'),
];

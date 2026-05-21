import 'package:flutter/material.dart';
import '../calendar_colors.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final List<Color> dots;
  final int badgeCount;

  const CalendarDayCell({super.key, required this.day, required this.isSelected, required this.dots, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (isSelected)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  color: CalendarColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CalendarColors.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (badgeCount > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                ],
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: CalendarColors.onSurface),
              ),
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Colors.white : CalendarColors.onSurface,
              ),
            ),
            if (dots.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots
                    .take(3)
                    .map(
                      (c) => Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.80) : c,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

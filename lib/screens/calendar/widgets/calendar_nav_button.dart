import 'package:flutter/material.dart';
import '../calendar_colors.dart';

class CalendarNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CalendarNavButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: CalendarColors.primary, size: 24),
      ),
    );
  }
}

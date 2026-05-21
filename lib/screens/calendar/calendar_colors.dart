import 'package:flutter/material.dart';

class CalendarColors {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const outlineVariant = Color(0xFFC7C4D7);
  static const outline = Color(0xFF767586);
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const error = Color(0xFFBA1A1A);
  static const tertiary = Color(0xFF006C49);
  static const secondaryFixed = Color(0xFFD4E3FF);
  static const onSecondaryFixed = Color(0xFF001C39);
}

BoxDecoration get calendarGlassCard => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.70),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ],
);

import 'package:flutter/material.dart';

class ChartsColors {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const onPrimaryFixedVar = Color(0xFF2F2EBE);
  static const onPrimaryFixed = Color(0xFF07006C);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const secondary = Color(0xFF0060AC);
  static const tertiary = Color(0xFF006C49);
  static const error = Color(0xFFBA1A1A);
  static const outlineVariant = Color(0xFFC7C4D7);
}

BoxDecoration get glassCard => BoxDecoration(
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

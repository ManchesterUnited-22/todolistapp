import 'package:flutter/material.dart';

/// Centralized color palette for the app.
class AppColors {
  // Brand
  static const Color brand = Color(0xFF6366F1); // Indigo Blue

  // Surface & background
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // dark slate
  static const Color textSecondary = Color(0xFF475569); // neutral gray

  // Semantic / status
  static const Color high = Color(0xFFF87171); // red for High priority
  static const Color medium = Color(0xFFFBBF24); // amber for Medium
  static const Color low = Color(0xFF34D399); // green for Low
  static const Color info = Color(0xFF60A5FA); // blue accent
  static const Color tertiary = Color(0xFF006C49); // teal green
}

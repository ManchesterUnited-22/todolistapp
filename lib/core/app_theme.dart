// lib/core/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
    ),
    cardTheme: CardThemeData(           // ← Đã sửa
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6366F1),
    ),
  );
}
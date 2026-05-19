import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'app_theme_mode';
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  static ThemeMode get currentMode => mode.value;
  static bool get isDarkMode => mode.value == ThemeMode.dark;
  static bool get isLightMode => mode.value == ThemeMode.light;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key) ?? 'light';
    switch (stored) {
      case 'dark':
        mode.value = ThemeMode.dark;
        break;
      case 'system':
        mode.value = ThemeMode.system;
        break;
      default:
        mode.value = ThemeMode.light;
    }
  }

  static Future<void> setMode(ThemeMode m) async {
    mode.value = m;
    final prefs = await SharedPreferences.getInstance();
    final s = m == ThemeMode.dark ? 'dark' : (m == ThemeMode.system ? 'system' : 'light');
    await prefs.setString(_key, s);
  }

  static Future<void> setDarkMode() async {
    await setMode(ThemeMode.dark);
  }

  static Future<void> setLightMode() async {
    await setMode(ThemeMode.light);
  }

  static Future<void> toggle() async {
    final next = mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setMode(next);
  }

  static Future<void> toggleMode() async {
    await toggle();
  }
}

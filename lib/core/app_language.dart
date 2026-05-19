import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLanguage {
  AppLanguage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _storageKey = 'app_language_code';

  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('en'),
  );

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
    Locale('fr'),
    Locale('ko'),
    Locale('ja'),
  ];

  static const List<String> supportedLanguageCodes = <String>[
    'en',
    'vi',
    'fr',
    'ko',
    'ja',
  ];

  static Locale fromCode(String code) {
    final normalized = code.trim().toLowerCase();
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == normalized,
      orElse: () => const Locale('en'),
    );
  }

  static Future<void> initialize() async {
    final savedCode = await _storage.read(key: _storageKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      locale.value = fromCode(savedCode);
    }
  }

  static String currentLanguageCode() => locale.value.languageCode;

  static Future<void> setLanguageCode(String code) async {
    final nextLocale = fromCode(code);
    locale.value = nextLocale;
    await _storage.write(key: _storageKey, value: nextLocale.languageCode);
  }

  static String aiLanguageInstruction() {
    switch (currentLanguageCode()) {
      case 'vi':
        return 'Tra loi hoan toan bang tieng Viet.';
      case 'fr':
        return 'Reponds uniquement en francais.';
      case 'ko':
        return '한국어로만 답변하세요.';
      case 'ja':
        return '日本語のみで答えてください。';
      case 'en':
      default:
        return 'Reply only in English.';
    }
  }
}

part of voice_ai_service;

/// Normalize text before TTS so uncommon words are pronounced clearly.
/// E.g. "promodoro" → "pô mô đô rô", "pomodoro" → "pô mô đô rô"
String _normalizeTtsText(String text) {
  final replacements = <String, String>{
    // Promodoro / Pomodoro variations
    r'promodoro': 'pô mô đô rô',
    r'pomodoro': 'pô mô đô rô',
    r'promodo': 'pô mô đô rô',
    r'pomo': 'pô mô',
    // English tech words that TTS mispronounces in Vietnamese
    r'dashboard': 'đát bô',
    r'timer': 'tai mơ',
    r'task': 'tát xờ',
    r'focus': 'phô cờ xờ',
    r'break': 'brây cờ',
    r'long_term_task': 'nhiệm vụ dài hạn',
    r'long term task': 'nhiệm vụ dài hạn',
  };

  String result = text;
  for (final entry in replacements.entries) {
    result = result.replaceAll(
      RegExp(entry.key, caseSensitive: false),
      entry.value,
    );
  }
  return result;
}

Future<void> voiceAiSpeakText(VoiceAiService self, String text) async {
  try {
    await self._tts.stop();
    await self._tts.setLanguage('vi-VN');
    await self._tts.setSpeechRate(0.42);
    await self._tts.setPitch(0.98);
    await self._tts.setVolume(1.0);

    final normalized = _normalizeTtsText(text);

    final completer = Completer<void>();

    self._tts.setStartHandler(() {
      if (kDebugMode) debugPrint('TTS started');
    });
    self._tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
      if (kDebugMode) debugPrint('TTS completed');
    });
    self._tts.setErrorHandler((msg) {
      if (!completer.isCompleted) completer.complete();
      if (kDebugMode) debugPrint('TTS error: $msg');
    });

    try {
      await self._tts.awaitSpeakCompletion(true);
    } catch (_) {}

    await self._tts.speak(normalized);

    try {
      await completer.future.timeout(
        Duration(seconds: max(5, (normalized.length ~/ 15) + 1)),
      );
    } catch (_) {}
  } catch (e) {
    if (kDebugMode) debugPrint('AIService TTS error: $e');
  }
}
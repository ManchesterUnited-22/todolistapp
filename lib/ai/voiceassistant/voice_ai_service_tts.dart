part of voice_ai_service;

/// Normalize text before TTS so uncommon words are pronounced clearly.
/// E.g. "promodoro" → "pô mô đô rô", "pomodoro" → "pô mô đô rô"
String _normalizeTtsText(String text) {
  String result = text;

  // Ngày/tháng/năm dạng dd/MM/yyyy -> đọc thành lời, không đọc dấu gạch chéo.
  // Phải xử lý TRƯỚC bước xử lý phân số bên dưới, nếu không "22/06/2026" sẽ
  // bị đọc sai thành "22 trên 06 trên 2026".
  result = result.replaceAllMapped(
    RegExp(r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b'),
    (m) => 'ngày ${int.parse(m.group(1)!)} tháng ${int.parse(m.group(2)!)} năm ${m.group(3)}',
  );

  // Tháng/năm dạng MM/yyyy (ví dụ nhãn "06/2026" của biểu đồ tháng).
  result = result.replaceAllMapped(
    RegExp(r'\b(\d{1,2})/(\d{4})\b'),
    (m) => 'tháng ${int.parse(m.group(1)!)} năm ${m.group(2)}',
  );

  // Mọi tỉ lệ/số lượng dạng X/Y còn lại (ví dụ "0/16 nhiệm vụ") -> đọc thành
  // "X trên Y" cho tự nhiên, thay vì bỏ qua hoặc đọc nhầm dấu gạch chéo.
  result = result.replaceAllMapped(
    RegExp(r'(\d+)\s*/\s*(\d+)'),
    (m) => '${m.group(1)} trên ${m.group(2)}',
  );

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

  for (final entry in replacements.entries) {
    result = result.replaceAll(
      RegExp(entry.key, caseSensitive: false),
      entry.value,
    );
  }
  return result;
}

Future<void> voiceAiSpeakText(VoiceAiService self, String text, {double? speechRate}) async {
  try {
    await self._tts.stop();
    await self._tts.setLanguage('vi-VN');
    await self._tts.setSpeechRate(speechRate ?? 0.42);
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
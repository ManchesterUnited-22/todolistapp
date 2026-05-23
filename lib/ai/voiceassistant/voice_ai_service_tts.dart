part of voice_ai_service;

Future<void> voiceAiSpeakText(VoiceAiService self, String text) async {
  try {
    await self._tts.stop();
    await self._tts.setLanguage('vi-VN');
    await self._tts.setSpeechRate(0.42);
    await self._tts.setPitch(0.98);
    await self._tts.setVolume(1.0);

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

    await self._tts.speak(text);

    try {
      await completer.future.timeout(
        Duration(seconds: max(5, (text.length ~/ 15) + 1)),
      );
    } catch (_) {}
  } catch (e) {
    if (kDebugMode) debugPrint('AIService TTS error: $e');
  }
}

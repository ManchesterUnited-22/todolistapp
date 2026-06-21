// Singleton STT (Speech-To-Text) service.
//
// IMPORTANT: this wraps a single shared `speech_to_text` instance that is
// initialized only once and reused for every listen session in the app.
//
// Why this matters: each `VoiceInputDialog` / `_VoiceAnswerDialog` used to
// create its OWN `stt.SpeechToText()` and call `initialize()` + `listen()`
// from scratch every time it opened. That works for the very first question
// in a flow, but when the app immediately opens a follow-up dialog (e.g. to
// ask for a missing field), the native speech recognizer on the previous
// session often hasn't fully released the microphone yet. The new session
// then silently fails to capture audio — `isListening` still flips to
// `true` and the UI keeps animating, but `onResult` never fires, which
// looks exactly like "mic vẫn on nhưng AI không nghe được".
//
// Reusing one instance + waiting briefly before re-listening fixes that.
library;

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';

class SttService {
  SttService._();
  static final SttService instance = SttService._();

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _pluginReady = false;
  String lastError = '';

  bool get isListening => _speech.isListening;

  Future<bool> _ensureInitialized({
    required void Function(String status) onStatus,
    required void Function(String message) onError,
  }) async {
    if (_pluginReady) return true;

    _pluginReady = await _speech.initialize(
      onStatus: onStatus,
      onError: (SpeechRecognitionError e) {
        lastError = '${e.errorMsg}${e.permanent ? ' (permanent)' : ''}';
        onError(lastError);
        // Only force a re-init on permanent errors; transient ones
        // (e.g. timeout/busy) shouldn't nuke an otherwise-working plugin.
        if (e.permanent) _pluginReady = false;
      },
    );
    return _pluginReady;
  }

  /// Starts (or restarts) a listening session.
  ///
  /// Safe to call back-to-back from multiple dialogs in the same flow —
  /// it stops any in-flight session and waits briefly before requesting
  /// the mic again so the native recognizer has time to release it
  /// (this also covers the moment right after TTS finishes speaking).
  Future<bool> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(String status) onStatus = _noopStatus,
    void Function(String message) onError = _noopError,
    String localeId = 'vi_VN',
    Duration pauseFor = const Duration(seconds: 3),
    Duration listenFor = const Duration(seconds: 30),
    stt.ListenMode listenMode = stt.ListenMode.confirmation,
  }) async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    final ready = await _ensureInitialized(onStatus: onStatus, onError: onError);
    if (!ready) return false;

    // Give the native audio session (mic and/or just-finished TTS) a brief
    // moment to fully release before requesting it again.
    await Future.delayed(const Duration(milliseconds: 350));

    await _speech.listen(
      localeId: localeId,
      listenMode: listenMode,
      pauseFor: pauseFor,
      listenFor: listenFor,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) _speech.stop();
      },
    );
    return true;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }

  static void _noopStatus(String _) {}
  static void _noopError(String _) {}
}
// Skeleton STT (Speech-To-Text) service.
// Implement actual STT using a platform plugin (e.g., `speech_to_text`) and
// wire into the UI where needed. This file provides a minimal API to start
///stop listening and expose the latest transcript.
library;

import 'dart:async';

class SttService {
  SttService._();
  static final SttService instance = SttService._();

  // Whether the service is currently listening.
  bool _listening = false;
  bool get isListening => _listening;

  // Latest partial/complete transcript.
  String transcript = '';

  // Callbacks for updates.
  final StreamController<String> _onTranscript = StreamController.broadcast();
  Stream<String> get onTranscript => _onTranscript.stream;

  /// Initialize the STT backend. Actual implementation should initialize the
  /// chosen plugin and request microphone permissions.
  Future<void> initialize() async {
    // TODO: integrate `speech_to_text` or another STT SDK.
    return;
  }

  /// Start listening and stream transcriptions to `onTranscript`.
  Future<void> startListening() async {
    _listening = true;
    // TODO: start plugin listening and push interim/final results.
  }

  /// Stop listening.
  Future<void> stopListening() async {
    _listening = false;
    // TODO: stop plugin listening.
  }

  void dispose() {
    _onTranscript.close();
  }
}

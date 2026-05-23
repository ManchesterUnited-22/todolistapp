import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Dialog widget that records short voice input and returns the recognized text.
class VoiceInputDialog extends StatefulWidget {
  final String prompt;
  const VoiceInputDialog({required this.prompt, super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _spokenText = '';
  bool _isListening = false;
  bool _isReady = false;
  bool _isFinal = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    if (_starting || _isListening) return;
    _starting = true;
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!available) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
      _isListening = true;
      _starting = false;
    });

    _speech.listen(
      localeId: 'vi_VN',
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _spokenText = result.recognizedWords;
          _isFinal = result.finalResult;
          if (result.finalResult) _isListening = false;
        });
        if (result.finalResult) _speech.stop();
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.prompt),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _spokenText.isEmpty ? (_isListening ? 'Đang nghe...' : 'Chờ ghi âm') : _spokenText,
              style: const TextStyle(fontSize: 14, color: Color(0xFF191C1E)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isReady ? 'Mic đã sẵn sàng, bạn có thể nói' : 'Đang khởi tạo mic...',
            style: const TextStyle(fontSize: 11, color: Color(0xFF767586)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _stopListening();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            if (_isListening) {
              await _stopListening();
            } else {
              await _startListening();
            }
          },
          icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_none_rounded),
          label: Text(_isListening ? 'Dừng ghi âm' : 'Nghe lại'),
        ),
        FilledButton.icon(
          onPressed: _spokenText.trim().isEmpty && !_isFinal ? null : () async {
            await _stopListening();
            if (context.mounted) Navigator.of(context).pop(_spokenText.trim());
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

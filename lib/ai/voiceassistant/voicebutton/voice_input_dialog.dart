import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Dialog widget that records short voice input and returns the recognized text.
class VoiceInputDialog extends StatefulWidget {
  final String prompt;
  const VoiceInputDialog({required this.prompt, super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  late final AnimationController _pulseController;
  String _spokenText = '';
  bool _isListening = false;
  bool _isReady = false;
  bool _isFinal = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    if (_starting || _isListening) return;
    _starting = true;
    if (mounted) setState(() {});
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
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.prompt),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VoiceWaveCard(
            pulse: _pulseController,
            isReady: _isReady,
            isListening: _isListening,
            isStarting: _starting,
            spokenText: _spokenText,
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

class _VoiceWaveCard extends StatelessWidget {
  final Animation<double> pulse;
  final bool isReady;
  final bool isListening;
  final bool isStarting;
  final String spokenText;

  const _VoiceWaveCard({
    required this.pulse,
    required this.isReady,
    required this.isListening,
    required this.isStarting,
    required this.spokenText,
  });

  @override
  Widget build(BuildContext context) {
    final status = spokenText.isNotEmpty
        ? spokenText
        : (isStarting
            ? 'Đang khởi tạo mic...'
            : isListening
                ? 'Đang nghe...'
                : 'Chờ ghi âm');

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final t = pulse.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _MicPulse(
                    progress: AlwaysStoppedAnimation<double>(t),
                    active: isStarting || isListening,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        status,
                        key: ValueKey<String>(status),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF191C1E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (index) {
                    final wave = (t + index * 0.18) % 1.0;
                    final heightFactor = isStarting || isListening
                        ? (0.25 + (0.75 * (1 - (wave - 0.5).abs() * 2).clamp(0.0, 1.0)))
                        : 0.25;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 6,
                        height: 32 * heightFactor,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4648D4).withValues(
                            alpha: (0.35 + 0.55 * heightFactor).clamp(0.0, 1.0),
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isReady ? 'Mic đã sẵn sàng, bạn có thể nói' : 'Đang khởi tạo mic...',
                style: const TextStyle(fontSize: 11, color: Color(0xFF767586)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MicPulse extends StatelessWidget {
  final Animation<double> progress;
  final bool active;

  const _MicPulse({required this.progress, required this.active});

  @override
  Widget build(BuildContext context) {
    final scale = active ? 1.0 + (progress.value * 0.12) : 1.0;
    final glow = active ? 0.12 + (progress.value * 0.12) : 0.08;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF4648D4).withValues(alpha: 0.12),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4648D4).withValues(alpha: glow),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Color(0xFF4648D4), size: 22),
      ),
    );
  }
}

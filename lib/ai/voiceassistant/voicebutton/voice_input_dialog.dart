import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputDialog extends StatefulWidget {
  final String prompt;
  final bool longListen;

  const VoiceInputDialog({
    required this.prompt,
    this.longListen = false,
    super.key,
  });

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();

  // 28 thanh sóng, mỗi cái controller riêng để chạy ngẫu nhiên
  late final List<AnimationController> _barControllers;
  late final List<Animation<double>> _barAnimations;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  String _spokenText = '';
  bool _isListening = false;
  bool _isReady    = false;
  bool _isFinal    = false;
  bool _starting   = false;

  static const int    _barCount = 28;
  static const Color  _accent   = Color(0xFF4648D4);

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _barControllers = List.generate(_barCount, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + rng.nextInt(500)),
    ));
    _barAnimations = _barControllers
        .map((c) => Tween<double>(begin: 0.08, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  void _startWave() {
    for (var i = 0; i < _barCount; i++) {
      Future.delayed(Duration(milliseconds: i * 15), () {
        if (mounted) _barControllers[i].repeat(reverse: true);
      });
    }
  }

  void _stopWave() {
    for (final c in _barControllers) {
      c.animateTo(0.08, duration: const Duration(milliseconds: 400));
    }
  }

  Future<void> _startListening() async {
    if (_starting || _isListening) return;
    _starting = true;
    if (mounted) setState(() {});
    final available = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) { setState(() => _isListening = false); _stopWave(); }
        }
      },
      onError: (_) { if (mounted) Navigator.of(context).pop(); },
    );
    if (!available) { if (mounted) Navigator.of(context).pop(); return; }
    if (!mounted) return;
    setState(() { _isReady = true; _isListening = true; _starting = false; });
    _startWave();

    _speech.listen(
      localeId: 'vi_VN',
      listenMode: widget.longListen ? stt.ListenMode.dictation : stt.ListenMode.confirmation,
      pauseFor: widget.longListen ? const Duration(seconds: 5) : const Duration(seconds: 2),
      onResult: (r) {
        if (!mounted) return;
        setState(() {
          _spokenText = r.recognizedWords;
          _isFinal    = r.finalResult;
          if (r.finalResult) { _isListening = false; _stopWave(); }
        });
        if (r.finalResult) _speech.stop();
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) { setState(() => _isListening = false); _stopWave(); }
  }

  @override
  void dispose() {
    for (final c in _barControllers) c.dispose();
    _glowController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _starting || _isListening;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Prompt ──────────────────────────────────────────────────────
            Text(
              widget.prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // ── Mic với vòng sáng ───────────────────────────────────────────
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) {
                final g = active ? _glowAnim.value : 0.0;
                return Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withValues(alpha: 0.06 * g),
                    ),
                  ),
                  Container(
                    width: 62, height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withValues(alpha: active ? 0.10 + 0.06 * g : 0.07),
                    ),
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? _accent : const Color(0xFFF0F0FA),
                      boxShadow: active ? [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.30 * g),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ] : [],
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: active ? Colors.white : _accent,
                      size: 22,
                    ),
                  ),
                ]);
              },
            ),
            const SizedBox(height: 22),

            // ── Sóng âm 28 thanh ─────────────────────────────────────────
            SizedBox(
              height: 44,
              child: AnimatedBuilder(
                animation: Listenable.merge(_barAnimations),
                builder: (_, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_barCount, (i) {
                    final h = _barAnimations[i].value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.8),
                      child: Container(
                        width: 3,
                        height: 44 * h.clamp(0.08, 1.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: _accent.withValues(
                            alpha: active
                                ? (0.25 + 0.65 * h).clamp(0.0, 1.0)
                                : 0.15,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Transcript ─────────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_spokenText.isEmpty ? '_empty' : _spokenText),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active
                        ? _accent.withValues(alpha: 0.30)
                        : const Color(0xFFE4E3F0),
                  ),
                ),
                child: Text(
                  _spokenText.isNotEmpty
                      ? _spokenText
                      : _starting
                          ? 'Đang khởi động mic...'
                          : active
                              ? 'Đang lắng nghe...'
                              : 'Nhấn "Nghe lại" để thử',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: _spokenText.isNotEmpty
                        ? const Color(0xFF191C1E)
                        : const Color(0xFF9896AA),
                    fontStyle: _spokenText.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // ── Nút ──────────────────────────────────────────────────────
            Row(children: [
              TextButton(
                onPressed: () async {
                  await _stopListening();
                  if (context.mounted) Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF9896AA)),
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (_isListening) {
                      await _stopListening();
                    } else {
                      setState(() { _spokenText = ''; _isFinal = false; });
                      await _startListening();
                    }
                  },
                  icon: Icon(
                    _isListening ? Icons.stop_rounded : Icons.refresh_rounded,
                    size: 16,
                  ),
                  label: Text(_isListening ? 'Dừng' : 'Nghe lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: const BorderSide(color: Color(0xFFD0CFEE)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _spokenText.trim().isEmpty && !_isFinal
                      ? null
                      : () async {
                          await _stopListening();
                          if (context.mounted) Navigator.of(context).pop(_spokenText.trim());
                        },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Xác nhận'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.25),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
} 
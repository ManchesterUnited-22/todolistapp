import 'package:flutter/material.dart';

class VoiceTaskButton extends StatefulWidget {
  final Future<void> Function(String) onVoiceResult;
  const VoiceTaskButton({super.key, required this.onVoiceResult});

  @override
  State<VoiceTaskButton> createState() => _VoiceTaskButtonState();
}

class _VoiceTaskButtonState extends State<VoiceTaskButton>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isDisposed = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  Future<void> _openVoiceAssistant() async {
    if (_isDisposed || _isProcessing) return;
    if (!mounted) return;

    setState(() => _isProcessing = true);
    _pulseController.repeat(reverse: true);

    try {
      await widget.onVoiceResult('');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã mở trợ lý giọng nói')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xử lý giọng nói: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openVoiceAssistant,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isProcessing
                      ? const Color(0xFF7AA9FF)
                      : const Color(0xFF4EA2FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF4C56D6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C56D6).withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              Icon(
                _isProcessing ? Icons.hourglass_top_rounded : Icons.mic_rounded,
                color: const Color(0xFF111827),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isProcessing)
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.35).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
        FloatingActionButton(
          onPressed: _openVoiceAssistant,
          backgroundColor: _isProcessing ? Colors.red : Colors.blue,
          child: Icon(_isProcessing ? Icons.hourglass_top : Icons.mic_none),
        ),
      ],
    );
  }
}

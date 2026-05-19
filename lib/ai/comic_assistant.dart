import 'dart:async';

import 'package:flutter/material.dart';

/// A comic-style assistant bubble with avatar and typewriter text effect.
class ComicAssistant extends StatefulWidget {
  final String text;
  final Duration charDelay;
  final VoidCallback? onFinished;
  final Alignment alignment;

  const ComicAssistant({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 40),
    this.onFinished,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  State<ComicAssistant> createState() => _ComicAssistantState();
}

class _ComicAssistantState extends State<ComicAssistant> {
  late String _visible = '';
  Timer? _timer;
  int _pos = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _timer?.cancel();
    _visible = '';
    _pos = 0;
    _timer = Timer.periodic(widget.charDelay, (t) {
      if (!mounted) return;
      setState(() {
        _pos++;
        if (_pos <= widget.text.length) {
          _visible = widget.text.substring(0, _pos);
        } else {
          t.cancel();
          widget.onFinished?.call();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant ComicAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTypewriter();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Text(_visible, style: const TextStyle(fontSize: 16, height: 1.3)),
    );

    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bubble with tail
            Stack(
              clipBehavior: Clip.none,
              children: [
                bubble,
                Positioned(
                  left: -10,
                  bottom: -6,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Container(
                      width: 18,
                      height: 18,
                      color: Colors.white,
                      transform: Matrix4.rotationZ(-0.6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

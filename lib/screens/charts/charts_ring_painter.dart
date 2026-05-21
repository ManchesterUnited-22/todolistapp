import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'charts_colors.dart';

class ChartsRingPainter extends CustomPainter {
  final double value;

  const ChartsRingPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 4;

    final trackPaint = Paint()
      ..color = ChartsColors.secondary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final fillPaint = Paint()
      ..color = ChartsColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * value.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(ChartsRingPainter old) => old.value != value;
}

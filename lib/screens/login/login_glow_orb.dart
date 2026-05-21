import 'dart:ui';
import 'package:flutter/material.dart';

class LoginGlowOrb extends StatelessWidget {
  const LoginGlowOrb({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: const SizedBox.expand(),
      ),
    );
  }
}

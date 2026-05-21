import 'package:flutter/material.dart';

class RegisterGlowOrb extends StatelessWidget {
  const RegisterGlowOrb({super.key, required this.size, required this.color});

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
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)],
      ),
    );
  }
}

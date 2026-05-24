import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import '../login/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Nền gradient giống code 1 ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F9FF), Color(0xFFE1E0FF)],
              ),
            ),
          ),

          // ── Blob top-left giống code 1 ──
          Positioned(
            top: -size.height * 0.10,
            left: -size.width * 0.10,
            child: Container(
              width: size.width * 0.40,
              height: size.width * 0.40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4648D4).withValues(alpha: 0.10),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Blob bottom-right giống code 1 ──
          Positioned(
            bottom: -size.height * 0.10,
            right: -size.width * 0.10,
            child: Container(
              width: size.width * 0.50,
              height: size.width * 0.50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF39B8FD).withValues(alpha: 0.10),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Content ──
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 40,
                      ),
                      decoration: BoxDecoration(
                        // glass-card: rgba(255,255,255,0.7)
                        color: Colors.white.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4648D4).withValues(alpha: 0.05),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Logo section ──
                          const _LoginLogo(),
                          const SizedBox(height: 12),
                          // ── App name ──
                          const Text(
                            'Serene Focus',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4648D4),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // ── Welcome text ──
                          const Text(
                            'Chào mừng trở lại!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy cùng hoàn thành các mục tiêu hôm nay nhé.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: const Color(0xFF767586).withValues(alpha: 0.80),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // ── Form (logic giữ nguyên) ──
                          const LoginForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4648D4), Color(0xFF39B8FD)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4648D4).withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // rotate(3deg) giống code 1
      child: Transform.rotate(
        angle: 0.052,
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 32,
          shadows: [
            Shadow(color: Colors.white24, blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
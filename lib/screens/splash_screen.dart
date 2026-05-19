import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Glassmorphic decorative blobs ──────────────────────────────

          // Top-left blob (primary/5)
          Positioned(
            top: -size.width * 0.15,
            left: -size.width * 0.2,
            child: _GlassBlob(
              diameter: size.width * 0.72,
              color: AppColors.brand.withValues(alpha: 0.05),
              blurSigma: 120,
            ),
          ),

          // Mid-right blob (primary/4)
          Positioned(
            top: size.height * 0.25,
            right: -size.width * 0.18,
            child: _GlassBlob(
              diameter: size.width * 0.48,
              color: AppColors.brand.withValues(alpha: 0.04),
              blurSigma: 100,
            ),
          ),

          // Bottom-right blob (secondary-container/10)
          Positioned(
            bottom: -size.width * 0.22,
            right: -size.width * 0.1,
            child: _GlassBlob(
              diameter: size.width * 0.96,
              color: AppColors.info.withValues(alpha: 0.06),
              blurSigma: 100,
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo icon (matches HTML gradient icon) ──
                            _LogoIcon(),

                            const SizedBox(height: 32),

                            // ── App title ──
                            Text(
                              'Serene Focus',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── Subtitle ──
                            Text(
                              'Elevated productivity for the modern professional.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Footer: loading state (kept from original code 2) ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 64),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Loading dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LoadingDot(opacity: 0.3),
                              const SizedBox(width: 4),
                              _LoadingDot(opacity: 0.6),
                              const SizedBox(width: 4),
                              _LoadingDot(opacity: 1.0),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ĐANG TẢI...',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets ─────────────────────────────────────────────────────────────

/// Gradient logo icon that mirrors the HTML `brand-icon-gradient` + rotated
/// layer design.
class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4648D4), Color(0xFF6063EE)],
    );

    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4648D4).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Back rotated tile (+12°)
          Transform.rotate(
            angle: 12 * 3.14159 / 180,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: gradient,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
          ),

          // Middle rotated tile (-6°)
          Transform.rotate(
            angle: -6 * 3.14159 / 180,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: gradient,
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withValues(alpha: 0.60),
              ),
            ),
          ),

          // Front tile (upright) with icon
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4648D4).withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.filter_vintage_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blurred circular blob for glassmorphic background decoration.
class _GlassBlob extends StatelessWidget {
  const _GlassBlob({
    required this.diameter,
    required this.color,
    required this.blurSigma,
  });

  final double diameter;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Single animated loading dot.
class _LoadingDot extends StatelessWidget {
  const _LoadingDot({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFF4648D4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
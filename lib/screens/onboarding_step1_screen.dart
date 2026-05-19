import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/onboarding_step2_screen.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          // ── Background decorative blobs ─────────────────────────────
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.64,
              height: size.width * 0.64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC0C1FF).withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.05,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4E3FF).withValues(alpha: 0.30),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              // ── Progress indicator ──────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 6,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.brand,
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 6,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.18),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 6,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.18),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // ── Illustration section ────────────────
                              SizedBox(
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Animated outer ring
                                      AnimatedBuilder(
                                        animation: _pulseAnim,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _pulseAnim.value,
                                            child: child,
                                          );
                                        },
                                        child: Container(
                                          width: 260,
                                          height: 260,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.brand
                                                  .withValues(alpha: 0.10),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Mid ring
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brand
                                                .withValues(alpha: 0.20),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      // Inner ring
                                      Container(
                                        width: 136,
                                        height: 136,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brand
                                                .withValues(alpha: 0.40),
                                            width: 1,
                                          ),
                                        ),
                                      ),

                                      // Main image + floating badge
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            children: [
                                              // Rounded-rect image
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                child: Image.network(
                                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAN05ZhpLVBwx1Ddy7UkjsT6Ubse02n8r-bV67vg1uybLS459ZXVoM__iuIk9Py1_b9G8ICttScu6YmVjUGc4grQP6n57k45qlgLYqy9MnlW5XscvH_A_dSNkxFqR0c3HKPr1-lkcoowvUIh5uMl4oichAegxgPpKcOouRch5cRnY-7Ds405c3HeoOedgNVwYPSg4wk0O6SskI-_4tl-AliQ1__9pfRDXYroDgG7OO1JogxeOmXdLkAHkigrBDO32eiYYCFERp82kA',
                                                  width: 288,
                                                  height: 288,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                          error,
                                                          stackTrace) =>
                                                      Container(
                                                    width: 288,
                                                    height: 288,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.brand
                                                          .withValues(
                                                              alpha: 0.08),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .center_focus_strong_outlined,
                                                      color: AppColors.brand,
                                                      size: 64,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Floating badge at bottom
                                              Positioned(
                                                bottom: -16,
                                                child: _FloatingBadge(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              // ── Text content ────────────────────────
                              Text(
                                'Welcome to Serene Focus',
                                textAlign: TextAlign.center,
                                style:
                                    theme.textTheme.headlineLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 280,
                                child: Text(
                                  'Organize your life with ease',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.65,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom action section ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        // Next button (full-width gradient pill)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4648D4),
                                  Color(0xFF6063EE),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OnboardingStep2Screen(),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.01 * 14,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Skip button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MainDashboardScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Skip onboarding',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Step indicator text
                        Text(
                          'Step 1 of 3',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.60),
                            letterSpacing: 0.03 * 12,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
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

// ── Subwidgets ──────────────────────────────────────────────────────────────

/// Glassmorphic floating badge shown below the illustration image.
class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.center_focus_strong_rounded,
              color: AppColors.brand,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Precision Tracking',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
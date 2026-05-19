import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/onboarding_step3_screen.dart';

class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // ── Header: "Serene Focus" branding ─────────────────
                  Text(
                    'Serene Focus',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Bento glass card illustration ───────────────────
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _BentoIllustrationCard(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Text content ────────────────────────────────────
                  Text(
                    'Smart Task Management',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 280,
                    child: Text(
                      'Prioritize what matters most to you',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Progress dots (inactive • active • inactive) ────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProgressDot(active: false),
                      const SizedBox(width: 8),
                      _ProgressDot(active: true),
                      const SizedBox(width: 8),
                      _ProgressDot(active: false),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Bottom nav: Back ←→ Next FAB ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: Text(
                          'Back',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Next FAB gradient button
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF4648D4), Color(0xFF6063EE)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand.withValues(alpha: 0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const OnboardingStep3Screen(),
                              ),
                            );
                          },
                          label: const Icon(Icons.arrow_forward, size: 20),
                          icon: Text(
                            'Next',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bento glass card with image + floating chips ────────────────────────────

class _BentoIllustrationCard extends StatelessWidget {
  const _BentoIllustrationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative corner blobs inside card
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4E3FF).withValues(alpha: 0.30),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE1E0FF).withValues(alpha: 0.20),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rounded-rect image
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBMh1C_Vxcp4ItFZwSfOI4LnO0GdrfJUOCXFdfOYtrQXDWpp9r7rSoKPvllVTpOto8T8ELZQr3E_DqTDdSIsbEiC55FV0xb7Hf9lxUnaS3LqHxjTqIOCxatUIsxSYRkB4A0T5nLKJiIS8Kua8Erg8YSQGDdNx1vZVS8UbnY2MvH5lwanbhpBq1wglJ9O7wpcuJH9Yg2foO2_iplzoOOn8SShlnyu9cAwYEQOS_N_eKZROR55zRm4qgOkkgXN7jtzJX5AFs5Gdp83LQ',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: BoxDecoration(
                              color:
                                  AppColors.brand.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              color: AppColors.brand,
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Floating chips row
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        _FloatingChip(
                          icon: Icons.priority_high_rounded,
                          label: 'High Priority',
                          color: const Color(0xFF0060AC),
                          bgColor: const Color(0xFF64A8FE).withValues(alpha: 0.10),
                        ),
                        _FloatingChip(
                          icon: Icons.done_all_rounded,
                          label: 'Done',
                          color: const Color(0xFF006C49),
                          bgColor: const Color(0xFF00885D).withValues(alpha: 0.10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subwidgets ──────────────────────────────────────────────────────────────

/// Pill chip with icon + label, matches HTML `rounded-full` chips.
class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Progress dot: active = wide pill brand color, inactive = small grey circle.
class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? AppColors.brand
            : const Color(0xFFC7C4D7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
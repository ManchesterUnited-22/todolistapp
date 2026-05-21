import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/onboarding_step2_screen.dart';
import 'widgets/onboarding_step1_footer.dart';
import 'widgets/onboarding_floating_badge.dart';

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
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 6,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.brand,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 6,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    height: 6,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _pulseAnim,
                                        builder: (context, child) {
                                          return Transform.scale(scale: _pulseAnim.value, child: child);
                                        },
                                        child: Container(
                                          width: 260,
                                          height: 260,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.brand.withValues(alpha: 0.10),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brand.withValues(alpha: 0.20),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 136,
                                        height: 136,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brand.withValues(alpha: 0.40),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(24),
                                                child: Image.network(
                                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAN05ZhpLVBwx1Ddy7UkjsT6Ubse02n8r-bV67vg1uybLS459ZXVoM__iuIk9Py1_b9G8ICttScu6YmVjUGc4grQP6n57k45qlgLYqy9MnlW5XscvH_A_dSNkxFqR0c3HKPr1-lkcoowvUIh5uMl4oichAegxgPpKcOouRch5cRnY-7Ds405c3HeoOedgNVwYPSg4wk0O6SskI-_4tl-AliQ1__9pfRDXYroDgG7OO1JogxeOmXdLkAHkigrBDO32eiYYCFERp82kA',
                                                  width: 288,
                                                  height: 288,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 288,
                                                    height: 288,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.brand.withValues(alpha: 0.08),
                                                      borderRadius: BorderRadius.circular(24),
                                                    ),
                                                    child: Icon(
                                                      Icons.center_focus_strong_outlined,
                                                      color: AppColors.brand,
                                                      size: 64,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Positioned(bottom: -16, child: OnboardingFloatingBadge()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                              Text(
                                'Welcome to Serene Focus',
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
                OnboardingStep1Footer(theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
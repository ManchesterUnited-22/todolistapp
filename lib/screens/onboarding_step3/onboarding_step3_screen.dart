import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'widgets/onboarding_step3_analytics_card.dart';
import 'widgets/onboarding_step3_footer.dart';

class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: OnboardingStep3Colors.background,
      body: Stack(
        children: [
          Positioned(
            top: -size.height * 0.10,
            right: -size.width * 0.05,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OnboardingStep3Colors.primaryFixed.withValues(alpha: 0.40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.10,
            left: -size.width * 0.05,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OnboardingStep3Colors.secondaryFixed.withValues(alpha: 0.40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Serene Focus',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: OnboardingStep3Colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        const OnboardingStep3AnalyticsCard(),
                        const SizedBox(height: 32),
                        Text(
                          'Track Your Progress',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: OnboardingStep3Colors.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 280,
                          child: Text(
                            'Stay motivated with detailed performance stats and celebrate your daily productivity milestones.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: OnboardingStep3Colors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                OnboardingStep3Footer(theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep3Colors {
  static const Color primary = Color(0xFF4648D4);
  static const Color primaryContainer = Color(0xFF6063EE);
  static const Color background = Color(0xFFF7F9FB);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF464554);
  static const Color outlineVariant = Color(0xFFC7C4D7);
  static const Color secondaryFixed = Color(0xFFD4E3FF);
  static const Color primaryFixed = Color(0xFFE1E0FF);
}
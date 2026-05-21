import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/onboarding_step3_screen.dart';
import 'widgets/onboarding_step2_footer.dart';
import 'widgets/onboarding_step2_illustration_card.dart';

class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Text(
                    'Serene Focus',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: OnboardingStep2IllustrationCard(),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      OnboardingStep2ProgressDot(active: false),
                      SizedBox(width: 8),
                      OnboardingStep2ProgressDot(active: true),
                      SizedBox(width: 8),
                      OnboardingStep2ProgressDot(active: false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OnboardingStep2Footer(theme: theme),
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
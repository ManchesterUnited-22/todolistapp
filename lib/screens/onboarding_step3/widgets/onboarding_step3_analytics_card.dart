import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/screens/onboarding_step3/onboarding_step3_screen.dart';

class OnboardingStep3AnalyticsCard extends StatelessWidget {
  const OnboardingStep3AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
            boxShadow: [
              BoxShadow(
                color: OnboardingStep3Colors.primary.withValues(alpha: 0.08),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -24,
                left: -24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OnboardingStep3Colors.secondaryFixed.withValues(alpha: 0.30),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6FFBBE).withValues(alpha: 0.20),
                  ),
                ),
              ),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCgbcxkNC8ToB6r_Zq0ecHIHfonwKZ4HoDifNZpUy3rs5NoaMThgsshhjtV_xEx6KdO3-olkrOqtpoi75WaeZ-Wt-WpimfHyyx611emF-QAPUaEyB_iu4lOBmN9dmxzRwUQJtApXsJoYaW4Ve3gHxKw-LnpURPV3LWwittI1U7kCkJzm1IhtOy4K9UYaGBlH7U3F_-fFWHIJdgeTLmiR42c9VC41C0pvmq_OFHbXV_r6DFNu7NAyH_UbZ07nvi9KxkhkXAGHE87UHY',
                      width: double.infinity,
                      height: 192,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 192,
                        decoration: BoxDecoration(
                          color: OnboardingStep3Colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: OnboardingStep3Colors.primary,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: OnboardingStep3Colors.primaryContainer.withValues(alpha: 0.10),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: OnboardingStep3Colors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECEEF0),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.75,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: OnboardingStep3Colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Focus Progress',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: OnboardingStep3Colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '75%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: OnboardingStep3Colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
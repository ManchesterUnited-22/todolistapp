import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/onboarding_step3_screen.dart';
import 'widgets/onboarding_step2_footer.dart';
import 'widgets/onboarding_step2_illustration_card.dart';

class OnboardingStep2Screen extends StatelessWidget {
  const OnboardingStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: Stack(
        children: [
          // Deco circle top-right
          Positioned(
            top: -size.height * 0.08,
            right: -size.width * 0.12,
            child: Container(
              width: size.width * 0.78,
              height: size.width * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8E9FF).withValues(alpha: 0.55),
              ),
            ),
          ),
          // Deco circle bottom-left
          Positioned(
            bottom: -size.height * 0.12,
            left: -size.width * 0.10,
            child: Container(
              width: size.width * 0.74,
              height: size.width * 0.74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F5FF).withValues(alpha: 0.95),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 28),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Serene Focus',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainDashboardScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Illustration card
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glass card background
                              Container(
                                width: size.width * 0.72,
                                height: size.width * 0.72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.70),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: AppColors.brand.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                              ),

                              // Main image
                              SizedBox(
                                width: size.width * 0.60,
                                height: size.width * 0.60,
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBzE7R4lf9O8y-FE60SWmNgF84Wp4Az7vGrUVH1ZGBhv-afdI_M2_Bpgsz5WS0cWT5mFoBptn8_1UOq0qCS9K09jcAMVotTMrShmyVDazmBcYipLz7095zMdvxfHPFBPUIYN0y4oti9yEX6V7P1s33XBqOiAa552fMh8kCiv0SS57tZyxUKtj1vxeI0eWNz3jQvWOi7tMk6RXiwhB22imywVFwX86FvtrF3Zti0IxzCZmu_PIyK0uoGI1MVkZLkQQLEaEmJNBGJpj8',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          Icons.mic_none_outlined,
                                          color: AppColors.brand,
                                          size: 72,
                                        ),
                                      ),
                                ),
                              ),

                              // Floating mic badge — top right
                              Positioned(
                                top: 36,
                                right: 36,
                                child: _GlassBadge(
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Icon(
                                    Icons.mic_none_outlined,
                                    color: Color(0xFF8127CF),
                                    size: 22,
                                  ),
                                ),
                              ),

                              // Floating clock badge — bottom left
                              Positioned(
                                bottom: 44,
                                left: 28,
                                child: _GlassBadge(
                                  borderRadius: BorderRadius.circular(99),
                                  child: const Icon(
                                    Icons.schedule_outlined,
                                    color: Color(0xFF4648D4),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Headline
                      Text(
                        'Thêm Nhiệm vụ Dễ dàng',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtext
                      SizedBox(
                        width: 290,
                        child: Text(
                          'Không còn phải gõ phím mệt mỏi. Chỉ cần nhấn mic và nói, chúng tôi sẽ tự động lên lịch cho bạn.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.65,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress dots — dot 2 active
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

                      const SizedBox(height: 24),

                      OnboardingStep2Footer(theme: theme),

                      const SizedBox(height: 4),
                    ],
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

/// Glass-morphism floating badge widget
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
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
          // Deco blob top-right (primary/5)
          Positioned(
            top: -size.height * 0.10,
            right: -size.width * 0.05,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OnboardingStep3Colors.primaryFixed.withValues(
                  alpha: 0.40,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          // Deco blob bottom-left (secondary/5)
          Positioned(
            bottom: -size.height * 0.10,
            left: -size.width * 0.05,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OnboardingStep3Colors.secondaryFixed.withValues(
                  alpha: 0.40,
                ),
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
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 16, 0),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Serene Focus',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: OnboardingStep3Colors.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainDashboardScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              OnboardingStep3Colors.onSurfaceVariant,
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

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        // Hero illustration — plain image like HTML (no analytics card)
                        SizedBox(
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Soft ambient pulse ring behind image
                                Container(
                                  width: size.width * 0.72,
                                  height: size.width * 0.72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: OnboardingStep3Colors.primaryFixed
                                        .withValues(alpha: 0.18),
                                  ),
                                ),
                                // Main illustration image
                                SizedBox(
                                  width: size.width * 0.72,
                                  height: size.width * 0.72,
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDFjZfa5okta-yTEnMVJ-msXx6xfbzRQ5lPbJRYPd84zWS0gtORp8qRpSH1cXorLxZBrkpxRYUkuVIvXdvXWNk4Lo3MEtCFtfbALN4L6jecIf-9umDm89DG5hQyrVXQqvz_7mrzvjd_tibZFpE_wGoO-SqEiW50-xPvsmtHasnsEuJSh0InY_WzkJWdlgYa4Flnfk4_HbwzIeg51ib4w_pUBPssDrdlUzm0ytmXM1ekdTmRtRAcFGjPthek7vYgT9te0pT7PSuTrn8',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Icon(
                                            Icons.bar_chart_outlined,
                                            color:
                                                OnboardingStep3Colors.primary,
                                            size: 72,
                                          ),
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
                          'Phân tích & Thống kê',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: OnboardingStep3Colors.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtext
                        SizedBox(
                          width: 290,
                          child: Text(
                            'Theo dõi tiến độ công việc với các báo cáo chi tiết và biểu đồ trực quan, giúp bạn tối ưu hoá năng suất mỗi ngày.',
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

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    OnboardingStep3ProgressDot(active: false),
                    SizedBox(width: 8),
                    OnboardingStep3ProgressDot(active: false),
                    SizedBox(width: 8),
                    OnboardingStep3ProgressDot(active: true),
                  ],
                ),
                const SizedBox(height: 24),
                // Footer with CTA only
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
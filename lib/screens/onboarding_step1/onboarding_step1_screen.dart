import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/onboarding_step2/onboarding_step2_screen.dart';

class OnboardingStep1Screen extends StatefulWidget {
  const OnboardingStep1Screen({super.key});

  @override
  State<OnboardingStep1Screen> createState() => _OnboardingStep1ScreenState();
}

class _OnboardingStep1ScreenState extends State<OnboardingStep1Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 0,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Navigation
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.brand,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Serene Focus',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const MainDashboardScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.brand,
                              ),
                              child: const Text('Skip'),
                            ),
                          ],
                        ),
                      ),

                      // Main content — expands to fill available height
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                // Hero Image Section — matches HTML design
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: _HeroImageSection(
                                    floatAnimation: _floatAnimation,
                                  ),
                                ),

                                const SizedBox(height: 48),

                                // Title
                                Text(
                                  'Tích hợp Giọng nói AI',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.9,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Description
                                SizedBox(
                                  width: 340,
                                  child: Text(
                                    'Trải nghiệm cách tương tác hoàn toàn mới với trợ lý ảo thông minh, giúp bạn quản lý công việc chỉ bằng lời nói.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.65,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 48),

                                // Progress Dots
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
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.textSecondary.withValues(
                                          alpha: 0.25,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 6,
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.textSecondary.withValues(
                                          alpha: 0.25,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 48),

                                // CTA — match onboarding step 2 style
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Color(0xFF4648D4), Color(0xFF6063EE)],
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.brand.withValues(alpha: 0.30),
                                          blurRadius: 20,
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
                                            builder: (context) => const OnboardingStep2Screen(),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Tiếp tục',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Bước 1 trên 3',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.72),
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hero image section with floating animation and glassmorphism badges.
/// Matches the HTML design: network image, ambient glow, mic badge top-right,
/// auto_awesome badge bottom-left.
class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection({required this.floatAnimation});

  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient radial glow behind the image
        Positioned.fill(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.75,
              heightFactor: 0.75,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brand.withValues(alpha: 0.18),
                      AppColors.brand.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating hero image
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: AnimatedBuilder(
              animation: floatAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, floatAnimation.value),
                child: child,
              ),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDRqUBQYdwp-r2UCvs4dvZkASDpuAYlHV7M_G1fPZ9XnUg5QcFCBzXYMaOTMR_myByPXxvnk7zMmYc4Sf_byDlL-o2szdmjBP80DLSzpWoGfArSiKknNm3U3Jl0Y-QvUa6GIgNF2VjH5F544_qoOwEoBD7ZYxYWj2m4cb-n3NiUsx240k8FSQ8wpLE4M76X16Kt_SZ9c8UjhNHFJRRfC0UPObAOXstoC38huVz8IAF_GOx5NErFWZ_kAavZnL7Uetr_qBgrAx5xB98',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const _FallbackHeroArtwork(),
              ),
            ),
          ),
        ),

        // Glass badge — top right: mic icon
        Positioned(
          top: 32,
          right: 32,
          child: _GlassBadge(
            child: Icon(Icons.mic_rounded, color: AppColors.brand, size: 22),
          ),
        ),

        // Glass badge — bottom left: auto_awesome icon
        Positioned(
          bottom: 72,
          left: 32,
          child: _GlassBadge(
            size: 44,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.brand,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

/// Glassmorphism circular badge.
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child, this.size = 52});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.70),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

/// Fallback artwork shown when network image fails to load.
/// Reuses the original gradient orb design.
class _FallbackHeroArtwork extends StatelessWidget {
  const _FallbackHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.18),
          radius: 0.58,
          colors: const [
            Color(0xCCF6FFFF),
            Color(0xCCB27DFF),
            Color(0xB46F48D9),
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
      ),
      child: const Center(
        child: Icon(Icons.mic_rounded, color: Colors.white, size: 64),
      ),
    );
  }
}
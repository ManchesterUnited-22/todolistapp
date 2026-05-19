import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';

class OnboardingStep3Screen extends StatelessWidget {
  const OnboardingStep3Screen({super.key});

  static const Color _primary = Color(0xFF4648D4);
  static const Color _primaryContainer = Color(0xFF6063EE);
  static const Color _background = Color(0xFFF7F9FB);
  static const Color _onSurface = Color(0xFF191C1E);
  static const Color _onSurfaceVariant = Color(0xFF464554);
  static const Color _outlineVariant = Color(0xFFC7C4D7);
  static const Color _secondaryFixed = Color(0xFFD4E3FF);
  static const Color _primaryFixed = Color(0xFFE1E0FF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          // ── Fixed background decoration blobs ──────────────────────
          Positioned(
            top: -size.height * 0.10,
            right: -size.width * 0.05,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryFixed.withValues(alpha: 0.40),
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
                color: _secondaryFixed.withValues(alpha: 0.40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Header branding ─────────────────────────────────
                Center(
                  child: Text(
                    'Serene Focus',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // ── Visual + text (scrollable middle) ───────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        // Illustration glass card
                        _AnalyticsCard(),

                        const SizedBox(height: 32),

                        // Text content
                        Text(
                          'Track Your Progress',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: _onSurface,
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
                              color: _onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer action area ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Progress dots — step 3 active
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProgressDot(active: false),
                          const SizedBox(width: 8),
                          _ProgressDot(active: false),
                          const SizedBox(width: 8),
                          _ProgressDot(active: true),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Get Started gradient pill button
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
                                color: _primary.withValues(alpha: 0.25),
                                blurRadius: 24,
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
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MainDashboardScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'GET STARTED',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Analytics glass card ────────────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard();

  static const Color _primary = Color(0xFF4648D4);
  static const Color _primaryContainer = Color(0xFF6063EE);
  static const Color _onSurfaceVariant = Color(0xFF464554);
  static const Color _secondaryFixed = Color(0xFFD4E3FF);
  static const Color _tertiaryFixed = Color(0xFF6FFBBE);

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
                color: _primary.withValues(alpha: 0.08),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner decorative blobs
              Positioned(
                top: -24,
                left: -24,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _secondaryFixed.withValues(alpha: 0.30),
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
                    color: _tertiaryFixed.withValues(alpha: 0.20),
                  ),
                ),
              ),

              Column(
                children: [
                  // Main illustration image
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
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: _primary,
                          size: 64,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress row: icon + bar + label
                  Row(
                    children: [
                      // Insights icon in circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryContainer.withValues(alpha: 0.10),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: _primary,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Progress bar + labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Track
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                children: [
                                  // Background track
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECEEF0),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  // Fill (75%)
                                  FractionallySizedBox(
                                    widthFactor: 0.75,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Labels row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Focus Progress',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '75%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _primary,
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

// ── Progress dot ────────────────────────────────────────────────────────────

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
        color: active ? const Color(0xFF4648D4) : const Color(0xFFC7C4D7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

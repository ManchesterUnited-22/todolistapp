import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/login_screen.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Aurora/Nebula Background
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.brand.withOpacity(0.15), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.brand.withOpacity(0.1), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Central Success Emblem
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 192,
                          height: 192,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withOpacity(0.3),
                                  blurRadius: 50,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                                BoxShadow(
                                  color: AppColors.brand.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: AppColors.brand,
                              size: 90,
                              shadows: [
                                Shadow(
                                  color: AppColors.brand.withOpacity(0.5),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Glow Rings
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.brand.withOpacity(0.2), width: 2),
                              shape: BoxShape.circle,
                            ),
                        ),
                        Container(
                          width: 288,
                          height: 288,
                            decoration: BoxDecoration(
                            border: Border.all(color: AppColors.brand.withOpacity(0.08), width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Success Text Content
                    Text(
                      'Voyage Authorized',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, Voyager. Your celestial workspace is ready. We have aligned the stars for your peak performance.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Transitional Action / Visual Anchor
                    Column(
                      children: [
                        Container(
                          width: 2,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x9900dbe9), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'INITIALIZING',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0x6600dbe9),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contextual Aesthetic Elements
          Positioned(
            bottom: 48,
            left: 48,
            child: MediaQuery.of(context).size.width > 900 ? Opacity(
              opacity: 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Biometric match', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.brand)),
                                const Text('ID: AUR-992-DELTA', style: TextStyle(fontSize: 10, color: Colors.white54)),
                              ],
                            ),
                          ],
                        ),
              ),
            ) : const SizedBox.shrink(),
          ),
          Positioned(
            top: 48,
            right: 48,
            child: MediaQuery.of(context).size.width > 900 ? Opacity(
              opacity: 0.3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_done, color: AppColors.brand),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Neural sync', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.brand)),
                        Text('Stable connection', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ],
                ),
              ),
            ) : const SizedBox.shrink(),
          ),
          // Floating Particle System Mock
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brand.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 1)],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            right: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.brand.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 2)],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.5,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF7df4ff).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(blurRadius: 1)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


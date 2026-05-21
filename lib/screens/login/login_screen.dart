import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import '../login/widgets/login_form.dart';
import '../login/login_glow_orb.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            child: LoginGlowOrb(size: size.width * 0.8, color: AppColors.brand.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.1,
            child: LoginGlowOrb(size: size.width * 0.8, color: AppColors.info.withValues(alpha: 0.08)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.brand.withValues(alpha: 0.20), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chào mừng trở lại!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy cùng hoàn thành các mục tiêu hôm nay nhé.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),
                    const LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

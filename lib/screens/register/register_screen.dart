import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import '../register/widgets/register_form.dart';
import '../register/widgets/register_social_button.dart';
import '../register/register_glow_orb.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            child: RegisterGlowOrb(size: size.width * 0.6, color: AppColors.brand.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.1,
            child: RegisterGlowOrb(size: size.width * 0.6, color: AppColors.brand.withValues(alpha: 0.04)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.15, -0.45),
                    radius: 1.2,
                    colors: [AppColors.brand.withValues(alpha: 0.05), AppColors.background],
                  ),
                ),
              ),
            ),
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
                        gradient: const LinearGradient(colors: [AppColors.brand, AppColors.info]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: AppColors.brand.withValues(alpha: 0.24), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: const Icon(Icons.task_alt, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bắt đầu hành trình',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sắp xếp cuộc sống một cách thanh thản.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: const RegisterForm(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.16), thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Hoặc', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.16), thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(
                          child: RegisterSocialButton(
                            iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKxJtwhgLu_0wH-JVdz0om2ZLDGFCsJ8XN0TwdouqrBcwveKL8oofanJ7yN0QVuUwCVzmkB5-z4TKTxwr44v7DOJD64xPm5RfAc9U1rE14d8EzEriXj04RFoU2aCZvl3C-aXoGS7pGL0UUtDn61NTMFrVcNS0nlFiQVJBTAOf6qNwAP6I9K1qs2eGM91bFjnKxsOymg9TOiOSi_z3bhT54Yj1m-cp7g6Npe6bG4izhXwCr954sAzSZR7WaE40nHgMMHeLuzqIIngg',
                            label: 'Google',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: RegisterSocialButton(
                            icon: Icon(Icons.apple, size: 20, color: AppColors.textPrimary),
                            label: 'Apple',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Bạn đã có tài khoản? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Đăng nhập',
                                style: theme.textTheme.labelMedium?.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: AppColors.brand),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

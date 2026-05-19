import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/services/auth.dart';
import 'package:smart_app/views/register_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_app/screens/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: _GlowOrb(size: MediaQuery.of(context).size.width * 0.6, color: AppColors.brand.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: _GlowOrb(size: MediaQuery.of(context).size.width * 0.6, color: AppColors.brand.withValues(alpha: 0.04)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.15, -0.45),
                    radius: 1.2,
                    colors: [
                      AppColors.brand.withValues(alpha: 0.05),
                      AppColors.background,
                    ],
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
                        gradient: const LinearGradient(
                          colors: [AppColors.brand, AppColors.info],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.24),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.task_alt, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bắt đầu hành trình',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sắp xếp cuộc sống một cách thanh thản.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: _RegisterForm(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.16), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Hoặc',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.textSecondary.withValues(alpha: 0.16), thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(
                          child: _SocialButton(
                            iconUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKxJtwhgLu_0wH-JVdz0om2ZLDGFCsJ8XN0TwdouqrBcwveKL8oofanJ7yN0QVuUwCVzmkB5-z4TKTxwr44v7DOJD64xPm5RfAc9U1rE14d8EzEriXj04RFoU2aCZvl3C-aXoGS7pGL0UUtDn61NTMFrVcNS0nlFiQVJBTAOf6qNwAP6I9K1qs2eGM91bFjnKxsOymg9TOiOSi_z3bhT54Yj1m-cp7g6Npe6bG4izhXwCr954sAzSZR7WaE40nHgMMHeLuzqIIngg',
                            label: 'Google',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
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
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.brand,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.brand,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerViewModel = RegisterViewModel(
        uid: '',
        name: _fullNameController.text,
        displayName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      await _authService.registerUser(
        registerViewModel,
      );

      if (!mounted) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/success.json', height: 100),
              const SizedBox(height: 16),
              Text('Account initialized', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth ${error.code}: ${error.message ?? 'Registration failed.'}')),
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message ?? error.code;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase ${error.plugin}: $message')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().isNotEmpty ? error.toString() : 'Registration failed. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Họ và tên', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fullNameController,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }

              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              hintText: 'Nguyễn Văn A',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5),
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Email', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Vui lòng nhập email';
              }

              if (!text.contains('@')) {
                return 'Vui lòng nhập email hợp lệ';
              }

              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textSecondary),
              hintText: 'email@vi-du.com',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5),
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Mật khẩu', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            obscureText: _obscure1,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }

              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }

              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
              hintText: '••••••••',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5),
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Xác nhận mật khẩu', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            obscureText: _obscure2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }

              if (value != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }

              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.verified_user_outlined, color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
              hintText: '••••••••',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5),
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
              shadowColor: AppColors.brand.withValues(alpha: 0.25),
            ),
            onPressed: _isLoading ? null : _handleRegister,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 120, spreadRadius: 20),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({this.icon, this.iconUrl, required this.label});

  final Widget? icon;
  final String? iconUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: Colors.white.withValues(alpha: 0.72),
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconUrl != null)
                    Image.network(iconUrl!, width: 20, height: 20)
                  else
                    icon!,
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


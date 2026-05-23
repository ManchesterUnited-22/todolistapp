import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/onboarding_step1_screen.dart';
import 'package:smart_app/services/auth.dart';
import 'package:smart_app/views/login_viewmodel.dart';
import 'login_social_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (!mounted) return;
      final user = credential.user;
      if (user != null) {
        await _authService.saveLoginRecord(
          LoginViewModel(
            uid: user.uid,
            email: user.email ?? _emailController.text.trim(),
            password: '',
            provider: 'google',
          ),
        );
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OnboardingStep1Screen()));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: $error')));
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.loginUser(
        LoginViewModel(
          uid: '',
          email: _emailController.text.trim(),
          password: _passwordController.text,
          provider: 'email_password',
        ),
      );
      if (!mounted) return;
      if (credential.user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OnboardingStep1Screen()));
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sai thông tin đăng nhập: ${error.message ?? error.code}')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Email', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Vui lòng nhập email';
              if (!text.contains('@')) return 'Vui lòng nhập email hợp lệ';
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textSecondary),
              hintText: 'example@gmail.com',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mật khẩu', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Quên mật khẩu?', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.brand, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textSecondary),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              hintText: '••••••••',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              shadowColor: AppColors.brand.withValues(alpha: 0.30),
            ).copyWith(
              elevation: WidgetStateProperty.all(0),
              overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
            ),
            onPressed: _isLoading ? null : _handleEmailLogin,
            child: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                : const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: LoginSocialButton(
                  text: 'Google',
                  icon: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAvMRrpsB93lZG8ak3-cnzD2jpE7DN0MPaOrlYwz76Ngj72iXBZKGKzoeb_gplIM-AA2jDZZ97RrTQiIhfYPNkFJqou53mz0tjBcQnLuE_NvQWOerV3_dKE8wJqYidcPIHeqtSFpjnP9uEa5m_GSkKV_jyQ-Ccw_b24C7ZgVGz8AJCxwtMAxYpoin7KTPYpvS-98O0tSm7aym52Eh5CagU3B_1NJfTo3Og0ru7VYUbYhmMjeozCU-OdL2xUoJYlYys56rIdZAlsXWs',
                    width: 18,
                    height: 18,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  onPressed: _handleGoogleLogin,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LoginSocialButton(
                  text: 'Email',
                  icon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textPrimary),
                  onPressed: _handleEmailLogin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

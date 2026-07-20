import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/screens/main_dashboard_screen.dart';
import 'package:smart_app/screens/register_screen.dart';
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
    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (!mounted) return;
      final user = credential.user;
      if (user != null) {
        await _authService.saveLoginRecord(
          LoginViewModel(
            uid: user.uid,
            email: user.email ?? '',
            password: '',
            provider: 'google',
          ),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sai thông tin đăng nhập: ${error.message ?? error.code}')),
      );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Email',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Vui lòng nhập email';
                  if (!text.contains('@')) return 'Vui lòng nhập email hợp lệ';
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF7B7C91)),
                  hintText: 'example@gmail.com',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: const Color(0xFFE8E8F4), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: const Color(0xFFE8E8F4), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.34), width: 1.4),
                  ),
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFBCC0D0)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mật khẩu',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Quên mật khẩu?',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF7B7C91)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Color(0xFF7B7C91)),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  hintText: '••••••••',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: const Color(0xFFE8E8F4), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: const Color(0xFFE8E8F4), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.34), width: 1.4),
                  ),
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFBCC0D0)),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF5059E8), Color(0xFF49A8F8)],
                  ).colors.first,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                  shadowColor: const Color(0xFF4F65FF).withValues(alpha: 0.28),
                ).copyWith(
                  elevation: WidgetStateProperty.all(0),
                  overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.08)),
                ),
                onPressed: _isLoading ? null : () => _handleEmailLogin(),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                    : const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: const Color(0xFFE2E4F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'HOẶC',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF7C8094),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: const Color(0xFFE2E4F0))),
                ],
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
        LoginSocialButton(
          text: 'Tiếp tục với Google',
          icon: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.g_mobiledata_rounded, size: 20, color: Colors.white),
          ),
          onPressed: _isLoading ? null : () => _handleGoogleLogin(),
        ),
        const SizedBox(height: 28),
        Center(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF4B5563), height: 1.3),
              children: [
                const TextSpan(text: 'Chưa có tài khoản? '),
                TextSpan(
                  text: 'Đăng ký ngay',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/services/auth.dart';
import 'package:smart_app/views/register_viewmodel.dart';
import 'package:smart_app/screens/login_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final registerViewModel = RegisterViewModel(
        uid: '',
        name: _fullNameController.text,
        displayName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      await _authService.registerUser(registerViewModel);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/success.json', height: 100),
              const SizedBox(height: 16),
              const Text('Account initialized', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth ${error.code}: ${error.message ?? 'Registration failed.'}')),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      final message = error.message ?? error.code;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase ${error.plugin}: $message')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().isNotEmpty ? error.toString() : 'Registration failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              hintText: 'Nguyễn Văn A',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
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
              if (text.isEmpty) return 'Vui lòng nhập email';
              if (!text.contains('@')) return 'Vui lòng nhập email hợp lệ';
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textSecondary),
              hintText: 'email@vi-du.com',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
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
              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
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
              if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (value != _passwordController.text) return 'Mật khẩu không khớp';
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: AppColors.brand.withValues(alpha: 0.22), width: 1.5)),
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
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

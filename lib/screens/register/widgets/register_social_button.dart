import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';

class RegisterSocialButton extends StatelessWidget {
  const RegisterSocialButton({super.key, this.icon, this.iconUrl, required this.label});

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

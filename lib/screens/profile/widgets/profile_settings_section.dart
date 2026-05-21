import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../widgets/edit_profile_form.dart';
import '../profile_colors.dart';
import 'profile_theme_setting_row.dart';

class ProfileSettingsSection extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const ProfileSettingsSection({super.key, required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'CÀI ĐẶT TÀI KHOẢN',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: ProfileColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingRow(
                context: context,
                icon: Icons.person_outline_rounded,
                iconBg: ProfileColors.primaryContainer,
                iconColor: ProfileColors.onPrimary,
                label: 'Chỉnh sửa hồ sơ',
                isFirst: true,
                isLast: false,
                onTap: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                  if (uid.isEmpty) return;
                  final results = await Future.wait([
                    FirebaseFirestore.instance.collection('register').doc(uid).get(),
                    FirebaseFirestore.instance.collection('users').doc(uid).get(),
                  ]);
                  final merged = {
                    ...results[0].data() ?? {},
                    ...results[1].data() ?? {},
                  };
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => EditProfileForm(initialData: merged),
                    );
                  }
                },
              ),
              Divider(height: 1, color: ProfileColors.surfaceContainerHigh),
              const ProfileThemeSettingRow(),
              Divider(height: 1, color: ProfileColors.surfaceContainerHigh),
              _buildSettingRow(
                context: context,
                icon: Icons.security_outlined,
                iconBg: ProfileColors.tertiaryContainer,
                iconColor: Colors.white,
                label: 'Bảo mật',
                isFirst: false,
                isLast: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onLogoutTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ProfileColors.errorContainer.withOpacity(0.20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ProfileColors.error.withOpacity(0.10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout_rounded, color: ProfileColors.error),
                  SizedBox(width: 8),
                  Text(
                    'Đăng xuất tài khoản',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(16) : Radius.zero,
      bottom: isLast ? const Radius.circular(16) : Radius.zero,
    );
    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ProfileColors.outline),
          ],
        ),
      ),
    );
  }
}

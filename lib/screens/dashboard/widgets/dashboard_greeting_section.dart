import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dashboard_colors.dart';

class DashboardGreetingSection extends StatelessWidget {
  final String userUid;

  const DashboardGreetingSection({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: userUid.isEmpty ? null : FirebaseFirestore.instance.collection('register').doc(userUid).snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  final regName = (data?['displayName'] as String?)?.trim();
                  final googleName = FirebaseAuth.instance.currentUser?.displayName?.trim();
                  final displayName = (regName != null && regName.isNotEmpty)
                      ? regName
                      : (googleName != null && googleName.isNotEmpty)
                          ? googleName
                          : 'User';

                  return RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.5),
                      children: [
                        const TextSpan(text: 'Chào, ', style: TextStyle(color: DashboardColors.onSurface)),
                        TextSpan(text: displayName, style: const TextStyle(color: DashboardColors.primary, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              const Text(
                'Hôm nay bạn muốn hoàn thành điều gì?',
                style: TextStyle(fontSize: 16, color: DashboardColors.outline, fontWeight: FontWeight.w500, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.light_mode_outlined, color: DashboardColors.primary, size: 26),
        ),
      ],
    );
  }
}

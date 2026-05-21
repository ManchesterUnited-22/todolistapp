import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../profile_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ProfileColors.primary.withOpacity(0.25),
                    ProfileColors.secondary.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                    .snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data() as Map<String, dynamic>?;
                  final avatarUrl = (data?['avatarUrl'] as String?)?.trim() ?? '';
                  if (avatarUrl.isNotEmpty) {
                    return Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _DefaultAvatar(),
                    );
                  }
                  return const _DefaultAvatar();
                },
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: ProfileColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: ProfileColors.onPrimary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('register')
              .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final displayName =
                (data?['fullName'] as String?)?.trim().isNotEmpty == true
                ? data!['fullName'] as String
                : (FirebaseAuth.instance.currentUser?.displayName ?? 'Tên người dùng');
            final email = (data?['email'] as String?)?.trim().isNotEmpty == true
                ? data!['email'] as String
                : (FirebaseAuth.instance.currentUser?.email ?? 'email@example.com');

            return Column(
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.48,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ProfileColors.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'AN';
    return Container(
      color: ProfileColors.primaryFixed,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: ProfileColors.primary,
          ),
        ),
      ),
    );
  }
}

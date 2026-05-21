library sidebar;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/avatar_service.dart';
import '../services/task_notification_service.dart';

part 'sidebar/sidebar_parts.dart';

// ── Colour tokens (shared, import from app_colors nếu cần) ───────────────────
class _C {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const surfaceContainerHigh = Color(0xFFE6E8EA);
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const secondary = Color(0xFF0060AC);
  static const tertiary = Color(0xFF006C49);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const outline = Color(0xFF767586);
  static const outlineVariant = Color(0xFFC7C4D7);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
}

// ── Public sidebar widget ─────────────────────────────────────────────────────

class DashboardSidebar extends StatelessWidget {
  /// Callback khi bấm "Edit Profile"
  final VoidCallback? onEditProfile;

  /// Callback khi bấm "Đăng xuất"
  final VoidCallback? onLogout;

  /// Callback khi bấm "Ngôn ngữ"
  final VoidCallback? onLanguage;

  /// Avatar URL (mặc định dùng ảnh placeholder)
  final String? avatarUrl;

  /// Tên người dùng
  final String userName;

  /// Nhãn dán đang được chọn để highlight.
  final String? selectedTag;

  /// Callback khi người dùng chọn nhãn dán.
  final ValueChanged<String?>? onTagSelected;

  /// Callback khi bấm vào mục Tất cả công việc.
  final VoidCallback? onDashboardTap;

  /// Callback khi bấm vào mục Lịch.
  final VoidCallback? onCalendarTap;

  /// Callback khi bấm vào mục Thống kê.
  final VoidCallback? onChartsTap;

  /// Màn hình hiện tại để highlight menu chính.
  final String? currentPage;

  const DashboardSidebar({
    super.key,
    this.onEditProfile,
    this.onLogout,
    this.onLanguage,
    this.avatarUrl,
    this.userName = 'User Name',
    this.selectedTag,
    this.onTagSelected,
    this.onDashboardTap,
    this.onCalendarTap,
    this.onChartsTap,
    this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: _C.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildNavList(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  // ── Header: avatar + tên + edit profile ────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: _C.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _C.primaryFixed, width: 2),
            ),
            child: GestureDetector(
              onTap: () async {
                await AvatarService.pickAndUploadAvatarToCloudinary(context);
              },
              child: ClipOval(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                      .snapshots(),
                  builder: (context, snap) {
                    final data = snap.data?.data() as Map<String, dynamic>?;
                    final src =
                        (data != null &&
                            (data['avatarUrl'] as String?)?.trim().isNotEmpty ==
                                true)
                        ? data['avatarUrl'] as String
                        : avatarUrl;

                    if (src == null || src.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Image.network(
                      src,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('register')
                      .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final displayName =
                        (data != null &&
                            (data['displayName'] as String?)
                                    ?.trim()
                                    .isNotEmpty ==
                                true)
                        ? data['displayName'] as String
                        : (FirebaseAuth.instance.currentUser?.displayName ??
                              userName);
                    final email =
                        (data != null &&
                            (data['email'] as String?)?.trim().isNotEmpty ==
                                true)
                        ? data['email'] as String
                        : (FirebaseAuth.instance.currentUser?.email ?? '');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: _C.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            color: _C.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: onEditProfile,
                          child: const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav list: menu chính + nhãn dán + tính năng ────────────────────────────
  Widget _buildNavList(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return _buildNavListContent(this, context, const {});
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final counts = _groupTaskCounts(snapshot.data?.docs ?? const []);
        return _buildNavListContent(this, context, counts);
      },
    );
  }

  // ── Footer: ngôn ngữ + đăng xuất ──────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _C.outlineVariant.withValues(alpha: 0.3)),
        ),
        color: _C.surfaceContainerLow.withValues(alpha: 0.5),
      ),
    );
  }
}

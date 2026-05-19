import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/avatar_service.dart';
import '../services/task_notification_service.dart';

// ── Colour tokens (shared, import from app_colors nếu cần) ───────────────────
class _C {
  static const background           = Color(0xFFF7F9FB);
  static const surface              = Color(0xFFFFFFFF);
  static const surfaceContainer     = Color(0xFFECEEF0);
  static const surfaceContainerLow  = Color(0xFFF2F4F6);
  static const surfaceContainerHigh = Color(0xFFE6E8EA);
  static const primary              = Color(0xFF4648D4);
  static const primaryContainer     = Color(0xFF6063EE);
  static const primaryFixed         = Color(0xFFE1E0FF);
  static const secondary            = Color(0xFF0060AC);
  static const tertiary             = Color(0xFF006C49);
  static const onSurface            = Color(0xFF191C1E);
  static const onSurfaceVariant     = Color(0xFF464554);
  static const outline              = Color(0xFF767586);
  static const outlineVariant       = Color(0xFFC7C4D7);
  static const error                = Color(0xFFBA1A1A);
  static const errorContainer       = Color(0xFFFFDAD6);
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
                    final src = (data != null && (data['avatarUrl'] as String?)?.trim().isNotEmpty == true)
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
                    final displayName = (data != null && (data['displayName'] as String?)?.trim().isNotEmpty == true)
                      ? data['displayName'] as String
                      : (FirebaseAuth.instance.currentUser?.displayName ?? userName);
                    final email = (data != null && (data['email'] as String?)?.trim().isNotEmpty == true)
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
      return _buildNavListContent(context, const {});
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final counts = _groupTaskCounts(snapshot.data?.docs ?? const []);
        return _buildNavListContent(context, counts);
      },
    );
  }

  Widget _buildNavListContent(
    BuildContext context,
    Map<String, int> counts,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        // ── DANH MỤC CHÍNH ──
        const _SidebarSectionLabel('DANH MỤC CHÍNH'),
        _SidebarNavItem(
          icon: Icons.task_alt,
          label: 'Tất cả công việc',
          active: currentPage == 'dashboard',
          onTap: onDashboardTap ?? () => onTagSelected?.call(null),
        ),
        _SidebarNavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Lịch',
          active: currentPage == 'calendar',
          onTap: onCalendarTap ?? () => Navigator.of(context).pushNamed('/calendar'),
        ),
        _SidebarNavItem(
          icon: Icons.leaderboard_outlined,
          label: 'Thống kê',
          active: currentPage == 'stats',
          onTap: onChartsTap ?? () => Navigator.of(context).pushNamed('/stats'),
        ),

        const SizedBox(height: 8),

        // ── NHÃN DÁN ──
        const _SidebarSectionLabel('NHÃN DÁN'),
        _SidebarTagItem(
          color: _C.secondary,
          label: 'Công việc',
          count: '${counts['Công việc'] ?? 0}',
          selected: selectedTag == 'Công việc',
          onTap: () => onTagSelected?.call('Công việc'),
        ),
        _SidebarTagItem(
          color: _C.primaryContainer,
          label: 'Cá nhân',
          count: '${counts['Cá nhân'] ?? 0}',
          selected: selectedTag == 'Cá nhân',
          onTap: () => onTagSelected?.call('Cá nhân'),
        ),
        _SidebarTagItem(
          color: _C.error,
          label: 'Sức khỏe',
          count: '${counts['Sức khỏe'] ?? 0}',
          selected: selectedTag == 'Sức khỏe',
          onTap: () => onTagSelected?.call('Sức khỏe'),
        ),

        _SidebarTagItem(
          color: _C.outline,
          label: 'Tất cả',
          count: '${counts.values.fold<int>(0, (sum, value) => sum + value)}',
          selected: selectedTag == null,
          onTap: () => onTagSelected?.call(null),
        ),

        const SizedBox(height: 8),

        // ── TÍNH NĂNG ──
        const _SidebarSectionLabel('TÍNH NĂNG'),
        const _TaskNotificationToggle(),
      ],
    );
  }

  Map<String, int> _groupTaskCounts(Iterable<QueryDocumentSnapshot> docs) {
    final counts = <String, int>{
      'Công việc': 0,
      'Cá nhân': 0,
      'Sức khỏe': 0,
    };

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final category = (data?['category'] as String?)?.trim();
      if (category == null || category.isEmpty) {
        continue;
      }

      if (counts.containsKey(category)) {
        counts[category] = counts[category]! + 1;
      }
    }

    return counts;
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

class _TaskNotificationToggle extends StatefulWidget {
  const _TaskNotificationToggle();

  @override
  State<_TaskNotificationToggle> createState() => _TaskNotificationToggleState();
}

class _TaskNotificationToggleState extends State<_TaskNotificationToggle> {
  bool _enabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _syncState();
  }

  Future<void> _syncState() async {
    await TaskNotificationService.instance.initialize();
    if (!mounted) return;
    setState(() {
      _enabled = TaskNotificationService.instance.notificationsEnabled;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool value) async {
    setState(() {
      _enabled = value;
      _loading = true;
    });

    await TaskNotificationService.instance.setNotificationsEnabled(value);
    if (!value) {
      await TaskNotificationService.instance.clearAllNotifications();
    }

    if (!mounted) return;
    setState(() {
      _enabled = value;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : () => _setEnabled(!_enabled),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _enabled
              ? _C.error.withValues(alpha: 0.05)
              : _C.surfaceContainerHigh.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _enabled
                ? _C.error.withValues(alpha: 0.12)
                : _C.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: _enabled ? _C.error : _C.outline,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Thông báo task',
                style: TextStyle(
                  color: _C.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _loading ? 0.5 : 1,
              child: Switch.adaptive(
                value: _enabled,
                activeColor: _C.error,
                onChanged: _loading ? null : _setEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets nội bộ ─────────────────────────────────────────────────────

class _SidebarSectionLabel extends StatelessWidget {
  final String text;
  const _SidebarSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          text,
          style: const TextStyle(
            color: _C.outline,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? (active ? _C.primary : _C.onSurfaceVariant);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color:
            active ? _C.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: onTap ?? () {},
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: _C.primary.withValues(alpha: 0.05),
      ),
    );
  }
}

class _SidebarTagItem extends StatelessWidget {
  final Color color;
  final String label;
  final String count;
  final bool selected;
  final VoidCallback? onTap;
  const _SidebarTagItem({
    required this.color,
    required this.label,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: ListTile(
          dense: true,
          leading: _TagIcon(label: label, color: color, selected: selected),
          title: Text(
            label,
            style: TextStyle(
              color: selected ? _C.primary : _C.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Text(
            count,
            style: TextStyle(
              color: selected ? _C.primary : _C.outline,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          selected: selected,
          selectedTileColor: _C.primary.withValues(alpha: 0.08),
          hoverColor: _C.surfaceContainerHigh,
        ),
      );
}

class _TagIcon extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;

  const _TagIcon({required this.label, required this.color, required this.selected});

  IconData _iconForLabel() {
    switch (label) {
      case 'Công việc':
        return Icons.work_rounded;
      case 'Cá nhân':
        return Icons.person_rounded;
      case 'Sức khỏe':
        return Icons.favorite_rounded;
      case 'Tất cả':
        return Icons.list_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconForLabel(),
      size: 18,
      color: selected ? _C.primary : color,
    );
  }
}
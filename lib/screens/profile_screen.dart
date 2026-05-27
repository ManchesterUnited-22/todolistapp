import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../widgets/floating_bottom_navbar.dart';
import '../widgets/edit_profile_form.dart';
import '../screens/login_screen.dart';
import '../services/theme_service.dart';
import '../notifications/task_notification_bell.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const secondary = Color(0xFF0060AC);
  static const secondaryContainer = Color(0xFF64A8FE);
  static const tertiary = Color(0xFF006C49);
  static const tertiaryContainer = Color(0xFF00885D);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceContainerHigh = Color(0xFFE6E8EA);
  static const surfaceVariant = Color(0xFFE0E3E5);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const outline = Color(0xFF767586);
  static const outlineVariant = Color(0xFFC7C4D7);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

// ── Glass card decoration ─────────────────────────────────────────────────────
BoxDecoration _buildGlassCard(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.40),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.20 : 0.04),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ── Achievement model ─────────────────────────────────────────────────────────
class _Badge {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final bool locked;
  // Điều kiện mở khóa: field Firestore và giá trị tối thiểu
  final String unlockField;
  final int unlockThreshold;

  const _Badge({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.locked,
    required this.unlockField,
    required this.unlockThreshold,
  });
}

const _badges = [
  _Badge(
    icon: Icons.wb_sunny_rounded,
    label: 'Bình Minh',
    iconColor: _C.tertiary,
    bgColor: Color(0x1A006C49),
    locked: true,
    unlockField: 'earlyMorningSessions',
    unlockThreshold: 1,
  ),
  _Badge(
    icon: Icons.self_improvement_rounded,
    label: 'Tự tại',
    iconColor: _C.secondary,
    bgColor: Color(0x1A0060AC),
    locked: true,
    unlockField: 'focusStreakDays',
    unlockThreshold: 3,
  ),
  _Badge(
    icon: Icons.center_focus_strong_rounded,
    label: 'Tập Trung',
    iconColor: _C.primary,
    bgColor: Color(0x1A4648D4),
    locked: true,
    unlockField: 'totalFocusMinutes',
    unlockThreshold: 60,
  ),
  _Badge(
    icon: Icons.local_fire_department_rounded,
    label: 'Bền Bỉ',
    iconColor: Color(0xFFE65100),
    bgColor: Color(0x1AE65100),
    locked: true,
    unlockField: 'focusStreakDays',
    unlockThreshold: 7,
  ),
  _Badge(
    icon: Icons.military_tech_rounded,
    label: 'Trưởng Thành',
    iconColor: Color(0xFFB8860B),
    bgColor: Color(0x1AB8860B),
    locked: true,
    unlockField: 'tasksCompleted',
    unlockThreshold: 20,
  ),
  _Badge(
    icon: Icons.psychology_rounded,
    label: 'Thông tuệ',
    iconColor: Color(0xFF7B1FA2),
    bgColor: Color(0x1A7B1FA2),
    locked: true,
    unlockField: 'totalFocusMinutes',
    unlockThreshold: 600,
  ),
  _Badge(
    icon: Icons.nights_stay_rounded,
    label: 'Đêm Thâu Tĩnh Lặng',
    iconColor: Color(0xFF1565C0),
    bgColor: Color(0x1A1565C0),
    locked: true,
    unlockField: 'lateNightSessions',
    unlockThreshold: 5,
  ),
  _Badge(
    icon: Icons.emoji_events_rounded,
    label: 'Trọn vẹn',
    iconColor: Color(0xFFAD1457),
    bgColor: Color(0x1AAD1457),
    locked: true,
    unlockField: 'tasksCompleted',
    unlockThreshold: 100,
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;

  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 32),
            _SettingsSection(onLogoutTap: () => _handleLogout(context)),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const FloatingBottomNavBar(currentIndex: 3, showFab: false)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Hồ sơ',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _C.primary,
        ),
      ),
      actions: [
        TaskNotificationBellButton(
          userId: _currentUserUid,
          iconColor: _C.primary,
          badgeColor: _C.error,
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $error')));
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow halo
            Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _C.primary.withOpacity(0.25),
                    _C.secondary.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Avatar circle
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
                  final avatarFromProfile =
                    (data?['avatarUrl'] as String?)?.trim() ?? '';
                  final avatarFromAuth =
                    FirebaseAuth.instance.currentUser?.photoURL?.trim() ??
                    '';
                  final avatarUrl = avatarFromProfile.isNotEmpty
                    ? avatarFromProfile
                    : avatarFromAuth;
                  if (avatarUrl.isNotEmpty) {
                    return Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _DefaultAvatar(
                        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                      ),
                    );
                  }
                  return _DefaultAvatar(
                    uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                  );
                },
              ),
            ),
            // Camera button
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {}, // TODO: Edit avatar
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: _C.primary,
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
                    color: _C.onPrimary,
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
                : (FirebaseAuth.instance.currentUser?.displayName ??
                      'Tên người dùng');
            final email = (data?['email'] as String?)?.trim().isNotEmpty == true
                ? data!['email'] as String
                : (FirebaseAuth.instance.currentUser?.email ??
                      'email@example.com');

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
                    color: _C.onSurfaceVariant,
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
  final String uid;
  const _DefaultAvatar({required this.uid});

  @override
  Widget build(BuildContext context) {
    // Show initials from display name if available
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? '';
    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'AN';
    return Container(
      color: _C.primaryFixed,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: _C.primary,
          ),
        ),
      ),
    );
  }
}

// ── Achievements Section ──────────────────────────────────────────────────────
class _AchievementsSection extends StatelessWidget {
  final String userId;
  const _AchievementsSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'HUY HIỆU THÀNH TÍCH',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: _C.onSurfaceVariant,
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot>(
          stream: userId.isNotEmpty
              ? FirebaseFirestore.instance
                    .collection('achievements')
                    .doc(userId)
                    .snapshots()
              : null,
          builder: (context, snap) {
            final data = snap.data?.data() as Map<String, dynamic>? ?? {};
            return GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _badges.map((badge) {
                // Determine unlocked status from Firestore data
                final fieldVal =
                    (data[badge.unlockField] as num?)?.toInt() ?? 0;
                final isUnlocked =
                    !badge.locked || fieldVal >= badge.unlockThreshold;
                return _BadgeTile(badge: badge, isUnlocked: isUnlocked);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _BadgeTile extends StatefulWidget {
  final _Badge badge;
  final bool isUnlocked;

  const _BadgeTile({required this.badge, required this.isUnlocked});

  @override
  State<_BadgeTile> createState() => _BadgeTileState();
}

class _BadgeTileState extends State<_BadgeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _unlockController;

  _Badge get badge => widget.badge;

  @override
  void initState() {
    super.initState();
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isUnlocked) {
      _unlockController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _BadgeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isUnlocked && widget.isUnlocked) {
      _unlockController.forward(from: 0);
    } else if (!widget.isUnlocked) {
      _unlockController.value = 0;
    }
  }

  @override
  void dispose() {
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeInfo(context),
      child: AnimatedBuilder(
        animation: _unlockController,
        builder: (context, _) {
          final t = _unlockController.value;
          final unlockProgress = Curves.easeOutCubic.transform(t);
          final shake = math.sin(t * math.pi * 14) * (1 - t) * 4.0;
          final rotate = math.sin(t * math.pi * 10) * (1 - t) * 0.12;
          final iconFade = Curves.easeIn.transform(t.clamp(0.0, 1.0));
          final lockFade = 1 - Curves.easeOut.transform(t.clamp(0.0, 1.0));

          return AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: widget.isUnlocked ? 1.0 : 0.98,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.80),
                          badge.bgColor.withOpacity(0.30),
                        ],
                      )
                    : null,
                color: widget.isUnlocked
                    ? null
                    : Colors.white.withOpacity(0.24),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.isUnlocked
                      ? badge.bgColor.withOpacity(0.30)
                      : Colors.white.withOpacity(0.44),
                ),
                boxShadow: widget.isUnlocked
                    ? [
                        BoxShadow(
                          color: badge.iconColor.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(shake, 0),
                    child: Transform.rotate(
                      angle: rotate,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.isUnlocked
                              ? badge.iconColor.withOpacity(
                                  0.12 + 0.12 * unlockProgress,
                                )
                              : _C.surfaceVariant.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.isUnlocked
                                ? badge.iconColor.withOpacity(0.18)
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (widget.isUnlocked && t < 1)
                              Opacity(
                                opacity: (0.85 * (1 - iconFade)).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: CustomPaint(
                                  size: const Size(42, 42),
                                  painter: _CrackPainter(
                                    color: badge.iconColor.withOpacity(0.92),
                                    progress: unlockProgress,
                                  ),
                                ),
                              ),
                            Opacity(
                              opacity: widget.isUnlocked ? lockFade : 1.0,
                              child: Icon(
                                Icons.lock_outline_rounded,
                                color: _C.outline,
                                size: widget.isUnlocked ? 18 : 20,
                              ),
                            ),
                            Opacity(
                              opacity: widget.isUnlocked ? iconFade : 0.0,
                              child: Transform.scale(
                                scale: 0.82 + 0.18 * unlockProgress,
                                child: Icon(
                                  badge.icon,
                                  color: badge.iconColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: widget.isUnlocked
                          ? badge.iconColor
                          : _C.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBadgeInfo(BuildContext context) {
    final String conditionText = _unlockConditionText();
    final isUnlocked = widget.isUnlocked;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        actionsAlignment: MainAxisAlignment.center,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUnlocked)
                Lottie.asset(
                  'assets/animations/success.json',
                  width: 132,
                  height: 132,
                  repeat: false,
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _C.surfaceVariant.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: _C.outline,
                    size: 36,
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? badge.bgColor
                      : _C.surfaceVariant.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  badge.icon,
                  color: isUnlocked ? badge.iconColor : _C.outline,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _C.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUnlocked
                    ? 'Chúc mừng, bạn đã đạt được huy hiệu này!'
                    : 'Điều kiện mở khoá:\n$conditionText',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: isUnlocked ? _C.tertiary : _C.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Đóng',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: _C.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _unlockConditionText() {
    switch (badge.unlockField) {
      case 'earlyMorningSessions':
        return 'Hoàn thành ${badge.unlockThreshold} phiên tập trung buổi sáng (trước 8:00)';
      case 'focusStreakDays':
        return 'Duy trì streak ${badge.unlockThreshold} ngày liên tiếp';
      case 'totalFocusMinutes':
        final hours = badge.unlockThreshold ~/ 60;
        return 'Tích luỹ ${hours > 0 ? "$hours giờ" : "${badge.unlockThreshold} phút"} tập trung';
      case 'tasksCompleted':
        return 'Hoàn thành ${badge.unlockThreshold} nhiệm vụ';
      case 'lateNightSessions':
        return 'Hoàn thành ${badge.unlockThreshold} phiên tập trung buổi tối (sau 22:00)';
      default:
        return 'Hoàn thành ${badge.unlockThreshold} ${badge.unlockField}';
    }
  }
}

class _CrackPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _CrackPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = Curves.easeOut.transform((progress - 0.12).clamp(0.0, 1.0));
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(size.width * 0.25, size.height * 0.22)
      ..lineTo(size.width * 0.42, size.height * 0.36)
      ..lineTo(size.width * 0.34, size.height * 0.52)
      ..lineTo(size.width * 0.50, size.height * 0.63)
      ..lineTo(size.width * 0.58, size.height * 0.82);

    final path2 = Path()
      ..moveTo(size.width * 0.76, size.height * 0.22)
      ..lineTo(size.width * 0.60, size.height * 0.36)
      ..lineTo(size.width * 0.68, size.height * 0.52)
      ..lineTo(size.width * 0.50, size.height * 0.63)
      ..lineTo(size.width * 0.42, size.height * 0.82);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _CrackPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}

// ── Settings Section ──────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const _SettingsSection({required this.onLogoutTap});

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
              color: _C.onSurfaceVariant,
            ),
          ),
        ),
        // Settings card group — giống HTML: divide-y trong một card
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
              // Chỉnh sửa hồ sơ
              _buildSettingRow(
                context: context,
                icon: Icons.person_outline_rounded,
                iconBg: _C.primaryContainer,
                iconColor: _C.onPrimary,
                label: 'Chỉnh sửa hồ sơ',
                isFirst: true,
                isLast: false,
                onTap: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                  if (uid.isEmpty) return;
                  final results = await Future.wait([
                    FirebaseFirestore.instance
                        .collection('register')
                        .doc(uid)
                        .get(),
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get(),
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
              Divider(height: 1, color: _C.surfaceContainerHigh),
              // Giao diện — theme toggle
              const _ThemeSettingRow(),
              Divider(height: 1, color: _C.surfaceContainerHigh),
              // Đăng xuất
              _buildSettingRow(
                context: context,
                icon: Icons.logout_rounded,
                iconBg: _C.errorContainer,
                iconColor: _C.error,
                label: 'Đăng xuất tài khoản',
                isFirst: false,
                isLast: true,
                onTap: onLogoutTap,
              ),
            ],
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
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _C.outline),
          ],
        ),
      ),
    );
  }
}

// ── Theme setting row (reactive) ──────────────────────────────────────────────
class _ThemeSettingRow extends StatelessWidget {
  const _ThemeSettingRow();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _C.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: _C.onSurface,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giao diện',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isDark ? 'Chế độ tối' : 'Chế độ sáng',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _C.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle pill giống HTML
              GestureDetector(
                onTap: () => ThemeService.setMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? _C.onSurface : _C.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: isDark
                        ? Alignment.centerRight
                        : Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

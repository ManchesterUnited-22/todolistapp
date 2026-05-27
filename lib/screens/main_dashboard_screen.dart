import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_app/screens/dashboard/widgets/dashboard_top_bar.dart';
import '../widgets/floating_bottom_navbar.dart';
import '../services/timer_service.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/promodoro/promodoro_timer_sheet.dart';
import 'package:smart_app/notifications/task_notification_bell.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_button.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_handler.dart';
import '../views/task_viewmodel.dart';

import 'dashboard/widgets/dashboard_streak_card.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
class _C {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const primary = Color(0xFF4648D4);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const tertiary = Color(0xFF006C49);
  static const onSurface = Color(0xFF191C1E);
  static const outline = Color(0xFF767586);
  static const outlineVariant = Color(0xFFC7C4D7);
  static const onSurfaceVariant = Color(0xFF464554);
  static const error = Color(0xFFEF4444);
  static const errorContainer = Color(0xFFFFDAD6);
  static const surfaceVariant = Color(0xFFE0E3E5);
  static const secondary = Color(0xFF0060AC);
  static const secondaryContainer = Color(0xFF64A8FE);
}

class MainDashboardScreen extends StatefulWidget {
  final bool showBottomNav;

  const MainDashboardScreen({super.key, this.showBottomNav = true});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  static const String _dailyCleanupPrefsPrefix =
      'main_dashboard_daily_cleanup_last_';

  String? _selectedCategory;
  bool _dailyCleanupRunning = false;

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _runDailyTaskCleanupIfNeeded();
  }

  String _dateKey(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _isBeforeToday(DateTime value, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    return day.isBefore(today);
  }

  Future<void> _runDailyTaskCleanupIfNeeded() async {
    if (_dailyCleanupRunning) return;

    final uid = _currentUserUid;
    if (uid.isEmpty) return;

    _dailyCleanupRunning = true;
    try {
      final now = DateTime.now();
      final todayKey = _dateKey(now);
      final prefs = await SharedPreferences.getInstance();
      final prefKey = '$_dailyCleanupPrefsPrefix$uid';
      final lastRun = prefs.getString(prefKey);
      if (lastRun == todayKey) return;

      final snap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      var deleteCount = 0;

      for (final doc in snap.docs) {
        final task = TaskViewModel.fromMap(doc.data());

        final dueAt = task.dueAt?.toDate();
        final isOverdueFromPreviousDays =
            dueAt != null && _isBeforeToday(dueAt, now);

        DateTime? completionAnchor;
        if (task.stat == 'Hoàn thành') {
          completionAnchor =
              task.completedAt?.toDate() ??
              task.timestamp?.toDate() ??
              task.createdAt?.toDate();
        }
        final isCompletedFromPreviousDays =
            completionAnchor != null && _isBeforeToday(completionAnchor, now);

        final shouldDelete = isCompletedFromPreviousDays ||
            isOverdueFromPreviousDays ||
            (task.stat == 'Quá hạn' &&
                (dueAt == null || _isBeforeToday(dueAt, now)));

        if (shouldDelete) {
          batch.delete(doc.reference);
          deleteCount++;
        }
      }

      if (deleteCount > 0) {
        await batch.commit();
      }

      await prefs.setString(prefKey, todayKey);
    } catch (_) {
      // Keep home screen resilient; cleanup can retry next time.
    } finally {
      _dailyCleanupRunning = false;
    }
  }

  // ── Task Helpers ──────────────────────────────────────────────────────────
  bool _isTaskCompleted(TaskViewModel task) => task.stat == 'Hoàn thành';

  bool _isTaskOverdue(TaskViewModel task) {
    if (_isTaskCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return task.stat == 'Quá hạn';
    return dueAt.isBefore(DateTime.now());
  }

  Future<void> _toggleTaskStatus(
    String docId,
    TaskViewModel task,
    bool checked,
  ) async {
    final stat = checked
        ? 'Hoàn thành'
        : (_isTaskOverdue(task) ? 'Quá hạn' : 'Đang làm');
    final updates = <String, dynamic>{'stat': stat};
    if (checked) {
      updates['completedAt'] = FieldValue.serverTimestamp();
    } else {
      updates['completedAt'] = FieldValue.delete();
    }
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(docId)
        .update(updates);
  }

  Future<void> _deleteTask(String docId) async =>
      FirebaseFirestore.instance.collection('tasks').doc(docId).delete();

  String _taskSectionTitle() => _selectedCategory == null
      ? 'Danh sách việc làm'
      : 'Danh sách việc làm • $_selectedCategory';

  // ════════════════════════════════════════════════════════════════════════════
  // TOP BAR — premium glass style from code 2
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return DashboardTopBar(userUid: _currentUserUid);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GREETING SECTION — premium style from code 2, data from code 1
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildGreetingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.surfaceVariant.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _currentUserUid.isEmpty
                  ? null
                  : FirebaseFirestore.instance
                        .collection('register')
                        .doc(_currentUserUid)
                        .snapshots(),
                builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final regName = (data?['displayName'] as String?)?.trim();
                final googleName = FirebaseAuth.instance.currentUser?.displayName?.trim();
                final displayName = (regName != null && regName.isNotEmpty)
                  ? regName
                  : (googleName != null && googleName.isNotEmpty)
                    ? googleName
                    : 'User';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'XIN CHÀO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.outline.withValues(alpha: 0.85),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _C.onSurface,
                        letterSpacing: -0.8,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hôm nay bạn muốn hoàn thành điều gì?',
                      style: TextStyle(
                        fontSize: 13,
                        color: _C.outline,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          StreamBuilder<DocumentSnapshot>(
            stream: _currentUserUid.isEmpty
                ? null
                : FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUserUid)
                      .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final avatarFromProfile =
                  (userData?['avatarUrl'] as String?)?.trim() ?? '';
              final avatarFromAuth =
                  FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? '';
              final avatarUrl = avatarFromProfile.isNotEmpty
                  ? avatarFromProfile
                  : avatarFromAuth;

              return Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _C.primary.withValues(alpha: 0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _GreetingAvatarFallback(
                            name: FirebaseAuth.instance.currentUser?.displayName,
                          ),
                        )
                      : _GreetingAvatarFallback(
                          name: FirebaseAuth.instance.currentUser?.displayName,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PROGRESS CARD — premium circular ring from code 2, data from code 1
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildProgressCard() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: _currentUserUid)
        .snapshots(),
    builder: (context, snapshot) {
      final docs = snapshot.data?.docs ?? [];
      final total = docs.length;
      final completed = docs
          .where(
            (d) => (d.data() as Map<String, dynamic>)['stat'] == 'Hoàn thành',
          )
          .length;
      final double pct = total == 0 ? 0.0 : completed / total;
      final String pctStr = '${(pct * 100).toInt()}%';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _C.surfaceVariant.withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 5,
                    backgroundColor: _C.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation(_C.primary),
                    strokeCap: StrokeCap.round,
                  ),
                  Text(
                    pctStr,
                    style: const TextStyle(
                      color: _C.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'TIẾN ĐỘ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _C.outline,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$completed / $total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildCategorySection() {
    final items = [
      _CategoryUiItem(
        label: 'Công việc',
        value: 'Công việc',
        icon: Icons.work_rounded,
        color: const Color(0xFFEFF1FF),
        iconBackground: const Color(0xFF6875F5),
        iconColor: Colors.white,
        textColor: const Color(0xFF5560CC),
      ),
      _CategoryUiItem(
        label: 'Cá nhân',
        value: 'Cá nhân',
        icon: Icons.person_rounded,
        color: const Color(0xFFE3F7EC),
        iconBackground: const Color(0xFF35B36A),
        iconColor: Colors.white,
        textColor: const Color(0xFF238751),
      ),
      _CategoryUiItem(
        label: 'Sức khỏe',
        value: 'Sức khỏe',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFFFE5E5),
        iconBackground: const Color(0xFFFF5A5F),
        iconColor: Colors.white,
        textColor: const Color(0xFFD94242),
      ),
      _CategoryUiItem(
        label: 'Học tập',
        value: 'Học tập',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFF4E8D7),
        iconBackground: const Color(0xFFB17705),
        iconColor: Colors.white,
        textColor: const Color(0xFF8E6412),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục',
          style: TextStyle(
            color: _C.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCategoryTile(items[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildCategoryTile(items[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildCategoryTile(items[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildCategoryTile(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTile(_CategoryUiItem item) {
    final selected = _selectedCategory == item.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = selected ? null : item.value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _C.primary.withValues(alpha: 0.55)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 17, color: item.iconColor),
            ),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: item.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TASK LIST — data from code 1, layout refined
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTaskList() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: _currentUserUid);

    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Lỗi tải dữ liệu'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 32),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE7E8F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      size: 34,
                      color: Color(0xFFA7A7EA),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Mọi thứ đã gọn gàng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A4B5C),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chưa có nhiệm vụ đang làm. Nhấn\nnút micro để thêm nhiệm vụ mới\nbằng giọng nói.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF707388),
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final task = TaskViewModel.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            final isCompleted = _isTaskCompleted(task);
            final isOverdue = _isTaskOverdue(task);

            return _TaskCard(
              docId: doc.id,
              task: task,
              isCompleted: isCompleted,
              isOverdue: isOverdue,
              onToggle: (val) => _toggleTaskStatus(doc.id, task, val ?? false),
              onDelete: () => _deleteTask(doc.id),
              onTimerTap: task.way == 'promodoro'
                  ? () => showPromodoroTimerSheet(
                      context,
                      taskDocId: doc.id,
                      task: task,
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  // ── Home content ──────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreetingSection(),
                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DashboardStreakCard(userUid: _currentUserUid),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _buildProgressCard(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _buildCategorySection(),
                const SizedBox(height: 22),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _taskSectionTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_selectedCategory != null) {
                          setState(() => _selectedCategory = null);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedCategory == null ? 'Xem tất cả' : 'Bỏ lọc',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _C.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTaskList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Main body ─────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Stack(
      children: [
        _buildHomeContent(),

        if (widget.showBottomNav)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavBar(currentIndex: 0, showFab: false),
          ),

        // FAB — premium gradient style from code 2
        Positioned(
          bottom: 96,
          right: 24,
          child: VoiceTaskButton(
            onVoiceResult: (text) => VoiceHandler.process(text, context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(child: _buildBody()),
    );
  }
}

class _GreetingAvatarFallback extends StatelessWidget {
  final String? name;

  const _GreetingAvatarFallback({this.name});

  @override
  Widget build(BuildContext context) {
    final safeName = (name ?? '').trim();
    final initials = safeName.isEmpty
        ? 'U'
        : safeName
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase();

    return Container(
      color: _C.primaryFixed,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: _C.primary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CategoryUiItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;

  const _CategoryUiItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconBackground,
    required this.iconColor,
    required this.textColor,
  });
}

// ════════════════════════════════════════════════════════════════════════════
// TASK CARD WIDGET — premium style from code 2, data/logic from code 1
// ════════════════════════════════════════════════════════════════════════════
class _TaskCard extends StatelessWidget {
  final String docId;
  final TaskViewModel task;
  final bool isCompleted;
  final bool isOverdue;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTimerTap;

  const _TaskCard({
    required this.docId,
    required this.task,
    required this.isCompleted,
    required this.isOverdue,
    required this.onToggle,
    required this.onDelete,
    this.onTimerTap,
  });

  String _formatTs(Timestamp? ts) {
    if (ts == null) return 'Chưa có';
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final mo = d.month.toString().padLeft(2, '0');
    return '$hh:$mm - $dd/$mo';
  }

  bool get _isUrgent {
    if (isCompleted || isOverdue || task.dueAt == null) return false;
    final due = task.dueAt!.toDate();
    final diff = due.difference(DateTime.now());
    return diff.inMinutes > 0 && diff.inHours <= 2;
  }

  _ChipStyle _chipStyle() {
    final cat = (task.category ?? '').toLowerCase();
    if (cat.contains('sức khỏe') || cat.contains('health')) {
      return _ChipStyle(
        task.category ?? 'Sức khỏe',
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      );
    } else if (cat.contains('cá nhân') || cat.contains('personal')) {
      return _ChipStyle(
        task.category ?? 'Cá nhân',
        _C.surfaceVariant,
        _C.outline,
      );
    } else {
      return _ChipStyle(
        task.category ?? 'Công việc',
        const Color(0xFFE0E7FF),
        const Color(0xFF4338CA),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _chipStyle();

    return Dismissible(
      key: ValueKey(task.title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFEF4444),
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Opacity(
        opacity: isCompleted ? 0.50 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? _C.surfaceContainerLow.withValues(alpha: 0.30)
                : _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              style: isCompleted ? BorderStyle.solid : BorderStyle.solid,
              color: isCompleted
                  ? _C.outlineVariant.withValues(alpha: 0.30)
                  : isOverdue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                  : _C.surfaceVariant.withValues(alpha: 0.20),
            ),
            boxShadow: isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Checkbox ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: () => onToggle(!isCompleted),
                  child: isCompleted
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _C.primary.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: _C.primary,
                            size: 18,
                          ),
                        )
                      : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _C.outlineVariant,
                              width: 2,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 20),

              // ── Content ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row + 3-dot menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? _C.outline : _C.onSurface,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: _C.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.way == 'promodoro')
                          AnimatedBuilder(
                            animation: TimerService.instance,
                            builder: (context, _) {
                              final svc = TimerService.instance;
                              final isCurrentRunning =
                                  svc.taskDocId == docId &&
                                  svc.phase != TimerPhase.idle &&
                                  svc.phase != TimerPhase.stopped;
                              final icon = isCurrentRunning
                                  ? Icons.notifications_active_rounded
                                  : Icons.alarm_rounded;
                              final bgColor = isCurrentRunning
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFE1E0FF);
                              final fgColor = isCurrentRunning
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF4648D4);

                              return GestureDetector(
                                onTap: onTimerTap,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, size: 18, color: fgColor),
                                ),
                              );
                            },
                          ),
                        if (!isCompleted)
                          GestureDetector(
                            onTap: () => _showTaskMenu(context),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.more_horiz_rounded,
                                color: _C.outlineVariant,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (task.way == 'promodoro' &&
                        (task.focusDuration != null ||
                            task.breakDuration != null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Làm ${task.focusDuration ?? 25} phút • Nghỉ ${task.breakDuration ?? 5} phút',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _C.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    // Timestamps row
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 15,
                              color: _C.outline,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _formatTs(task.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.outline,
                              ),
                            ),
                          ],
                        ),
                        if (task.dueAt != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue
                                    ? Icons.alarm_outlined
                                    : Icons.schedule_outlined,
                                size: 15,
                                color: isOverdue || _isUrgent
                                    ? _C.error
                                    : _C.outline,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Hạn: ${_formatTs(task.dueAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isOverdue || _isUrgent
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isOverdue || _isUrgent
                                      ? _C.error
                                      : _C.outline,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Chips row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chip.bg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            chip.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: chip.fg,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (_isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _C.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ƯU TIÊN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _C.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: _C.primary),
              title: const Text('Chỉnh sửa'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
              ),
              title: const Text(
                'Xoá',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Chip style helper ─────────────────────────────────────────────────────────
class _ChipStyle {
  final String label;
  final Color bg;
  final Color fg;
  const _ChipStyle(this.label, this.bg, this.fg);
}

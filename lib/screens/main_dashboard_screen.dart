export 'dashboard/dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/promodoro/promodoro_timer_sheet.dart';
import '../widgets/floating_bottom_navbar.dart';
import '../widgets/sidebar.dart';
import '../services/timer_service.dart';
import '../notifications/task_notification_bell.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_button.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_handler.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_input_dialog.dart';
import '../views/task_viewmodel.dart';

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
  bool _showSidebar = false;
  String? _selectedCategory;

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
  }

  void _toggleSidebar() => setState(() => _showSidebar = !_showSidebar);

  // ── Task Helpers ──────────────────────────────────────────────────────────
  bool _isTaskCompleted(TaskViewModel task) => task.stat == 'Hoàn thành';

  DateTime? _taskAnchor(TaskViewModel task) {
    final candidates = [
      task.completedAt?.toDate(),
      task.dueAt?.toDate(),
      task.createdAt?.toDate(),
      task.timestamp?.toDate(),
    ];

    for (final candidate in candidates) {
      if (candidate != null) return candidate;
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
      updates['timestamp'] = FieldValue.serverTimestamp();
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

  Future<void> _editLongTaskByVoice(String docId, TaskViewModel task) async {
    if (task.way != 'long_term_task') return;

    await SystemSound.play(SystemSoundType.click);
    await VoiceAiService.instance.speakText('Bạn muốn thay đổi gì ạ?');

    if (!mounted) return;
    final transcript = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(
        prompt: 'Nói phần bạn muốn đổi cho task dài hạn',
      ),
    );

    if (!mounted || transcript == null || transcript.trim().isEmpty) return;

    final updates = <String, dynamic>{};
    final parsed = await VoiceAiService.instance.extractTaskFromText(transcript);

    final aiTitle = (parsed?['task_name'] as String?)?.trim();
    if (aiTitle != null && aiTitle.isNotEmpty) {
      updates['title'] = aiTitle;
    }

    final aiPriority = (parsed?['priority'] as String?)?.trim();
    final priority = aiPriority ?? _parsePriorityFromSpeech(transcript);
    if (priority != null) updates['priority'] = priority;

    final aiCategory = (parsed?['category'] as String?)?.trim();
    final category = aiCategory ?? _parseCategoryFromSpeech(transcript);
    if (category != null) updates['category'] = category;

    final parsedDue = _parseDueAtFromSpeech(
      dateText: parsed?['date'] as String?,
      timeText: parsed?['time'] as String?,
      rawText: transcript,
    );
    if (parsedDue != null) {
      updates['dueAt'] = Timestamp.fromDate(parsedDue);
    }

    if (updates.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa nhận diện được thông tin cần thay đổi.')),
        );
      }
      return;
    }

    updates['timestamp'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance.collection('tasks').doc(docId).update(updates);
    await SystemSound.play(SystemSoundType.click);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật task bằng giọng nói.')),
      );
    }
  }

  String? _parsePriorityFromSpeech(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('cao') || lower.contains('high')) return 'Cao';
    if (lower.contains('thấp') || lower.contains('thap') || lower.contains('low')) return 'Thấp';
    if (lower.contains('vừa') || lower.contains('vua') || lower.contains('medium')) return 'Vừa';
    return null;
  }

  String? _parseCategoryFromSpeech(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('học')) return 'Học tập';
    if (lower.contains('cá nhân') || lower.contains('ca nhan') || lower.contains('personal')) return 'Cá nhân';
    if (lower.contains('sức') || lower.contains('suc') || lower.contains('health')) return 'Sức khỏe';
    if (lower.contains('công') || lower.contains('cong') || lower.contains('work')) return 'Công việc';
    return null;
  }

  DateTime? _parseDueAtFromSpeech({
    String? dateText,
    String? timeText,
    required String rawText,
  }) {
    final now = DateTime.now();
    DateTime base = now;

    if (dateText != null && dateText.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(dateText.trim());
      if (parsed != null) base = parsed;
    } else {
      final lower = rawText.toLowerCase();
      if (lower.contains('ngày mai') || lower.contains('mai')) {
        base = now.add(const Duration(days: 1));
      }
    }

    int? hour;
    int minute = 0;

    if (timeText != null && timeText.trim().isNotEmpty) {
      final parts = timeText.trim().split(':');
      if (parts.length == 2) {
        hour = int.tryParse(parts[0]);
        minute = int.tryParse(parts[1]) ?? 0;
      }
    }

    if (hour == null) {
      final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawText);
      if (hm != null) {
        hour = int.tryParse(hm.group(1) ?? '0') ?? 0;
        minute = int.tryParse(hm.group(2) ?? '0') ?? 0;
      }
    }

    if (hour == null) return null;

    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  String _taskSectionTitle() => _selectedCategory == null
      ? 'Danh sách việc làm'
      : 'Danh sách việc làm • $_selectedCategory';

  // ════════════════════════════════════════════════════════════════════════════
  // TOP BAR — premium glass style from code 2
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: _C.surface.withValues(alpha: 0.60),
        border: Border(
          bottom: BorderSide(color: _C.surfaceVariant.withValues(alpha: 0.10)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleSidebar,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: _C.onSurface,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Serene Focus',
            style: TextStyle(
              color: _C.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          TaskNotificationBellButton(
            userId: _currentUserUid,
            iconColor: _C.onSurfaceVariant,
            badgeColor: _C.error,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GREETING SECTION — premium style from code 2, data from code 1
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildGreetingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: _currentUserUid.isEmpty
                    ? null
                    : FirebaseFirestore.instance
                          .collection('register')
                          .doc(_currentUserUid)
                          .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  final displayName =
                      (data?['displayName'] as String?)?.trim().isNotEmpty ==
                          true
                      ? data!['displayName'] as String
                      : 'User';

                  return RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Chào, ',
                          style: TextStyle(color: _C.onSurface),
                        ),
                        TextSpan(
                          text: displayName,
                          style: const TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              const Text(
                'Hôm nay bạn muốn hoàn thành điều gì?',
                style: TextStyle(
                  fontSize: 16,
                  color: _C.outline,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
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
          child: const Icon(
            Icons.light_mode_outlined,
            color: _C.primary,
            size: 26,
          ),
        ),
      ],
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
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final tomorrowStart = todayStart.add(const Duration(days: 1));

        final todayTasks = docs.where((doc) {
          final task = TaskViewModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          final anchor = _taskAnchor(task);
          return anchor != null &&
              !anchor.isBefore(todayStart) &&
              anchor.isBefore(tomorrowStart);
        }).map((doc) => TaskViewModel.fromMap(doc.data() as Map<String, dynamic>)).toList();

        final total = todayTasks.length;
        final completed = todayTasks.where(_isTaskCompleted).length;
        final double pct = total == 0 ? 0.0 : completed / total;
        final String pctStr = '${(pct * 100).toInt()}%';

        String mood, sub;
        if (total == 0) {
          mood = 'Hôm nay bắt đầu nào!';
          sub = 'Bạn có thể làm được nhiều điều.';
        } else if (pct >= 1.0) {
          mood = 'Xuất sắc! 🎉';
          sub = 'Bạn đã hoàn thành tất cả!';
        } else if (pct >= 0.5) {
          mood = 'Bạn đang làm rất tốt!';
          sub = 'Hãy tiếp tục nhé!';
        } else {
          mood = 'Cố lên nào!';
          sub = 'Bạn đang làm rất tốt.';
        }

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _C.surfaceVariant.withValues(alpha: 0.20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Circular progress ring
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 10,
                        backgroundColor: _C.surfaceContainer,
                        valueColor: const AlwaysStoppedAnimation(_C.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pctStr,
                          style: const TextStyle(
                            color: _C.primary,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'TIẾN ĐỘ',
                          style: TextStyle(
                            color: _C.outline,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats text
              Text(
                total == 0
                    ? 'Chưa có công việc nào.'
                    : '$completed trên $total công việc',
                style: const TextStyle(
                  color: _C.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(
                  color: _C.outline,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
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
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Chưa có nhiệm vụ nào phù hợp',
                style: TextStyle(color: _C.outline, fontSize: 15),
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
              onToggle: (val) =>
                  _toggleTaskStatus(doc.id, task, val ?? false),
              onDelete: () => _deleteTask(doc.id),
              onVoiceEdit: task.way == 'long_term_task'
                ? () => _editLongTaskByVoice(doc.id, task)
                : null,
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreetingSection(),
                const SizedBox(height: 32),

                // Progress
                _buildProgressCard(),
                const SizedBox(height: 32),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _taskSectionTitle(),
                      style: const TextStyle(
                        fontSize: 20,
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

        // Sidebar overlay
        AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          opacity: _showSidebar ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !_showSidebar,
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),

        // Sidebar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          left: _showSidebar ? 0 : -280,
          top: 0,
          bottom: 0,
          width: 280,
          child: DashboardSidebar(
            currentPage: 'dashboard',
            userName: 'User Name',
            selectedTag: _selectedCategory,
            onTagSelected: (category) {
              setState(() {
                _selectedCategory = category;
                _showSidebar = false;
              });
            },
            onDashboardTap: () {
              setState(() {
                _selectedCategory = null;
                _showSidebar = false;
              });
            },
            onCalendarTap: () {
              setState(() => _showSidebar = false);
              Navigator.of(context).pushNamed('/calendar');
            },
            onChartsTap: () {
              setState(() => _showSidebar = false);
              Navigator.of(context).pushNamed('/charts');
            },
            onEditProfile: () {},
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),

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
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4648D4), Color(0xFF6063EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4648D4).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: VoiceTaskButton(
              onVoiceResult: (text) => VoiceHandler.process(text, context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBody(),
          ],
        ),
      ),
    );
  }
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
  final VoidCallback? onVoiceEdit;
  final VoidCallback? onTimerTap;

  const _TaskCard({
    required this.docId,
    required this.task,
    required this.isCompleted,
    required this.isOverdue,
    required this.onToggle,
    required this.onDelete,
    this.onVoiceEdit,
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
                                  child: Icon(
                                    icon,
                                    size: 18,
                                    color: fgColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (task.way == 'long_term_task' && !isCompleted)
                          GestureDetector(
                            onTap: onVoiceEdit,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1E0FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.mic_none_rounded,
                                size: 18,
                                color: Color(0xFF4648D4),
                              ),
                            ),
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
                        (task.focusDuration != null || task.breakDuration != null))
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/floating_bottom_navbar.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_notification_bell.dart';
import '../views/task_viewmodel.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const outlineVariant = Color(0xFFC7C4D7);
  static const outline = Color(0xFF767586);
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const error = Color(0xFFBA1A1A);
  static const tertiary = Color(0xFF006C49);
  static const secondaryFixed = Color(0xFFD4E3FF);
  static const onSecondaryFixed = Color(0xFF001C39);
}

// ── Screen ────────────────────────────────────────────────────────────────────
class CalendarScreen extends StatefulWidget {
  final bool showBottomNav;

  const CalendarScreen({super.key, this.showBottomNav = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = DateTime.now().day;
  DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      drawer: Drawer(
        width: 280,
        child: SafeArea(
          child: DashboardSidebar(
            currentPage: 'calendar',
            userName: 'User Name',
            onDashboardTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/dashboard');
            },
            onCalendarTap: () => Navigator.of(context).pop(),
            onChartsTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/stats');
            },
            onEditProfile: () => Navigator.of(context).pushNamed('/profile'),
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildHeaderSection(),
                const SizedBox(height: 32),
                _CalendarCard(
                  selectedDay: _selectedDay,
                  displayedMonth: _displayedMonth,
                  onDaySelected: (d) => setState(() => _selectedDay = d),
                  onPrevMonth: () => setState(() {
                    final prev = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                    final daysInPrev = DateTime(
                      prev.year,
                      prev.month + 1,
                      0,
                    ).day;
                    _displayedMonth = prev;
                    if (_selectedDay > daysInPrev) {
                      _selectedDay = daysInPrev;
                    }
                  }),
                  onNextMonth: () => setState(() {
                    final next = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month + 1,
                    );
                    final daysInNext = DateTime(
                      next.year,
                      next.month + 1,
                      0,
                    ).day;
                    _displayedMonth = next;
                    if (_selectedDay > daysInNext) {
                      _selectedDay = daysInNext;
                    }
                  }),
                  onToday: () => setState(() {
                    final now = DateTime.now();
                    _displayedMonth = DateTime(now.year, now.month);
                    _selectedDay = now.day;
                  }),
                ),
                const SizedBox(height: 32),
                _TaskSection(
                  selectedDay: _selectedDay,
                  displayedMonth: _displayedMonth,
                ),
              ],
            ),
          ),
        ],
      ),
        bottomNavigationBar: widget.showBottomNav
          ? const FloatingBottomNavBar(currentIndex: 1, showFab: false)
          : null,
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.surface.withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // glass border effect
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: _C.outlineVariant.withValues(alpha: 0.30),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: _C.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'Serene Focus',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _C.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        TaskNotificationBellButton(
          userId: _currentUserUid,
          iconColor: _C.onSurfaceVariant,
          badgeColor: _C.error,
        ),
      ],
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    final now = DateTime.now();
    final isCurrentMonth =
        _displayedMonth.year == now.year && _displayedMonth.month == now.month;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch biểu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: _C.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _monthLabel(_displayedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  color: _C.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // "Hôm nay" pill button (from HTML code 1)
        GestureDetector(
          onTap: () => setState(() {
            final n = DateTime.now();
            _displayedMonth = DateTime(n.year, n.month);
            _selectedDay = n.day;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.today_outlined,
                  size: 18,
                  color: isCurrentMonth ? _C.primary : _C.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Hôm nay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCurrentMonth ? _C.primary : _C.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _monthLabel(DateTime dt) {
    const names = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${names[dt.month - 1]}, ${dt.year}';
  }
}

// ── Calendar Card ─────────────────────────────────────────────────────────────
class _CalendarCard extends StatelessWidget {
  final int selectedDay;
  final DateTime displayedMonth;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  const _CalendarCard({
    required this.selectedDay,
    required this.displayedMonth,
    required this.onDaySelected,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  static const _weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _monthNames = [
    'Tháng Một',
    'Tháng Hai',
    'Tháng Ba',
    'Tháng Tư',
    'Tháng Năm',
    'Tháng Sáu',
    'Tháng Bảy',
    'Tháng Tám',
    'Tháng Chín',
    'Tháng Mười',
    'Tháng Mười Một',
    'Tháng Mười Hai',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // glass-card from HTML code 1
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text(
                '${_monthNames[displayedMonth.month - 1]} ${displayedMonth.year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: _C.onSurface,
                ),
              ),
              _NavButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 20),

          // Weekday headers
          Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Day grid with real Firestore dot indicators
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where(
                  'uid',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
                )
                .snapshots(),
            builder: (context, snap) {
              final Map<int, List<Color>> dayColors = {};
              final Map<int, int> dayCounts = {};

              if (snap.hasData) {
                for (final doc in snap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>?;
                  final due = (data?['dueAt'] as Timestamp?)?.toDate();
                  if (due != null &&
                      due.year == displayedMonth.year &&
                      due.month == displayedMonth.month) {
                    final day = due.day;
                    final category = (data?['category'] as String?) ?? '';
                    Color col = _C.primary;
                    if (category.toLowerCase().contains('sức')) {
                      col = _C.error;
                    } else if (category.toLowerCase().contains('cá nhân')) {
                      col = _C.tertiary;
                    } else {
                      col = _C.primaryContainer;
                    }
                    dayColors.putIfAbsent(day, () => []);
                    if (!dayColors[day]!.contains(col)) {
                      dayColors[day]!.add(col);
                    }
                    dayCounts[day] = (dayCounts[day] ?? 0) + 1;
                  }
                }
              }

              final year = displayedMonth.year;
              final month = displayedMonth.month;
              final first = DateTime(year, month, 1);
              final startOffset = first.weekday % 7;
              final daysInMonth = DateTime(year, month + 1, 0).day;

              return GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                children: List.generate(42, (i) {
                  final dayNumber = i - startOffset + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () => onDaySelected(dayNumber),
                    child: _DayCell(
                      day: dayNumber,
                      isSelected: dayNumber == selectedDay,
                      dots: dayColors[dayNumber] ?? const [],
                      badgeCount: dayCounts[dayNumber] ?? 0,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Nav button ────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // hover:bg-primary-fixed/50 equivalent
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: _C.primary, size: 24),
      ),
    );
  }
}

// ── Day Cell ──────────────────────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final List<Color> dots;
  final int badgeCount;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.dots,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Selected background — rounded-xl with shadow (from HTML)
        if (isSelected)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Badge count (top-right corner)
        if (badgeCount > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _C.onSurface,
                ),
              ),
            ),
          ),

        // Day number + dots
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Colors.white : _C.onSurface,
              ),
            ),
            if (dots.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots
                    .take(3)
                    .map(
                      (c) => Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          // white dots on selected, colored otherwise
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.80)
                              : c,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Task Section ──────────────────────────────────────────────────────────────
class _TaskSection extends StatelessWidget {
  final int selectedDay;
  final DateTime displayedMonth;

  const _TaskSection({required this.selectedDay, required this.displayedMonth});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final start = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      selectedDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header — matches HTML code 1 style
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NHIỆM VỤ - NGÀY $selectedDay',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: _C.onSurfaceVariant,
              ),
            ),
            // Task count badge (real data below, placeholder pill here)
            StreamBuilder<QuerySnapshot>(
              stream: user == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('tasks')
                        .where('uid', isEqualTo: user.uid)
                        .snapshots(),
              builder: (context, snap) {
                final count = snap.hasData
                    ? snap.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>?;
                        final due = (data?['dueAt'] as Timestamp?)?.toDate();
                        return due != null &&
                            due.year == start.year &&
                            due.month == start.month &&
                            due.day == start.day;
                      }).length
                    : 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _C.secondaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count CÔNG VIỆC',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.onSecondaryFixed,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (user == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Vui lòng đăng nhập để xem nhiệm vụ',
                style: TextStyle(color: _C.outline, fontSize: 15),
              ),
            ),
          )
        else
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('uid', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter tasks for the selected date by dueAt
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                final due = (data?['dueAt'] as Timestamp?)?.toDate();
                return due != null &&
                    due.year == start.year &&
                    due.month == start.month &&
                    due.day == start.day;
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Chưa có nhiệm vụ nào',
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
                  final isCompleted = task.stat == 'Hoàn thành';
                  final dueAt = task.dueAt?.toDate();
                  final isOverdue =
                      !isCompleted &&
                      (dueAt != null
                          ? dueAt.isBefore(DateTime.now())
                          : task.stat == 'Quá hạn');

                  return _CalendarTaskCard(
                    task: task,
                    isCompleted: isCompleted,
                    isOverdue: isOverdue,
                    onToggle: (val) async {
                      final stat = (val ?? false)
                          ? 'Hoàn thành'
                          : (isOverdue ? 'Quá hạn' : 'Đang làm');
                      final updates = <String, dynamic>{'stat': stat};
                      if (val == true) {
                        updates['completedAt'] = FieldValue.serverTimestamp();
                      } else {
                        updates['completedAt'] = FieldValue.delete();
                      }
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(doc.id)
                          .update(updates);
                    },
                    onDelete: () async {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(doc.id)
                          .delete();
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

// ── Calendar Task Card ─────────────────────────────────────────────────────────
// UI from HTML code 1 (glass-card, icon avatar, horizontal layout)
// Data/logic from Flutter code 2
class _CalendarTaskCard extends StatelessWidget {
  final TaskViewModel task;
  final bool isCompleted;
  final bool isOverdue;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const _CalendarTaskCard({
    required this.task,
    required this.isCompleted,
    required this.isOverdue,
    required this.onToggle,
    required this.onDelete,
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

  // Derive icon + color from category & status (mirroring HTML code 1)
  _CardTheme _cardTheme() {
    final cat = (task.category ?? '').toLowerCase();
    if (isCompleted) {
      return _CardTheme(
        Icons.check_circle_rounded,
        _C.tertiary.withValues(alpha: 0.10),
        _C.tertiary,
      );
    } else if (isOverdue) {
      return _CardTheme(
        Icons.priority_high_rounded,
        _C.error.withValues(alpha: 0.10),
        _C.error,
      );
    } else if (cat.contains('sức')) {
      return _CardTheme(
        Icons.favorite_outline_rounded,
        _C.tertiary.withValues(alpha: 0.10),
        _C.tertiary,
      );
    } else if (cat.contains('cá nhân')) {
      return _CardTheme(
        Icons.person_outline_rounded,
        _C.primaryContainer.withValues(alpha: 0.10),
        _C.primaryContainer,
      );
    } else {
      return _CardTheme(
        Icons.work_outline_rounded,
        _C.primary.withValues(alpha: 0.10),
        _C.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _cardTheme();

    return Dismissible(
      key: ValueKey(
        task.title + (task.createdAt?.millisecondsSinceEpoch.toString() ?? ''),
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _C.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: _C.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Opacity(
        opacity: isCompleted ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // glass-card style from HTML code 1
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue
                  ? _C.error.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.20),
            ),
            boxShadow: isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon avatar (from HTML code 1) ──────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(theme.icon, color: theme.iconFg, size: 24),
              ),
              const SizedBox(width: 14),

              // ── Content ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? _C.outline : _C.onSurface,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: _C.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Time row
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.done_all_rounded
                              : Icons.schedule_outlined,
                          size: 14,
                          color: isCompleted
                              ? _C.tertiary
                              : isOverdue
                              ? _C.error
                              : _C.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted
                              ? 'Đã hoàn thành'
                              : isOverdue
                              ? 'Quá hạn: ${_formatTs(task.dueAt)}'
                              : _formatTs(task.dueAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isCompleted
                                ? _C.tertiary
                                : isOverdue
                                ? _C.error
                                : _C.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Checkbox (from code 2 logic) ────────────────────
              GestureDetector(
                onTap: () => onToggle(!isCompleted),
                child: isCompleted
                    ? Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: _C.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    : Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _C.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card theme helper ─────────────────────────────────────────────────────────
class _CardTheme {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  const _CardTheme(this.icon, this.iconBg, this.iconFg);
}

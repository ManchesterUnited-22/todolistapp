import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/stats_service.dart';
import '../views/stats_viewmodel.dart';
import '../views/task_viewmodel.dart';
import '../widgets/floating_bottom_navbar.dart';
import '../widgets/mentor_ai.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_notification_bell.dart';
import '../widgets/timer.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF464554);
  static const onPrimaryFixedVar = Color(0xFF2F2EBE);
  static const onPrimaryFixed = Color(0xFF07006C);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const secondary = Color(0xFF0060AC);
  static const tertiary = Color(0xFF006C49);
  static const error = Color(0xFFBA1A1A);
  static const outlineVariant = Color(0xFFC7C4D7);
}

BoxDecoration get _glassCard => BoxDecoration(
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
);

// ── Screen ────────────────────────────────────────────────────────────────────
class ChartsScreen extends StatefulWidget {
  final bool showBottomNav;

  const ChartsScreen({super.key, this.showBottomNav = true});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _lastSyncedSignature = '';

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      drawer: Drawer(
        width: 280,
        child: SafeArea(
          child: DashboardSidebar(
            currentPage: 'charts',
            userName: 'User Name',
            onDashboardTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/dashboard');
            },
            onCalendarTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/calendar');
            },
            onChartsTap: () => Navigator.of(context).pop(),
            onEditProfile: () => Navigator.of(context).pushNamed('/profile'),
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),
      ),
      appBar: _buildAppBar(),
      body: _buildBody(),
        bottomNavigationBar: widget.showBottomNav
          ? const FloatingBottomNavBar(currentIndex: 2, showFab: false)
          : null,
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.surface.withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
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
          iconColor: _C.primary,
          badgeColor: _C.error,
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final uid = _currentUserUid;
    if (uid.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Vui lòng đăng nhập để xem thống kê.',
            style: TextStyle(color: _C.onSurfaceVariant, fontSize: 16),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Lỗi tải dữ liệu biểu đồ'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs
            .map((doc) => TaskViewModel.fromMap(doc.data()))
            .toList();
        final stats = StatsViewModel.fromTasks(uid: uid, tasks: tasks);

        if (stats.syncSignature != _lastSyncedSignature) {
          _lastSyncedSignature = stats.syncSignature;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) StatsService.instance.saveUserStats(stats);
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryBanner(stats: stats),
              const SizedBox(height: 20),
              MentorAiButton(),
              const SizedBox(height: 32),
              _KpiGrid(stats: stats),
              const SizedBox(height: 32),
              _WeeklyChart(stats: stats, tasks: tasks),
              const SizedBox(height: 32),
              _DistributionSection(stats: stats),
              const SizedBox(height: 32),
              _FocusInsightsRow(stats: stats),
              const SizedBox(height: 32),
              const TimerCard(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. SUMMARY BANNER
// ══════════════════════════════════════════════════════════════════════════════
class _SummaryBanner extends StatelessWidget {
  final StatsViewModel stats;
  const _SummaryBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = (stats.completionRate * 100).round();
    final String headline;
    final String subline;
    if (pct >= 80) {
      headline = 'Tuyệt vời!';
      subline = 'Bạn đã hoàn thành $pct% mục tiêu. Tiếp tục phát huy nhé!';
    } else if (pct >= 50) {
      headline = 'Cố lên nào!';
      subline = 'Bạn đã hoàn thành $pct% — đang đi đúng hướng!';
    } else if (pct > 0) {
      headline = 'Bắt đầu thôi!';
      subline = 'Chỉ mới $pct% — mỗi bước nhỏ đều quan trọng.';
    } else {
      headline = 'Hôm nay bắt đầu nào!';
      subline = 'Chưa có công việc nào. Hãy thêm nhiệm vụ đầu tiên!';
    }

    return Container(
      decoration: BoxDecoration(
        color: _C.primaryFixed.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _C.onPrimaryFixed,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subline,
                      style: const TextStyle(
                        fontSize: 15,
                        color: _C.onPrimaryFixedVar,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: _C.primary,
                  size: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. KPI GRID
// ══════════════════════════════════════════════════════════════════════════════
class _KpiGrid extends StatelessWidget {
  final StatsViewModel stats;
  const _KpiGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final completionPct = (stats.completionRate * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.timer_outlined,
                iconColor: _C.primary,
                label: 'Tập trung',
                value: stats.bestFocusWindowLabel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                icon: Icons.local_fire_department_outlined,
                iconColor: _C.tertiary,
                label: 'Chuỗi ngày',
                value: stats.streakLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _glassCard,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: _C.secondary, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tỷ lệ hoàn thành',
                      style: TextStyle(
                        fontSize: 12,
                        color: _C.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      '$completionPct%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _C.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(
                  painter: _RingPainter(value: stats.completionRate),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _C.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. WEEKLY BAR CHART
// ══════════════════════════════════════════════════════════════════════════════
class _WeeklyChart extends StatelessWidget {
  final StatsViewModel stats;
  final List<TaskViewModel> tasks;
  const _WeeklyChart({required this.stats, required this.tasks});

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));

    // Bucket tasks by weekday
    final tasksByDay = List.generate(7, (_) => <TaskViewModel>[]);
    for (final task in tasks) {
      final anchor = task.dueAt?.toDate() ?? task.createdAt?.toDate();
      if (anchor == null) continue;
      final dayOnly = DateTime(anchor.year, anchor.month, anchor.day);
      final diff = dayOnly.difference(monday).inDays;
      if (diff < 0 || diff > 6) continue;
      tasksByDay[diff].add(task);
    }

    // Completion ratio per day
    final ratios = List.generate(7, (i) {
      final dayTasks = tasksByDay[i];
      if (dayTasks.isEmpty) return 0.0;
      final completed = dayTasks.where((t) => t.stat == 'Hoàn thành').length;
      return completed / dayTasks.length;
    });

    final maxVal = ratios.isEmpty
        ? 1.0
        : ratios.reduce(math.max).clamp(0.01, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'Hiệu suất tuần',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _C.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Tuần này',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bar chart card
        Container(
          decoration: _glassCard,
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (dayIndex) {
                final ratio = ratios[dayIndex];
                final barFraction = maxVal > 0 ? (ratio / maxVal) : 0.0;
                final dayDate = monday.add(Duration(days: dayIndex));
                final completedCount = tasksByDay[dayIndex]
                    .where((t) => t.stat == 'Hoàn thành')
                    .length;
                final totalCount = tasksByDay[dayIndex].length;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onLongPress: () => _showDayTasks(
                        context,
                        dayIndex,
                        dayDate,
                        tasksByDay[dayIndex],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: barFraction.clamp(0.04, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: barFraction > 0.85
                                        ? _C.primaryContainer
                                        : _C.primary,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dayLabels[dayIndex],
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$completedCount/$totalCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _C.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _showDayTasks(
    BuildContext context,
    int dayIndex,
    DateTime dayDate,
    List<TaskViewModel> dayTasks,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.only(top: 56),
          decoration: const BoxDecoration(
            color: _C.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_dayLabels[dayIndex]} • ${dayDate.day.toString().padLeft(2, '0')}/${dayDate.month.toString().padLeft(2, '0')}/${dayDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _C.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dayTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Không có nhiệm vụ trong ngày này.'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dayTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final task = dayTasks[idx];
                        final isCompleted = task.stat == 'Hoàn thành';
                        final iconColor = isCompleted
                            ? _C.tertiary
                            : _C.onSurfaceVariant;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconForCategory(task.category),
                                  color: iconColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: _C.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${task.category.isEmpty ? 'Không có nhãn' : task.category} • ${isCompleted ? 'Hoàn thành' : 'Chưa hoàn thành'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _C.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? _C.tertiary
                                    : _C.onSurfaceVariant,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String label) {
    final n = label.toLowerCase();
    if (n.contains('sức') || n.contains('khỏe')) {
      return Icons.favorite_rounded;
    }
    if (n.contains('cá nhân') || n.contains('personal')) {
      return Icons.person_rounded;
    }
    if (n.contains('học')) return Icons.school_outlined;
    return Icons.work_rounded;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4. DISTRIBUTION SECTION
// ══════════════════════════════════════════════════════════════════════════════
class _DistributionSection extends StatelessWidget {
  final StatsViewModel stats;
  const _DistributionSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    double healthRatio = 0.0;
    double workRatio = 0.0;
    double personalRatio = 0.0;

    stats.categoryRatios.forEach((rawName, ratio) {
      final n = rawName.toLowerCase();
      if (n.contains('sức') || n.contains('khỏe')) {
        healthRatio += ratio;
      } else if (n.contains('cá nhân') ||
          n.contains('cá nhan') ||
          n.contains('personal')) {
        personalRatio += ratio;
      } else {
        workRatio += ratio;
      }
    });

    final total = healthRatio + workRatio + personalRatio;
    if (total > 1.0) {
      healthRatio /= total;
      workRatio /= total;
      personalRatio /= total;
    }

    final categories = <Map<String, dynamic>>[
      {
        'name': 'Sức khỏe',
        'ratio': healthRatio,
        'icon': Icons.favorite_rounded,
        'color': _C.tertiary,
      },
      {
        'name': 'Công việc',
        'ratio': workRatio,
        'icon': Icons.work_rounded,
        'color': _C.secondary,
      },
      {
        'name': 'Cá nhân',
        'ratio': personalRatio,
        'icon': Icons.person_rounded,
        'color': _C.primaryContainer,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Phân tích chi tiết',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _glassCard,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: categories.map((share) {
              final color = share['color'] as Color;
              final name = share['name'] as String;
              final ratio = (share['ratio'] as double).clamp(0.0, 1.0);
              final icon = share['icon'] as IconData;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _InsightRow(
                  icon: icon,
                  iconColor: color,
                  label: name,
                  value: '${(ratio * 100).round()}%',
                  ratio: ratio,
                  barColor: color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double ratio;
  final Color barColor;

  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.ratio,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.onSurface,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: ratio.clamp(0.0, 1.0),
                  backgroundColor: barColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 5. FOCUS INSIGHTS ROW
// ══════════════════════════════════════════════════════════════════════════════
class _FocusInsightsRow extends StatelessWidget {
  final StatsViewModel stats;
  const _FocusInsightsRow({required this.stats});

  String _formatFocus(int minutes) =>
      minutes <= 0 ? '0h 0p' : '${minutes ~/ 60}h ${minutes % 60}p';

  String _formatBreak(int minutes) {
    if (minutes <= 0) return '0h 0p';
    return '${minutes ~/ 60}h ${minutes % 60}p';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Chỉ số tập trung',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _InsightTile(
                icon: Icons.psychology_outlined,
                iconColor: _C.tertiary,
                label: 'Tổng thời gian tập trung hôm nay',
                value: _formatFocus(stats.averageFocusMinutes),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InsightTile(
                icon: Icons.coffee_outlined,
                iconColor: _C.secondary,
                label: 'Tổng thời gian nghỉ hôm nay',
                value: _formatBreak(stats.breakMinutes),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InsightTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _glassCard,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _C.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 6. MOTIVATION CARD
// ══════════════════════════════════════════════════════════════════════════════
class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: _C.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn có biết?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _C.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nghỉ ngơi 5 phút sau mỗi 25 phút làm việc giúp tăng 20% hiệu suất não bộ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _C.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double value;
  const _RingPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 4;

    final trackPaint = Paint()
      ..color = _C.secondary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final fillPaint = Paint()
      ..color = _C.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * value.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value;
}

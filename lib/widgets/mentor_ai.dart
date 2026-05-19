import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/voice_nudge_service.dart';

// ─────────────────────────────────────────────
// BUTTON WIDGET
// ─────────────────────────────────────────────
class MentorAiButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final String subtitle;
  final IconData icon;

  const MentorAiButton({
    super.key,
    this.onPressed,
    this.title = 'Phân tích',
    this.subtitle = 'Xem gợi ý tối ưu hiệu suất học tập',
    this.icon = Icons.auto_awesome_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final surface = colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed ?? () => showAiAnalysisSheet(context),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.95),
                primary.withValues(alpha: 0.72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: surface.withValues(alpha: 0.20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 1 — DATE RANGE PICKER DIALOG (styled like code 2)
// ─────────────────────────────────────────────
Future<DateTimeRange?> _showStyledDateRangePicker(BuildContext context) async {
  final now = DateTime.now();
  DateTime? rangeStart;
  DateTime? rangeEnd;
  DateTime displayMonth = DateTime(now.year, now.month);

  return showDialog<DateTimeRange>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final daysInMonth =
            DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
        // weekday of 1st: 1=Mon … 7=Sun, convert to 0-based offset Mon=0
        final firstWeekday = DateTime(displayMonth.year, displayMonth.month, 1).weekday; // 1..7
        final leadingBlanks = firstWeekday - 1; // Mon=0 blanks

        final monthName = _monthName(displayMonth.month);
        final year = displayMonth.year;

        String summaryText = '';
        if (rangeStart != null && rangeEnd != null) {
          summaryText =
              'Báo cáo sẽ tổng hợp từ ngày ${rangeStart!.day} đến ngày ${rangeEnd!.day} tháng ${rangeStart!.month}.';
        } else if (rangeStart != null) {
          summaryText = 'Đã chọn ngày bắt đầu: ${rangeStart!.day}/${rangeStart!.month}.';
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x1AC7C4D7)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6063EE),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4648D4).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chọn thời gian báo cáo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Calendar body ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Month nav
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$monthName, $year',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF191C1E),
                                  ),
                                ),
                                Row(
                                  children: [
                                    _NavButton(
                                      icon: Icons.chevron_left_rounded,
                                      onTap: () => setState(() {
                                        displayMonth = DateTime(
                                            displayMonth.year, displayMonth.month - 1);
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    _NavButton(
                                      icon: Icons.chevron_right_rounded,
                                      onTap: () => setState(() {
                                        displayMonth = DateTime(
                                            displayMonth.year, displayMonth.month + 1);
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Day-of-week header
                            const Row(
                              children: [
                                _DayLabel('T2'),
                                _DayLabel('T3'),
                                _DayLabel('T4'),
                                _DayLabel('T5'),
                                _DayLabel('T6'),
                                _DayLabel('T7'),
                                _DayLabel('CN'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Calendar grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: leadingBlanks + daysInMonth,
                              itemBuilder: (_, index) {
                                if (index < leadingBlanks) {
                                  return const SizedBox.shrink();
                                }
                                final day = index - leadingBlanks + 1;
                                final date = DateTime(
                                    displayMonth.year, displayMonth.month, day);
                                final isStart = rangeStart != null &&
                                    DateUtils.isSameDay(date, rangeStart);
                                final isEnd = rangeEnd != null &&
                                    DateUtils.isSameDay(date, rangeEnd);
                                final inRange = rangeStart != null &&
                                    rangeEnd != null &&
                                    date.isAfter(rangeStart!) &&
                                    date.isBefore(rangeEnd!);
                                final isSelected = isStart || isEnd;

                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (rangeStart == null ||
                                        (rangeStart != null && rangeEnd != null)) {
                                      rangeStart = date;
                                      rangeEnd = null;
                                    } else {
                                      if (date.isBefore(rangeStart!)) {
                                        rangeEnd = rangeStart;
                                        rangeStart = date;
                                      } else {
                                        rangeEnd = date;
                                      }
                                    }
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF4648D4)
                                          : inRange
                                              ? const Color(0xFF4648D4)
                                                  .withValues(alpha: 0.15)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF191C1E),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Summary hint
                      if (summaryText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Color(0xFF4648D4), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                summaryText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF464554),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            side: const BorderSide(color: Color(0xFF767586)),
                            foregroundColor: const Color(0xFF464554),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(null),
                          child: const Text('Hủy',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: const Color(0xFF4648D4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                            shadowColor:
                                const Color(0xFF4648D4).withValues(alpha: 0.4),
                          ),
                          onPressed: rangeStart != null && rangeEnd != null
                              ? () => Navigator.of(ctx).pop(
                                    DateTimeRange(
                                        start: rangeStart!, end: rangeEnd!),
                                  )
                              : null,
                          child: const Text('Tạo báo cáo',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

// ─────────────────────────────────────────────
// STEP 2 — ANALYSIS REPORT DIALOG (styled like code 3)
// ─────────────────────────────────────────────
void _showReportDialog(BuildContext context, _ReportData data) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x1AC7C4D7)),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6063EE),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4648D4).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Báo cáo phân tích',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Distribution donut + legend
                    _SectionHeader('Phân bổ công việc'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: _DonutChart(
                            total: data.totalTasks,
                            work: data.categoryCounts['Công việc'] ?? 0,
                            personal: data.categoryCounts['Cá nhân'] ?? 0,
                            health: data.categoryCounts['Sức khỏe'] ?? 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem(
                                color: const Color(0xFF64A8FE),
                                label: 'Công việc',
                                count: data.categoryCounts['Công việc'] ?? 0,
                              ),
                              const SizedBox(height: 6),
                              _LegendItem(
                                color: const Color(0xFF00885D),
                                label: 'Cá nhân',
                                count: data.categoryCounts['Cá nhân'] ?? 0,
                              ),
                              const SizedBox(height: 6),
                              _LegendItem(
                                color: const Color(0xFF4EDEA3),
                                label: 'Sức khỏe',
                                count: data.categoryCounts['Sức khỏe'] ?? 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Stats grid
                    Row(
                      children: [
                        _StatCard(
                          label: 'TỔNG SỐ',
                          value: '${data.totalTasks}',
                          bg: const Color(0xFFECEEF0),
                          fg: const Color(0xFF4648D4),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'XONG',
                          value: '${data.completedTasks}',
                          bg: const Color(0xFF6FFBBE),
                          fg: const Color(0xFF002113),
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'TRỄ',
                          value: '${data.overdueTasks}',
                          bg: const Color(0xFFFFDAD6),
                          fg: const Color(0xFF93000A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Detailed metrics
                    const SizedBox(height: 12),
                    _SectionHeader('Chi tiết báo cáo'),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Nhiệm vụ quá hạn nhiều nhất'),
                      subtitle: Text(data.topOverdueTitle ?? 'Không có'),
                      trailing: Text('${data.topOverdueMinutes ?? 0} phút'),
                    ),
                    ListTile(
                      title: const Text('Số nhiệm vụ chưa hoàn bị quá hạn'),
                      trailing: Text('${data.incompleteOverdueCount ?? 0}'),
                    ),
                    ListTile(
                      title: const Text('Số nhiệm vụ hoàn trễ (tổng phút)'),
                      subtitle: Text('Số / Tổng phút'),
                      trailing: Text('${data.completedLateCount ?? 0} / ${data.completedLateTotalMinutes ?? 0}'),
                    ),
                    ListTile(
                      title: const Text('Nhiệm vụ hoàn sớm nhất (phút trước hạn)'),
                      subtitle: Text(data.earliestCompletionTitle ?? 'Không có'),
                      trailing: Text('${data.earliestCompletionMinutes ?? 0}'),
                    ),

                    const SizedBox(height: 12),
                    const Divider(),

                    // Section 4: AI Suggestions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4648D4).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4648D4).withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded,
                                  color: Color(0xFF4648D4), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Gợi ý từ Serene AI',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4648D4),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._buildSuggestions(data).map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•',
                                      style: TextStyle(
                                          color: Color(0xFF4648D4),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF464554),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF4648D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor:
                      const Color(0xFF4648D4).withValues(alpha: 0.4),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Đã hiểu',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// MAIN FLOW
// ─────────────────────────────────────────────
Future<void> showAiAnalysisSheet(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || uid.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để xem phân tích.')),
    );
    return;
  }

  final now = DateTime.now();

  // Show styled date range picker
  final picked = await _showStyledDateRangePicker(context);
  if (picked == null) return;

  final periodStart =
      DateTime(picked.start.year, picked.start.month, picked.start.day);
  final periodEnd = DateTime(
      picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

  // Fetch tasks from Firestore
  final tasksSnap = await FirebaseFirestore.instance
      .collection('tasks')
      .where('uid', isEqualTo: uid)
      .get();
  final tasks = tasksSnap.docs.map((d) => d.data()).toList();

  // Filter by period
  final periodTasks = <Map<String, dynamic>>[];
  for (final map in tasks) {
    final dueTs = map['dueAt'] as Timestamp?;
    final completedTs = map['completedAt'] as Timestamp?;
    final due = dueTs?.toDate();
    final completed = completedTs?.toDate();
    final inPeriod =
        (due != null && !due.isBefore(periodStart) && !due.isAfter(periodEnd)) ||
        (completed != null &&
            !completed.isBefore(periodStart) &&
            !completed.isAfter(periodEnd));
    if (inPeriod) periodTasks.add(map);
  }

  if (periodTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Không có báo cáo cho khoảng thời gian đã chọn.')),
    );
    return;
  }

  // Compute metrics
  int completedTasks = 0;
  int overdueTasks = 0;
  int onTimeCount = 0;
  int lateCount = 0;
  int highPriority = 0, mediumPriority = 0, lowPriority = 0;
  int highCompleted = 0, mediumCompleted = 0, lowCompleted = 0;
  final Map<String, int> categoryCounts = {};
  var totalDelayMinutes = 0;

  for (final map in periodTasks) {
    final stat = (map['stat'] as String?) ?? '';
    final priorityRaw = ((map['priority'] as String?) ?? '').toLowerCase();
    final categoryRaw = ((map['category'] as String?) ?? '').toLowerCase();

    if (priorityRaw.contains('cao') || priorityRaw.contains('high')) {
      highPriority++;
    } else if (priorityRaw.contains('thấp') ||
        priorityRaw.contains('thap') ||
        priorityRaw.contains('low')) {
      lowPriority++;
    } else {
      mediumPriority++;
    }

    String catKey;
    if (categoryRaw.contains('cá nhân') ||
        categoryRaw.contains('ca nhan') ||
        categoryRaw.contains('personal') ||
        categoryRaw == 'cá nhân' ||
        categoryRaw == 'canhan') {
      catKey = 'Cá nhân';
    } else if (categoryRaw.contains('sức') ||
        categoryRaw.contains('suc') ||
        categoryRaw.contains('health') ||
        categoryRaw.contains('khỏe') ||
        categoryRaw.contains('khoe')) {
      catKey = 'Sức khỏe';
    } else {
      catKey = 'Công việc';
    }
    categoryCounts[catKey] = (categoryCounts[catKey] ?? 0) + 1;

    final dueTs = map['dueAt'] as Timestamp?;
    final completedTs = map['completedAt'] as Timestamp?;

    final isCompleted = stat.toLowerCase().contains('hoàn') ||
        stat.toLowerCase().contains('hoan') ||
        completedTs != null;
    if (isCompleted) completedTasks++;

    if (!isCompleted && dueTs != null) {
      final due = dueTs.toDate();
      if (due.isBefore(now)) overdueTasks++;
    }

    if (isCompleted && completedTs != null && dueTs != null) {
      final completed = completedTs.toDate();
      final due = dueTs.toDate();
      final diff = completed.difference(due).inMinutes;
      if (diff <= 0) {
        onTimeCount++;
      } else {
        lateCount++;
      }
      totalDelayMinutes += diff > 0 ? diff : 0;
    }

    if (isCompleted) {
      if (priorityRaw.contains('cao') || priorityRaw.contains('high')) {
        highCompleted++;
      } else if (priorityRaw.contains('thấp') ||
          priorityRaw.contains('thap') ||
          priorityRaw.contains('low')) {
        lowCompleted++;
      } else {
        mediumCompleted++;
      }
    }
  }

  final avgDelay =
      lateCount > 0 ? (totalDelayMinutes / lateCount).round() : 0;
  final topCategory = categoryCounts.entries
          .fold<MapEntry<String, int>?>(
              null,
              (prev, e) =>
                  prev == null || e.value > prev.value ? e : prev)
          ?.key ??
      'Không rõ';

  // compute additional details: top overdue, earliest completion, per-category stats
  String topOverdueTitle = 'Không có';
  int topOverdueMinutes = 0;
  int incompleteOverdueCount = 0;
  int completedLateCount = 0;
  int completedLateTotalMinutes = 0;
  String earliestCompletionTitle = 'Không có';
  int earliestCompletionMinutes = 0;
  final Map<String,int> priorityCountsMap = {'high':0,'medium':0,'low':0};
  final Map<String,int> completedByPriorityMap = {'high':0,'medium':0,'low':0};

  for (final map in periodTasks) {
    final title = (map['title'] as String?) ?? 'Untitled';
    final priorityRaw = ((map['priority'] as String?) ?? '').toLowerCase();
    final categoryRaw = ((map['category'] as String?) ?? '').toLowerCase();

    String pKey = 'medium';
    if (priorityRaw.contains('cao') || priorityRaw.contains('high')) pKey = 'high';
    else if (priorityRaw.contains('thấp') || priorityRaw.contains('thap') || priorityRaw.contains('low')) pKey = 'low';
    priorityCountsMap[pKey] = (priorityCountsMap[pKey] ?? 0) + 1;

    final dueTs = map['dueAt'] as Timestamp?;
    final completedTs = map['completedAt'] as Timestamp?;
    final due = dueTs?.toDate();
    final completed = completedTs?.toDate();

    final isCompleted = ((map['stat'] as String?) ?? '').toLowerCase().contains('hoàn') || completed != null;
    if (isCompleted) {
      completedByPriorityMap[pKey] = (completedByPriorityMap[pKey] ?? 0) + 1;
    }

    if (isCompleted && completed != null && due != null) {
      final diff = completed.difference(due).inMinutes;
      if (diff > 0) {
        completedLateCount++;
        completedLateTotalMinutes += diff;
        if (diff > topOverdueMinutes) {
          topOverdueMinutes = diff;
          topOverdueTitle = title;
        }
      } else {
        final earlyMins = due.difference(completed).inMinutes;
        if (earlyMins > earliestCompletionMinutes) {
          earliestCompletionMinutes = earlyMins;
          earliestCompletionTitle = title;
        }
      }
    } else if (!isCompleted && due != null && due.isBefore(now)) {
      final overdueMins = now.difference(due).inMinutes;
      incompleteOverdueCount++;
      if (overdueMins > topOverdueMinutes) {
        topOverdueMinutes = overdueMins;
        topOverdueTitle = title;
      }
    }
  }

  final data = _ReportData(
    totalTasks: periodTasks.length,
    completedTasks: completedTasks,
    overdueTasks: overdueTasks,
    onTimeCount: onTimeCount,
    lateCount: lateCount,
    avgDelayMinutes: avgDelay,
    highPriority: highPriority,
    mediumPriority: mediumPriority,
    lowPriority: lowPriority,
    highCompleted: highCompleted,
    mediumCompleted: mediumCompleted,
    lowCompleted: lowCompleted,
    categoryCounts: categoryCounts,
    topCategory: topCategory,
    topOverdueTitle: topOverdueTitle,
    topOverdueMinutes: topOverdueMinutes,
    incompleteOverdueCount: incompleteOverdueCount,
    completedLateCount: completedLateCount,
    completedLateTotalMinutes: completedLateTotalMinutes,
    earliestCompletionTitle: earliestCompletionTitle,
    earliestCompletionMinutes: earliestCompletionMinutes,
    priorityCountsMap: priorityCountsMap,
    completedByPriorityMap: completedByPriorityMap,
  );
  
  // Try to fetch existing report for this user & period from Firestore
  String? aiNotes;
  Map<String, dynamic>? matchedReport;
  try {
    final reportsSnap = await FirebaseFirestore.instance
        .collection('report')
        .where('uid', isEqualTo: uid)
        .orderBy('generatedAt', descending: true)
        .get();

    for (final d in reportsSnap.docs) {
      final map = d.data();
      final rs = map['periodStart'] as Timestamp?;
      final re = map['periodEnd'] as Timestamp?;
      if (rs == null || re == null) continue;
      final rStart = rs.toDate();
      final rEnd = re.toDate();
      if (!(rEnd.isBefore(periodStart) || rStart.isAfter(periodEnd))) {
        matchedReport = Map<String, dynamic>.from(map);
        aiNotes = (map['notes'] as String?) ?? '';
        if (aiNotes.trim().isEmpty) aiNotes = null;
        break;
      }
    }
  } catch (_) {
    matchedReport = null;
    aiNotes = null;
  }

  // If we found a report document, prefer its stored metrics; otherwise use computed data.
  final finalData = matchedReport != null
      ? _ReportData(
          totalTasks: (matchedReport['totalTasks'] as num?)?.toInt() ?? data.totalTasks,
          completedTasks: (matchedReport['completedTasks'] as num?)?.toInt() ?? data.completedTasks,
          overdueTasks: (matchedReport['overdueTasks'] as num?)?.toInt() ?? data.overdueTasks,
          onTimeCount: (matchedReport['onTimeCount'] as num?)?.toInt() ?? data.onTimeCount,
          lateCount: (matchedReport['lateCount'] as num?)?.toInt() ?? data.lateCount,
          avgDelayMinutes: (matchedReport['avgDelayMinutes'] as num?)?.toInt() ?? data.avgDelayMinutes,
          highPriority: (matchedReport['priorityCounts'] as Map?)?.cast<String, dynamic>()['high'] is int
              ? ((matchedReport['priorityCounts'] as Map).cast<String, dynamic>()['high'] as num).toInt()
              : (matchedReport['priorityCounts'] as Map?)?.cast<String, dynamic>()['high']?.toInt() ?? data.highPriority,
          mediumPriority: (matchedReport['priorityCounts'] as Map?)?.cast<String, dynamic>()['medium']?.toInt() ?? data.mediumPriority,
          lowPriority: (matchedReport['priorityCounts'] as Map?)?.cast<String, dynamic>()['low']?.toInt() ?? data.lowPriority,
          highCompleted: (matchedReport['completedByPriority'] as Map?)?.cast<String, dynamic>()['high']?.toInt() ?? data.highCompleted,
          mediumCompleted: (matchedReport['completedByPriority'] as Map?)?.cast<String, dynamic>()['medium']?.toInt() ?? data.mediumCompleted,
          lowCompleted: (matchedReport['completedByPriority'] as Map?)?.cast<String, dynamic>()['low']?.toInt() ?? data.lowCompleted,
          categoryCounts: (matchedReport['categoryCounts'] as Map?)?.cast<String, dynamic>().map((k, v) => MapEntry(k, (v as num).toInt())) ?? data.categoryCounts,
          topCategory: (matchedReport['topCategory'] as String?) ?? data.topCategory,
          aiNotes: aiNotes,
        )
      : data.copyWith(aiNotes: aiNotes);

  _showReportDialog(context, finalData);
}



// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────
class _ReportData {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int onTimeCount;
  final int lateCount;
  final int avgDelayMinutes;
  final int highPriority, mediumPriority, lowPriority;
  final int highCompleted, mediumCompleted, lowCompleted;
  final Map<String, int> categoryCounts;
  final String topCategory;
  final String? aiNotes;
  final String? topOverdueTitle;
  final int? topOverdueMinutes;
  final int? incompleteOverdueCount;
  final int? completedLateCount;
  final int? completedLateTotalMinutes;
  final String? earliestCompletionTitle;
  final int? earliestCompletionMinutes;
  final Map<String,int>? priorityCountsMap;
  final Map<String,int>? completedByPriorityMap;

  const _ReportData({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.onTimeCount,
    required this.lateCount,
    required this.avgDelayMinutes,
    required this.highPriority,
    required this.mediumPriority,
    required this.lowPriority,
    required this.highCompleted,
    required this.mediumCompleted,
    required this.lowCompleted,
    required this.categoryCounts,
    required this.topCategory,
    this.aiNotes,
    this.topOverdueTitle,
    this.topOverdueMinutes,
    this.incompleteOverdueCount,
    this.completedLateCount,
    this.completedLateTotalMinutes,
    this.earliestCompletionTitle,
    this.earliestCompletionMinutes,
    this.priorityCountsMap,
    this.completedByPriorityMap,
  });

  _ReportData copyWith({String? aiNotes}) {
    return _ReportData(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      onTimeCount: onTimeCount,
      lateCount: lateCount,
      avgDelayMinutes: avgDelayMinutes,
      highPriority: highPriority,
      mediumPriority: mediumPriority,
      lowPriority: lowPriority,
      highCompleted: highCompleted,
      mediumCompleted: mediumCompleted,
      lowCompleted: lowCompleted,
      categoryCounts: categoryCounts,
      topCategory: topCategory,
      aiNotes: aiNotes ?? this.aiNotes,
      topOverdueTitle: topOverdueTitle,
      topOverdueMinutes: topOverdueMinutes,
      incompleteOverdueCount: incompleteOverdueCount,
      completedLateCount: completedLateCount,
      completedLateTotalMinutes: completedLateTotalMinutes,
      earliestCompletionTitle: earliestCompletionTitle,
      earliestCompletionMinutes: earliestCompletionMinutes,
      priorityCountsMap: priorityCountsMap,
      completedByPriorityMap: completedByPriorityMap,
    );
  }
}

// ─────────────────────────────────────────────
// HELPERS — suggestions builder
// ─────────────────────────────────────────────
List<String> _buildSuggestions(_ReportData d) {
  // If Firestore provided aiNotes, prefer them (split into lines)
  if (d.aiNotes != null && d.aiNotes!.trim().isNotEmpty) {
    return d.aiNotes!.trim().split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
  final pct = d.totalTasks > 0
      ? ((d.completedTasks / d.totalTasks) * 100).round()
      : 0;
  final suggestions = <String>[];

  suggestions.add(
      'Tỷ lệ hoàn thành đạt $pct%. ${pct >= 70 ? "Bạn đang duy trì tiến độ khá tốt!" : "Hãy cố gắng hoàn thành thêm nhiệm vụ."}');

  if (d.overdueTasks > 0) {
    suggestions
        .add('Xu hướng trễ hạn xuất hiện ở nhóm ${d.topCategory}. Cần ưu tiên xử lý ${ d.overdueTasks} nhiệm vụ quá hạn.');
  }

  suggestions.add(_categoryComment(d.topCategory));
  suggestions.add(
      'Hãy ưu tiên các nhiệm vụ quan trọng vào buổi sáng để tối ưu sự tập trung.');

  return suggestions;
}

String _categoryComment(String topCategory) {
  switch (topCategory) {
    case 'Cá nhân':
      return 'Nhận định: Phần lớn nhiệm vụ của bạn thuộc "Cá nhân" — bạn dành nhiều thời gian cho cuộc sống riêng và chăm sóc bản thân.\n\nĐánh giá: Đây là dấu hiệu tích cực cho sức khỏe và cân bằng cuộc sống nếu công việc không bị bỏ sót; nếu công việc nghề nghiệp đang tụt hậu thì cần điều chỉnh.\n\nĐề xuất (3 bước cụ thể):\n1) Thiết lập 1 khung thời gian cố định/tuần cho việc cá nhân (ví dụ: Chủ nhật sáng 60 phút).\n   - Bước: Ghi vào lịch và đánh dấu là bất khả xâm phạm.\n2) Chọn 2–3 nhiệm vụ cá nhân quan trọng mỗi tuần và hoàn thành trước cuối tuần.\n   - Bước: Dùng tag "Quan trọng" và sắp xếp vào đầu danh sách.\n3) Gom các việc nhỏ thành 1 khối làm cùng nhau để tiết kiệm thời gian.\n\nKết: Giữ thói quen này, nhưng kiểm tra xem nó có ảnh hưởng đến mục tiêu nghề nghiệp không và điều chỉnh khi cần.';
    case 'Sức khỏe':
      return 'Nhận định: Phần lớn nhiệm vụ thuộc "Sức khỏe" — bạn đang ưu tiên chăm sóc sức khỏe, một thói quen rất có lợi dài hạn.\n\nĐánh giá: Rất tốt cho sức khỏe thể chất và tinh thần; chỉ cần đảm bảo không ảnh hưởng quá nhiều tới các trách nhiệm quan trọng khác.\n\nĐề xuất (3 bước cụ thể):\n1) Duy trì một khung nhỏ (30–60 phút) mỗi ngày và đặt lịch cố định.\n   - Bước: Đặt nhắc và đánh dấu là không thể hủy trong lịch cá nhân.\n2) Ghi lại tiến trình hàng tuần (ví dụ 3 buổi/tuần) để theo dõi.\n   - Bước: Dùng một mục nhỏ trong app để ghi kết quả.\n3) Nếu lịch bận, điều chỉnh sang buổi sáng/nghỉ trưa để đảm bảo tính đều đặn.\n\nKết: Tiếp tục duy trì — đây là đầu tư dài hạn cho năng lượng và tinh thần của bạn.';
    case 'Công việc':
      return 'Nhận định: Phần lớn nhiệm vụ của bạn thuộc "Công việc" — bạn có xu hướng ưu tiên công việc và hoàn thành nhiều nhiệm vụ liên quan nghề nghiệp.\n\nĐánh giá: Giúp tiến tới mục tiêu nghề nghiệp nhưng có nguy cơ kiệt sức hoặc bỏ lỡ thời gian cá nhân nếu kéo dài.\n\nĐề xuất (3 bước cụ thể):\n1) Áp dụng "timeboxing": chia ngày làm việc thành khung giờ tập trung và khung nghỉ.\n   - Bước: Đặt 2–3 khung 45–90 phút cho công việc quan trọng mỗi ngày.\n2) Chọn 3 nhiệm vụ quan trọng nhất mỗi ngày và hoàn thành trước buổi trưa.\n   - Bước: Đánh dấu trong danh sách và khóa thời gian để thực hiện.\n3) Ủy thác hoặc gom các nhiệm vụ lặp lại để giảm tải.\n\nKết: Tốt cho năng suất nhưng cần chủ động nghỉ ngơi để tránh kiệt sức.';
    default:
      return 'Nhận định: Loại ưu tiên nhất: $topCategory.\n\nĐánh giá: Hãy xem xét liệu việc ưu tiên này phù hợp với mục tiêu dài hạn của bạn hay không; cân bằng có thể giúp cải thiện cuộc sống và hiệu suất.\n\nĐề xuất (3 bước cụ thể):\n1) Đặt mục tiêu rõ ràng cho mỗi loại và đánh dấu mức ưu tiên.\n   - Bước: Dùng tag và thời hạn để phân loại.\n2) Dành khối thời gian hàng tuần cho từng loại nhiệm vụ.\n   - Bước: Lên lịch 30–60 phút mỗi ngày cho loại ít được ưu tiên.\n3) Thử Pomodoro hoặc timeboxing để tăng hiệu suất.\n\nKết: Điều chỉnh dần theo tuần, đánh giá lại kết quả.';
  }
}

String _monthName(int month) {
  const names = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];
  return names[month];
}

// ─────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: const Color(0xFF464554), size: 22),
      );
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF464554),
            ),
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF464554),
          letterSpacing: 0.8,
        ),
      );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF464554)),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191C1E),
            ),
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.bg,
      required this.fg});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: fg),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF464554),
                    letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _DonutChart extends StatelessWidget {
  final int total;
  final int work;
  final int personal;
  final int health;
  const _DonutChart(
      {required this.total,
      required this.work,
      required this.personal,
      required this.health});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(64, 64),
          painter: _DonutPainter(
            segments: total > 0
                ? [
                    _DonutSegment(work / total, const Color(0xFF64A8FE)),
                    _DonutSegment(personal / total, const Color(0xFF00885D)),
                    _DonutSegment(health / total, const Color(0xFF4EDEA3)),
                  ]
                : [_DonutSegment(1.0, const Color(0xFFECEEF0))],
          ),
        ),
        Text(
          '$total',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191C1E),
          ),
        ),
      ],
    );
  }
}

class _DonutSegment {
  final double fraction;
  final Color color;
  const _DonutSegment(this.fraction, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    var startAngle = -3.14159 / 2;
    const strokeW = 7.0;

    for (final seg in segments) {
      final sweepAngle = 2 * 3.14159 * seg.fraction;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - 0.04,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
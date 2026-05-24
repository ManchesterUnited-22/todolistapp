import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_app/screens/charts/charts_colors.dart';
import 'package:smart_app/screens/charts/charts_ring_painter.dart';
import 'package:smart_app/screens/charts/widgets/charts_distribution_section.dart';
import 'package:smart_app/views/stats_viewmodel.dart';
import 'package:smart_app/views/task_viewmodel.dart';

import 'analysis/diagram_analysis_section.dart';

enum VoiceDiagramPeriod { day, week, month, year }

class VoiceDiagramRequest {
  final VoiceDiagramPeriod period;
  final DateTime anchorDate;
  final String label;
  final String sourceText;

  const VoiceDiagramRequest({
    required this.period,
    required this.anchorDate,
    required this.label,
    required this.sourceText,
  });

  bool get showPerformanceChart => period != VoiceDiagramPeriod.day;

  DateTimeRange get range {
    switch (period) {
      case VoiceDiagramPeriod.day:
        final start = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
        );
      case VoiceDiagramPeriod.week:
        final start = _startOfWeek(anchorDate);
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1)),
        );
      case VoiceDiagramPeriod.month:
        final start = DateTime(anchorDate.year, anchorDate.month, 1);
        final end = DateTime(anchorDate.year, anchorDate.month + 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      case VoiceDiagramPeriod.year:
        final start = DateTime(anchorDate.year, 1, 1);
        final end = DateTime(anchorDate.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
    }
  }

  static VoiceDiagramRequest fromVoiceIntent(
    String transcript, {
    Map<String, dynamic>? params,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final raw = transcript.trim();
    final lower = raw.toLowerCase();
    final normalizedParams = params ?? const <String, dynamic>{};

    final requestedPeriod = _parsePeriod(normalizedParams, lower);
    final anchor = _parseAnchorDate(normalizedParams, lower, current, requestedPeriod);
    final label = _buildLabel(normalizedParams, lower, requestedPeriod, anchor);

    return VoiceDiagramRequest(
      period: requestedPeriod,
      anchorDate: anchor,
      label: label,
      sourceText: raw,
    );
  }
}

Future<void> openVoiceDiagram(
  BuildContext context,
  VoiceDiagramRequest request,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VoiceDiagramPage(request: request),
    ),
  );
}

class VoiceDiagramPage extends StatelessWidget {
  final VoiceDiagramRequest request;

  const VoiceDiagramPage({super.key, required this.request});

  String get _title {
    switch (request.period) {
      case VoiceDiagramPeriod.day:
        return 'Biểu đồ ngày';
      case VoiceDiagramPeriod.week:
        return 'Biểu đồ tuần';
      case VoiceDiagramPeriod.month:
        return 'Biểu đồ tháng';
      case VoiceDiagramPeriod.year:
        return 'Biểu đồ năm';
    }
  }

  String get _subtitle {
    final range = request.range;
    final formatter = DateFormat('dd/MM/yyyy');
    switch (request.period) {
      case VoiceDiagramPeriod.day:
        return request.label;
      case VoiceDiagramPeriod.week:
      case VoiceDiagramPeriod.month:
      case VoiceDiagramPeriod.year:
        return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: ChartsColors.background,
      appBar: AppBar(
        backgroundColor: ChartsColors.surface.withValues(alpha: 0.80),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ChartsColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: uid.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vui lòng đăng nhập để xem biểu đồ.',
                  style: TextStyle(
                    color: ChartsColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

                final allTasks = snapshot.data!.docs
                    .map((doc) => TaskViewModel.fromMap(doc.data()))
                    .toList();
                final filteredTasks = allTasks.where((task) {
                  final anchor = _taskAnchor(task);
                  if (anchor == null) return false;
                  return !anchor.isBefore(request.range.start) &&
                      !anchor.isAfter(request.range.end);
                }).toList();

                final stats = StatsViewModel.fromTasks(uid: uid, tasks: filteredTasks);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (request.showPerformanceChart) ...[
                        _CompletionRateCard(stats: stats, subtitle: _subtitle),
                        const SizedBox(height: 20),
                        _buildPerformanceSection(filteredTasks),
                        const SizedBox(height: 20),
                      ],
                      ChartsDistributionSection(stats: stats),
                      DiagramAnalysisSectionLoader(
                        uid: uid,
                        range: request.range,
                        rangeLabel: request.label,
                        tasks: filteredTasks,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPerformanceSection(List<TaskViewModel> tasks) {
    switch (request.period) {
      case VoiceDiagramPeriod.day:
        return const SizedBox.shrink();
      case VoiceDiagramPeriod.week:
        return _WeeklyPerformanceChart(
          tasks: tasks,
          rangeStart: request.range.start,
          title: 'Hiệu suất tuần',
          subtitle: request.label,
        );
      case VoiceDiagramPeriod.month:
        return _MonthlyPerformanceOverview(
          tasks: tasks,
          monthAnchor: request.anchorDate,
          subtitle: request.label,
        );
      case VoiceDiagramPeriod.year:
        return _YearlyPerformanceChart(
          tasks: tasks,
          yearAnchor: request.anchorDate,
          subtitle: request.label,
        );
    }
  }
}

class _CompletionRateCard extends StatelessWidget {
  final StatsViewModel stats;
  final String subtitle;

  const _CompletionRateCard({required this.stats, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final completionPct = (stats.completionRate * 100).round();

    return Container(
      decoration: glassCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: CustomPaint(
              painter: ChartsRingPainter(value: stats.completionRate),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tỷ lệ hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: ChartsColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '$completionPct%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ChartsColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ChartsColors.onSurfaceVariant,
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

class _WeeklyPerformanceChart extends StatelessWidget {
  final List<TaskViewModel> tasks;
  final DateTime rangeStart;
  final String title;
  final String subtitle;

  const _WeeklyPerformanceChart({
    required this.tasks,
    required this.rangeStart,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (index) => rangeStart.add(Duration(days: index)));
    final buckets = days.map((day) {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      final dayTasks = tasks.where((task) {
        final anchor = _taskAnchor(task);
        return anchor != null && !anchor.isBefore(dayStart) && !anchor.isAfter(dayEnd);
      }).toList();
      return _PerformanceBucket(
        label: DateFormat('dd').format(day),
        total: dayTasks.length,
        completed: dayTasks.where((task) => task.stat == 'Hoàn thành').length,
      );
    }).toList();

    return _PerformanceCard(
      title: title,
      subtitle: subtitle,
      buckets: buckets,
      compact: false,
    );
  }
}

class _MonthlyPerformanceOverview extends StatelessWidget {
  final List<TaskViewModel> tasks;
  final DateTime monthAnchor;
  final String subtitle;

  const _MonthlyPerformanceOverview({
    required this.tasks,
    required this.monthAnchor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final monthEnd = DateTime(monthAnchor.year, monthAnchor.month + 1, 1).subtract(const Duration(milliseconds: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(4, (weekIndex) {
        final weekStart = monthStart.add(Duration(days: weekIndex * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final clippedStart = weekStart.isBefore(monthStart) ? monthStart : weekStart;
        final clippedEnd = weekEnd.isAfter(monthEnd) ? monthEnd : weekEnd;
        final buckets = List.generate(7, (dayIndex) {
          final day = weekStart.add(Duration(days: dayIndex));
          final dayStart = DateTime(day.year, day.month, day.day);
          final dayEnd = dayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
          final dayTasks = tasks.where((task) {
            final anchor = _taskAnchor(task);
            return anchor != null && !anchor.isBefore(dayStart) && !anchor.isAfter(dayEnd);
          }).toList();
          return _PerformanceBucket(
            label: day.day.toString(),
            total: dayTasks.length,
            completed: dayTasks.where((task) => task.stat == 'Hoàn thành').length,
          );
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PerformanceCard(
            title: 'Tuần ${weekIndex + 1}',
            subtitle: '${DateFormat('dd/MM').format(clippedStart)} - ${DateFormat('dd/MM').format(clippedEnd)} • $subtitle',
            buckets: buckets,
            compact: true,
          ),
        );
      }),
    );
  }
}

class _YearlyPerformanceChart extends StatelessWidget {
  final List<TaskViewModel> tasks;
  final DateTime yearAnchor;
  final String subtitle;

  const _YearlyPerformanceChart({
    required this.tasks,
    required this.yearAnchor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final buckets = List.generate(12, (monthIndex) {
      final month = DateTime(yearAnchor.year, monthIndex + 1, 1);
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 1).subtract(const Duration(milliseconds: 1));
      final monthTasks = tasks.where((task) {
        final anchor = _taskAnchor(task);
        return anchor != null && !anchor.isBefore(monthStart) && !anchor.isAfter(monthEnd);
      }).toList();
      return _PerformanceBucket(
        label: 'T${monthIndex + 1}',
        total: monthTasks.length,
        completed: monthTasks.where((task) => task.stat == 'Hoàn thành').length,
      );
    });

    return _PerformanceCard(
      title: 'Hiệu suất theo tháng',
      subtitle: subtitle,
      buckets: buckets,
      compact: false,
      barWidth: 18,
      showMonthLabels: true,
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_PerformanceBucket> buckets;
  final bool compact;
  final double barWidth;
  final bool showMonthLabels;

  const _PerformanceCard({
    required this.title,
    required this.subtitle,
    required this.buckets,
    required this.compact,
    this.barWidth = 14,
    this.showMonthLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxRatio = buckets.fold<double>(0.0, (maxValue, bucket) {
      return math.max(maxValue, bucket.ratio);
    }).clamp(0.2, 1.0);

    return Container(
      decoration: glassCard,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ChartsColors.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: ChartsColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: compact ? 180 : 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: buckets.map((bucket) {
                final ratio = bucket.ratio;
                final heightFactor = maxRatio > 0 ? (ratio / maxRatio) : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: math.max(heightFactor, 0.05),
                              child: Container(
                                width: barWidth,
                                decoration: BoxDecoration(
                                  color: bucket.color,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bucket.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ChartsColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(bucket.ratio * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ChartsColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (showMonthLabels) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: buckets
                  .map(
                    (bucket) => Chip(
                      label: Text(bucket.label),
                      backgroundColor: bucket.color.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: bucket.color,
                        fontWeight: FontWeight.w600,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformanceBucket {
  final String label;
  final int total;
  final int completed;

  const _PerformanceBucket({
    required this.label,
    required this.total,
    required this.completed,
  });

  double get ratio => total == 0 ? 0 : completed / total;

  Color get color {
    if (ratio >= 0.85) return ChartsColors.tertiary;
    if (ratio >= 0.5) return ChartsColors.primaryContainer;
    return ChartsColors.secondary;
  }
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

VoiceDiagramPeriod _parsePeriod(
  Map<String, dynamic> params,
  String lowerText,
) {
  final rawRange = _stringParam(params, const ['rangeType', 'range', 'period', 'timeRange']);
  final normalized = rawRange?.toLowerCase().trim() ?? '';
  if (normalized.isNotEmpty) {
    switch (normalized) {
      case 'day':
      case 'date':
        return VoiceDiagramPeriod.day;
      case 'week':
        return VoiceDiagramPeriod.week;
      case 'month':
        return VoiceDiagramPeriod.month;
      case 'year':
        return VoiceDiagramPeriod.year;
    }
  }

  if (lowerText.contains('năm')) return VoiceDiagramPeriod.year;
  if (lowerText.contains('tháng')) return VoiceDiagramPeriod.month;
  if (lowerText.contains('tuần')) return VoiceDiagramPeriod.week;
  if (lowerText.contains('ngày') || lowerText.contains('hôm nay') || lowerText.contains('hôm qua') || lowerText.contains('ngày mai')) {
    return VoiceDiagramPeriod.day;
  }

  return VoiceDiagramPeriod.week;
}

DateTime _parseAnchorDate(
  Map<String, dynamic> params,
  String lowerText,
  DateTime now,
  VoiceDiagramPeriod period,
) {
  final explicit = _stringParam(params, const ['anchorDate', 'anchor', 'date', 'dateString']);
  if (explicit != null && explicit.trim().isNotEmpty) {
    final parsed = _parseDateString(explicit.trim(), now);
    if (parsed != null) return parsed;
  }

  if (lowerText.contains('hôm qua')) return now.subtract(const Duration(days: 1));
  if (lowerText.contains('ngày mai')) return now.add(const Duration(days: 1));
  if (lowerText.contains('hôm nay')) return now;

  if (lowerText.contains('tuần trước')) return now.subtract(const Duration(days: 7));
  if (lowerText.contains('tuần sau')) return now.add(const Duration(days: 7));

  if (lowerText.contains('tháng trước')) return DateTime(now.year, now.month - 1, 1);
  if (lowerText.contains('tháng sau')) return DateTime(now.year, now.month + 1, 1);

  if (lowerText.contains('năm ngoái')) return DateTime(now.year - 1, 1, 1);
  if (lowerText.contains('năm sau')) return DateTime(now.year + 1, 1, 1);

  final dateMatch = RegExp(r'(\d{1,2}[\/-]\d{1,2}(?:[\/-]\d{2,4})?)').firstMatch(lowerText);
  if (dateMatch != null) {
    final parsed = _parseDateString(dateMatch.group(0)!, now);
    if (parsed != null) return parsed;
  }

  final monthMatch = RegExp(r'tháng\s*(\d{1,2})(?:\s*năm\s*(\d{4}))?').firstMatch(lowerText);
  if (monthMatch != null) {
    final month = int.tryParse(monthMatch.group(1) ?? '') ?? now.month;
    final year = int.tryParse(monthMatch.group(2) ?? '') ?? now.year;
    return DateTime(year, month, 1);
  }

  final yearMatch = RegExp(r'năm\s*(\d{4})').firstMatch(lowerText);
  if (yearMatch != null) {
    final year = int.tryParse(yearMatch.group(1) ?? '') ?? now.year;
    return DateTime(year, 1, 1);
  }

  switch (period) {
    case VoiceDiagramPeriod.day:
      return now;
    case VoiceDiagramPeriod.week:
      return now;
    case VoiceDiagramPeriod.month:
      return DateTime(now.year, now.month, 1);
    case VoiceDiagramPeriod.year:
      return DateTime(now.year, 1, 1);
  }
}

String _buildLabel(
  Map<String, dynamic> params,
  String lowerText,
  VoiceDiagramPeriod period,
  DateTime anchor,
) {
  final explicit = _stringParam(params, const ['label', 'title']);
  if (explicit != null && explicit.trim().isNotEmpty) return explicit.trim();

  if (lowerText.contains('hôm qua')) return 'Hôm qua';
  if (lowerText.contains('hôm nay')) return 'Hôm nay';
  if (lowerText.contains('ngày mai')) return 'Ngày mai';
  if (lowerText.contains('tuần trước')) return 'Tuần trước';
  if (lowerText.contains('tuần này')) return 'Tuần này';
  if (lowerText.contains('tuần sau')) return 'Tuần sau';
  if (lowerText.contains('tháng trước')) return 'Tháng trước';
  if (lowerText.contains('tháng này')) return 'Tháng này';
  if (lowerText.contains('tháng sau')) return 'Tháng sau';
  if (lowerText.contains('năm ngoái')) return 'Năm ngoái';
  if (lowerText.contains('năm nay')) return 'Năm nay';
  if (lowerText.contains('năm sau')) return 'Năm sau';

  switch (period) {
    case VoiceDiagramPeriod.day:
      return DateFormat('dd/MM/yyyy').format(anchor);
    case VoiceDiagramPeriod.week:
      return 'Tuần ${DateFormat('dd/MM/yyyy').format(_startOfWeek(anchor))}';
    case VoiceDiagramPeriod.month:
      return DateFormat('MM/yyyy').format(anchor);
    case VoiceDiagramPeriod.year:
      return DateFormat('yyyy').format(anchor);
  }
}

String? _stringParam(Map<String, dynamic> params, List<String> keys) {
  for (final key in keys) {
    final value = params[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  return null;
}

DateTime? _parseDateString(String value, DateTime fallbackNow) {
  final cleaned = value.replaceAll('/', '-').trim();
  final parts = cleaned.split('-');
  if (parts.length < 2) return DateTime.tryParse(cleaned);

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (day == null || month == null) return DateTime.tryParse(cleaned);

  int year = fallbackNow.year;
  if (parts.length >= 3) {
    final rawYear = parts[2];
    year = rawYear.length == 2
        ? int.tryParse('20$rawYear') ?? fallbackNow.year
        : int.tryParse(rawYear) ?? fallbackNow.year;
  }

  return DateTime(year, month, day);
}

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

  final dateString = task.dateString?.trim();
  if (dateString == null || dateString.isEmpty) return null;

  return _parseDateString(dateString, DateTime.now());
}

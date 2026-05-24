import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_app/services/report_service.dart';
import 'package:smart_app/views/report_viewmodel.dart';
import 'package:smart_app/views/task_viewmodel.dart';

class DiagramAnalysisResult {
  final ReportViewModel report;
  final List<String> suggestions;
  final String rangeLabel;
  final DateTimeRange range;

  const DiagramAnalysisResult({
    required this.report,
    required this.suggestions,
    required this.rangeLabel,
    required this.range,
  });
}

class DiagramAnalysisService {
  DiagramAnalysisService._();
  static final DiagramAnalysisService instance = DiagramAnalysisService._();

  Future<DiagramAnalysisResult> buildAndStore({
    required String uid,
    required DateTimeRange range,
    required String rangeLabel,
    required List<TaskViewModel> tasks,
  }) async {
    final now = DateTime.now();
    final report = _buildReport(
      uid: uid,
      range: range,
      tasks: tasks,
      generatedAt: now,
    );
    final suggestions = _buildSuggestions(report);
    final enrichedReport = _withNotes(report, suggestions.join('\n'));

    await ReportService.instance.saveReport(
      enrichedReport,
      docId: _reportDocId(uid, range),
    );

    return DiagramAnalysisResult(
      report: enrichedReport,
      suggestions: suggestions,
      rangeLabel: rangeLabel,
      range: range,
    );
  }

  ReportViewModel _buildReport({
    required String uid,
    required DateTimeRange range,
    required List<TaskViewModel> tasks,
    required DateTime generatedAt,
  }) {
    int completedTasks = 0;
    int overdueTasks = 0;
    int onTimeCount = 0;
    int lateCount = 0;
    int totalDelayMinutes = 0;

    int highPriority = 0;
    int mediumPriority = 0;
    int lowPriority = 0;
    int highCompleted = 0;
    int mediumCompleted = 0;
    int lowCompleted = 0;

    final Map<String, int> categoryCounts = {};
    final Map<String, ReportCategoryStat> categoryStats = {};

    String topOverdueTitle = 'Không có';
    int topOverdueMinutes = 0;
    int incompleteOverdueCount = 0;
    int completedLateCount = 0;
    int completedLateTotalMinutes = 0;
    String earliestCompletionTitle = 'Không có';
    int earliestCompletionMinutes = 0;

    for (final task in tasks) {
      final priorityRaw = (task.priority ?? '').toLowerCase();
      final categoryRaw = task.category.trim().isEmpty ? 'Khác' : task.category.trim();
      final due = task.dueAt?.toDate();
      final completed = task.completedAt?.toDate();
      final isCompleted = task.stat.toLowerCase().contains('hoàn') ||
          task.stat.toLowerCase().contains('hoan') ||
          completed != null;

      final priorityKey = _priorityKey(priorityRaw);
      switch (priorityKey) {
        case 'high':
          highPriority++;
          break;
        case 'low':
          lowPriority++;
          break;
        default:
          mediumPriority++;
          break;
      }

      categoryCounts[categoryRaw] = (categoryCounts[categoryRaw] ?? 0) + 1;
      categoryStats.putIfAbsent(
        categoryRaw,
        () => ReportCategoryStat(
          name: categoryRaw,
          count: 0,
          overdueCount: 0,
          lateCount: 0,
          overdueMinutes: 0,
        ),
      );
      categoryStats[categoryRaw] = ReportCategoryStat(
        name: categoryRaw,
        count: categoryStats[categoryRaw]!.count + 1,
        overdueCount: categoryStats[categoryRaw]!.overdueCount,
        lateCount: categoryStats[categoryRaw]!.lateCount,
        overdueMinutes: categoryStats[categoryRaw]!.overdueMinutes,
      );

      if (isCompleted) {
        completedTasks++;
        switch (priorityKey) {
          case 'high':
            highCompleted++;
            break;
          case 'low':
            lowCompleted++;
            break;
          default:
            mediumCompleted++;
            break;
        }
      }

      if (isCompleted && completed != null && due != null) {
        final diff = completed.difference(due).inMinutes;
        if (diff <= 0) {
          onTimeCount++;
          final earlyMins = due.difference(completed).inMinutes;
          if (earlyMins > 0 && earlyMins > earliestCompletionMinutes) {
            earliestCompletionMinutes = earlyMins;
            earliestCompletionTitle = task.title;
          }
        } else {
          lateCount++;
          totalDelayMinutes += diff;
          completedLateCount++;
          completedLateTotalMinutes += diff;
          final cs = categoryStats[categoryRaw]!;
          categoryStats[categoryRaw] = ReportCategoryStat(
            name: cs.name,
            count: cs.count,
            overdueCount: cs.overdueCount,
            lateCount: cs.lateCount + 1,
            overdueMinutes: cs.overdueMinutes + diff,
          );
          if (diff > topOverdueMinutes) {
            topOverdueMinutes = diff;
            topOverdueTitle = task.title;
          }
        }
      } else if (!isCompleted && due != null && due.isBefore(DateTime.now())) {
        final overdueMins = DateTime.now().difference(due).inMinutes;
        overdueTasks++;
        incompleteOverdueCount++;
        final cs = categoryStats[categoryRaw]!;
        categoryStats[categoryRaw] = ReportCategoryStat(
          name: cs.name,
          count: cs.count,
          overdueCount: cs.overdueCount + 1,
          lateCount: cs.lateCount,
          overdueMinutes: cs.overdueMinutes + overdueMins,
        );
        if (overdueMins > topOverdueMinutes) {
          topOverdueMinutes = overdueMins;
          topOverdueTitle = task.title;
        }
      }
    }

    final avgDelay = lateCount > 0 ? (totalDelayMinutes / lateCount).round() : 0;
    final topCategory = categoryCounts.entries
            .fold<MapEntry<String, int>?>(
              null,
              (prev, entry) => prev == null || entry.value > prev.value ? entry : prev,
            )
            ?.key ??
        'Không rõ';

    return ReportViewModel(
      uid: uid,
      periodStart: Timestamp.fromDate(range.start),
      periodEnd: Timestamp.fromDate(range.end),
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      onTimeCount: onTimeCount,
      lateCount: lateCount,
      avgDelayMinutes: avgDelay,
      priorityCounts: {'high': highPriority, 'medium': mediumPriority, 'low': lowPriority},
      completedByPriority: {'high': highCompleted, 'medium': mediumCompleted, 'low': lowCompleted},
      categoryCounts: categoryCounts,
      topCategory: topCategory,
      topOverdueTitle: topOverdueTitle,
      topOverdueMinutes: topOverdueMinutes,
      incompleteOverdueCount: incompleteOverdueCount,
      completedLateCount: completedLateCount,
      completedLateTotalMinutes: completedLateTotalMinutes,
      earliestCompletionTitle: earliestCompletionTitle,
      earliestCompletionMinutes: earliestCompletionMinutes,
      categoryStats: categoryStats,
      notes: '',
      generatedAt: Timestamp.fromDate(generatedAt),
    );
  }

  ReportViewModel _withNotes(ReportViewModel report, String notes) {
    return ReportViewModel(
      id: report.id,
      uid: report.uid,
      periodStart: report.periodStart,
      periodEnd: report.periodEnd,
      totalTasks: report.totalTasks,
      completedTasks: report.completedTasks,
      overdueTasks: report.overdueTasks,
      onTimeCount: report.onTimeCount,
      lateCount: report.lateCount,
      avgDelayMinutes: report.avgDelayMinutes,
      priorityCounts: report.priorityCounts,
      completedByPriority: report.completedByPriority,
      categoryCounts: report.categoryCounts,
      topCategory: report.topCategory,
      topOverdueTitle: report.topOverdueTitle,
      topOverdueMinutes: report.topOverdueMinutes,
      incompleteOverdueCount: report.incompleteOverdueCount,
      completedLateCount: report.completedLateCount,
      completedLateTotalMinutes: report.completedLateTotalMinutes,
      earliestCompletionTitle: report.earliestCompletionTitle,
      earliestCompletionMinutes: report.earliestCompletionMinutes,
      categoryStats: report.categoryStats,
      notes: notes,
      generatedAt: report.generatedAt,
      updatedAt: report.updatedAt,
    );
  }

  List<String> _buildSuggestions(ReportViewModel report) {
    final completionPct = report.totalTasks > 0
        ? ((report.completedTasks / report.totalTasks) * 100).round()
        : 0;

    final suggestions = <String>[
      'Tỷ lệ hoàn thành đạt $completionPct% trong mốc đã chọn.',
    ];

    if (report.overdueTasks > 0) {
      suggestions.add(
        'Có ${report.overdueTasks} nhiệm vụ quá hạn, nên ưu tiên xử lý nhóm ${report.topCategory}.',
      );
    } else {
      suggestions.add('Không ghi nhận quá hạn trong phạm vi này.');
    }

    suggestions.add(
      'Nhiệm vụ nổi bật: ${report.topOverdueTitle == 'Không có' ? 'không có nhiệm vụ trễ nổi bật' : report.topOverdueTitle}.',
    );

    if (report.avgDelayMinutes > 0) {
      suggestions.add('Độ trễ trung bình của các nhiệm vụ trễ là ${report.avgDelayMinutes} phút.');
    }

    return suggestions;
  }

  String _priorityKey(String raw) {
    if (raw.contains('cao') || raw.contains('high')) return 'high';
    if (raw.contains('thấp') || raw.contains('thap') || raw.contains('low')) return 'low';
    return 'medium';
  }

  String _reportDocId(String uid, DateTimeRange range) {
    return '${uid}_${range.start.millisecondsSinceEpoch}_${range.end.millisecondsSinceEpoch}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_viewmodel.dart';
import 'viewmodel_base.dart';

class StatsCategoryShare {
  final String name;
  final int count;
  final double ratio;

  const StatsCategoryShare({
    required this.name,
    required this.count,
    required this.ratio,
  });

  factory StatsCategoryShare.fromMap(Map<String, dynamic> map) {
    return StatsCategoryShare(
      name: map['name'] as String? ?? 'Khác',
      count: (map['count'] as num?)?.toInt() ?? 0,
      ratio: (map['ratio'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'count': count, 'ratio': ratio};
  }
}

class StatsViewModel extends ViewModel {
  final String uid;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int delayedTasks;
  final double completionRate;
  final int bestFocusStartMinute;
  final int bestFocusEndMinute;
  final int streakDays;
  final int totalFocusTime;
  final int totalBreakTime;
  final int breakDuration;
  final int focusDuration;
  final String dateString;
  final Timestamp? timestamp;
  final int averageFocusMinutes;
  final int breakMinutes;
  final Map<String, int> categoryCounts;
  final Map<String, double> categoryRatios;
  final Timestamp? updatedAt;

  StatsViewModel({
    required this.uid,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.delayedTasks,
    required this.completionRate,
    required this.bestFocusStartMinute,
    required this.bestFocusEndMinute,
    required this.streakDays,
    required this.totalFocusTime,
    required this.totalBreakTime,
    required this.breakDuration,
    required this.focusDuration,
    required this.dateString,
    this.timestamp,
    required this.averageFocusMinutes,
    required this.breakMinutes,
    required this.categoryCounts,
    required this.categoryRatios,
    this.updatedAt,
  });

  factory StatsViewModel.fromFirestore(Map<String, dynamic> map) {
    final rawCategoryCounts =
        (map['categoryCounts'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final rawCategoryRatios =
        (map['categoryRatios'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return StatsViewModel(
      uid: map['uid'] as String? ?? '',
      totalTasks: (map['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (map['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (map['overdueTasks'] as num?)?.toInt() ?? 0,
      delayedTasks: (map['delayedTasks'] as num?)?.toInt() ?? 0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 0,
      bestFocusStartMinute: (map['bestFocusStartMinute'] as num?)?.toInt() ?? 0,
      bestFocusEndMinute: (map['bestFocusEndMinute'] as num?)?.toInt() ?? 0,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      totalFocusTime:
          (map['total_focus_time'] as num?)?.toInt() ??
          (map['totalFocusTime'] as num?)?.toInt() ??
          0,
      totalBreakTime:
          (map['total_break_time'] as num?)?.toInt() ??
          (map['totalBreakTime'] as num?)?.toInt() ??
          0,
      breakDuration:
          (map['break_duration'] as num?)?.toInt() ??
          (map['breakDuration'] as num?)?.toInt() ??
          0,
      focusDuration:
          (map['focus_duration'] as num?)?.toInt() ??
          (map['focusDuration'] as num?)?.toInt() ??
          0,
      dateString:
          map['date_string'] as String? ?? map['dateString'] as String? ?? '',
      timestamp: map['timestamp'] as Timestamp?,
      averageFocusMinutes: (map['averageFocusMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (map['breakMinutes'] as num?)?.toInt() ?? 0,
      categoryCounts: rawCategoryCounts.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
      categoryRatios: rawCategoryRatios.map(
        (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0),
      ),
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  factory StatsViewModel.empty({required String uid}) {
    return StatsViewModel(
      uid: uid,
      totalTasks: 0,
      completedTasks: 0,
      overdueTasks: 0,
      delayedTasks: 0,
      completionRate: 0,
      bestFocusStartMinute: 0,
      bestFocusEndMinute: 0,
      streakDays: 0,
      totalFocusTime: 0,
      totalBreakTime: 0,
      breakDuration: 0,
      focusDuration: 0,
      dateString: '',
      timestamp: null,
      averageFocusMinutes: 0,
      breakMinutes: 0,
      categoryCounts: const {},
      categoryRatios: const {},
    );
  }

  factory StatsViewModel.fromTasks({
    required String uid,
    required List<TaskViewModel> tasks,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final todayStart = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    );
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final totalTasks = tasks.length;
    final completedTasks = tasks
        .where((task) => task.stat == 'Hoàn thành')
        .length;
    final overdueTasks = tasks.where((task) {
      if (task.stat == 'Hoàn thành') return false;
      final dueAt = task.dueAt?.toDate();
      return dueAt != null && dueAt.isBefore(currentTime);
    }).length;

    final categoryCounts = <String, int>{};
    final completedDaySet = <DateTime>{};
    final hourBuckets = List<int>.filled(24, 0);
    var totalFocusTime = 0;
    var totalBreakTime = 0;
    var todayFocusTime = 0;
    var todayBreakTime = 0;
    var lastFocusDuration = 0;
    var lastBreakDuration = 0;
    var lastDateString = _formatDate(currentTime);
    Timestamp? lastTimestamp;

    for (final task in tasks) {
      final category = task.category.trim().isEmpty
          ? 'Khác'
          : task.category.trim();
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

      totalFocusTime += task.totalFocusTime ?? task.focusDuration ?? 0;
      totalBreakTime += task.totalBreakTime ?? task.breakDuration ?? 0;

      final taskFocus = task.totalFocusTime ?? task.focusDuration ?? 0;
      final taskBreak = task.totalBreakTime ?? task.breakDuration ?? 0;

      final taskAnchorTs =
          task.timestamp ?? task.createdAt ?? task.completedAt ?? task.dueAt;
      final taskAnchor = taskAnchorTs?.toDate();
      final taskDateString = task.dateString?.trim() ?? '';
      final isToday =
          taskDateString == _formatDate(currentTime) ||
          (taskAnchor != null &&
              !taskAnchor.isBefore(todayStart) &&
              taskAnchor.isBefore(tomorrowStart));

      if (isToday) {
        todayFocusTime += taskFocus;
        todayBreakTime += taskBreak;
      }

      final taskTimestamp =
          task.timestamp ?? task.completedAt ?? task.createdAt ?? task.dueAt;
      if (taskTimestamp != null) {
        final candidate = taskTimestamp.toDate();
        final currentLatest = lastTimestamp?.toDate();
        if (currentLatest == null || candidate.isAfter(currentLatest)) {
          lastTimestamp = taskTimestamp;
          lastFocusDuration = task.focusDuration ?? 0;
          lastBreakDuration = task.breakDuration ?? 0;
          final taskDateString = task.dateString?.trim() ?? '';
          lastDateString = taskDateString.isNotEmpty
              ? taskDateString
              : _formatDate(candidate);
        }
      }

      if (task.stat == 'Hoàn thành') {
        // Prefer explicit completedAt timestamp. Fall back to createdAt if missing.
        final anchorTs = task.completedAt ?? task.createdAt ?? task.dueAt;
        final anchor = anchorTs?.toDate();
        if (anchor != null) {
          completedDaySet.add(DateTime(anchor.year, anchor.month, anchor.day));
          hourBuckets[anchor.hour] += 1;
        }
      }
    }

    final categoryRatios = categoryCounts.map(
      (key, value) => MapEntry(key, totalTasks == 0 ? 0.0 : value / totalTasks),
    );

    final bestFocusWindow = _bestTwoHourWindow(hourBuckets);
    final streakDays = _streakLength(completedDaySet, currentTime);

    return StatsViewModel(
      uid: uid,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      delayedTasks: overdueTasks,
      completionRate: totalTasks == 0 ? 0 : completedTasks / totalTasks,
      bestFocusStartMinute: bestFocusWindow.$1,
      bestFocusEndMinute: bestFocusWindow.$2,
      streakDays: streakDays,
      totalFocusTime: totalFocusTime,
      totalBreakTime: totalBreakTime,
      breakDuration: lastBreakDuration,
      focusDuration: lastFocusDuration,
      dateString: lastDateString,
      timestamp: lastTimestamp ?? Timestamp.fromDate(currentTime),
      averageFocusMinutes: todayFocusTime,
      breakMinutes: todayBreakTime,
      categoryCounts: categoryCounts,
      categoryRatios: categoryRatios,
      updatedAt: Timestamp.fromDate(currentTime),
    );
  }

  static (int, int) _bestTwoHourWindow(List<int> buckets) {
    var bestStart = 0;
    var bestScore = -1;
    for (var hour = 0; hour < buckets.length - 1; hour++) {
      final score = buckets[hour] + buckets[hour + 1];
      if (score > bestScore) {
        bestScore = score;
        bestStart = hour;
      }
    }

    return (bestStart * 60, (bestStart + 2) * 60);
  }

  static int _streakLength(Set<DateTime> completedDays, DateTime now) {
    if (completedDays.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime(now.year, now.month, now.day);
    while (completedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String get completionSummary {
    return '${(completionRate * 100).round()}% - Hoàn thành $completedTasks/$totalTasks việc';
  }

  String get overdueSummary {
    return '$overdueTasks việc bị quá hạn/trì hoãn';
  }

  String get bestFocusWindowLabel {
    return '${_formatMinute(bestFocusStartMinute)} - ${_formatMinute(bestFocusEndMinute)}';
  }

  String get streakLabel {
    return '$streakDays ngày';
  }

  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  List<StatsCategoryShare> get categoryShares {
    final entries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (entry) => StatsCategoryShare(
            name: entry.key,
            count: entry.value,
            ratio: categoryRatios[entry.key] ?? 0,
          ),
        )
        .toList();
  }

  static String _formatMinute(int minuteOfDay) {
    final normalized = minuteOfDay.clamp(0, 23 * 60 + 59);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Map<String, dynamic> toMap() {
    return toFirestoreMap();
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
      'delayedTasks': delayedTasks,
      'completionRate': completionRate,
      'bestFocusStartMinute': bestFocusStartMinute,
      'bestFocusEndMinute': bestFocusEndMinute,
      'bestFocusWindowLabel': bestFocusWindowLabel,
      'streakDays': streakDays,
      'total_focus_time': totalFocusTime,
      'total_break_time': totalBreakTime,
      'break_duration': breakDuration,
      'focus_duration': focusDuration,
      'date_string': dateString,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'averageFocusMinutes': averageFocusMinutes,
      'breakMinutes': breakMinutes,
      'categoryCounts': categoryCounts,
      'categoryRatios': categoryRatios,
      'categoryShares': categoryShares.map((share) => share.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String get syncSignature {
    final categoryPart = categoryCounts.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');
    return [
      uid,
      totalTasks,
      completedTasks,
      overdueTasks,
      delayedTasks,
      completionRate.toStringAsFixed(4),
      bestFocusStartMinute,
      bestFocusEndMinute,
      streakDays,
      totalFocusTime,
      totalBreakTime,
      breakDuration,
      focusDuration,
      dateString,
      timestamp?.millisecondsSinceEpoch ?? 0,
      averageFocusMinutes,
      breakMinutes,
      categoryPart,
    ].join('|');
  }

  @override
  String toString() {
    return 'StatsViewModel(uid: $uid, totalTasks: $totalTasks, completedTasks: $completedTasks, overdueTasks: $overdueTasks)';
  }
}

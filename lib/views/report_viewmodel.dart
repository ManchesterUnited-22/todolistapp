import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCategoryStat {
  final String name;
  final int count;
  final int overdueCount;
  final int lateCount;
  final int overdueMinutes;

  ReportCategoryStat({
    required this.name,
    required this.count,
    required this.overdueCount,
    required this.lateCount,
    required this.overdueMinutes,
  });

  factory ReportCategoryStat.fromMap(Map<String, dynamic> map) {
    return ReportCategoryStat(
      name: map['name'] as String? ?? 'Khác',
      count: (map['count'] as num?)?.toInt() ?? 0,
      overdueCount: (map['overdueCount'] as num?)?.toInt() ?? 0,
      lateCount: (map['lateCount'] as num?)?.toInt() ?? 0,
      overdueMinutes: (map['overdueMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'count': count,
      'overdueCount': overdueCount,
      'lateCount': lateCount,
      'overdueMinutes': overdueMinutes,
    };
  }
}

class ReportViewModel {
  final String id; // Firestore doc id (optional - may be '')
  final String uid;
  final Timestamp periodStart;
  final Timestamp periodEnd;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int onTimeCount;
  final int lateCount;
  final int avgDelayMinutes;
  final Map<String, int> priorityCounts; // high/medium/low
  final Map<String, int> completedByPriority;
  final Map<String, int> categoryCounts;
  final String topCategory;
  final String topOverdueTitle;
  final int topOverdueMinutes;
  final int incompleteOverdueCount;
  final int completedLateCount;
  final int completedLateTotalMinutes;
  final String earliestCompletionTitle;
  final int earliestCompletionMinutes;
  final Map<String, ReportCategoryStat> categoryStats;
  final String notes; // human/AI notes
  final Timestamp generatedAt;
  final Timestamp? updatedAt;

  ReportViewModel({
    this.id = '',
    required this.uid,
    required this.periodStart,
    required this.periodEnd,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.onTimeCount,
    required this.lateCount,
    required this.avgDelayMinutes,
    required this.priorityCounts,
    required this.completedByPriority,
    required this.categoryCounts,
    required this.topCategory,
    required this.topOverdueTitle,
    required this.topOverdueMinutes,
    required this.incompleteOverdueCount,
    required this.completedLateCount,
    required this.completedLateTotalMinutes,
    required this.earliestCompletionTitle,
    required this.earliestCompletionMinutes,
    required this.categoryStats,
    required this.notes,
    required this.generatedAt,
    this.updatedAt,
  });

  factory ReportViewModel.fromMap(String id, Map<String, dynamic> map) {
    final rawPriority =
        (map['priorityCounts'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final rawCompletedByPriority =
        (map['completedByPriority'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final rawCategoryCounts =
        (map['categoryCounts'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final rawCategoryStats =
        (map['categoryStats'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return ReportViewModel(
      id: id,
      uid: map['uid'] as String? ?? '',
      periodStart: map['periodStart'] as Timestamp? ?? Timestamp.now(),
      periodEnd: map['periodEnd'] as Timestamp? ?? Timestamp.now(),
      totalTasks: (map['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (map['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (map['overdueTasks'] as num?)?.toInt() ?? 0,
      onTimeCount: (map['onTimeCount'] as num?)?.toInt() ?? 0,
      lateCount: (map['lateCount'] as num?)?.toInt() ?? 0,
      avgDelayMinutes: (map['avgDelayMinutes'] as num?)?.toInt() ?? 0,
      priorityCounts: rawPriority.map(
        (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
      ),
      completedByPriority: rawCompletedByPriority.map(
        (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
      ),
      categoryCounts: rawCategoryCounts.map(
        (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
      ),
      topCategory: map['topCategory'] as String? ?? '',
      topOverdueTitle: map['topOverdueTitle'] as String? ?? '',
      topOverdueMinutes: (map['topOverdueMinutes'] as num?)?.toInt() ?? 0,
      incompleteOverdueCount:
          (map['incompleteOverdueCount'] as num?)?.toInt() ?? 0,
      completedLateCount: (map['completedLateCount'] as num?)?.toInt() ?? 0,
      completedLateTotalMinutes:
          (map['completedLateTotalMinutes'] as num?)?.toInt() ?? 0,
      earliestCompletionTitle: map['earliestCompletionTitle'] as String? ?? '',
      earliestCompletionMinutes:
          (map['earliestCompletionMinutes'] as num?)?.toInt() ?? 0,
      categoryStats: rawCategoryStats.map(
        (k, v) => MapEntry(
          k,
          ReportCategoryStat.fromMap((v as Map).cast<String, dynamic>()),
        ),
      ),
      notes: map['notes'] as String? ?? '',
      generatedAt: map['generatedAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
      'onTimeCount': onTimeCount,
      'lateCount': lateCount,
      'avgDelayMinutes': avgDelayMinutes,
      'priorityCounts': priorityCounts,
      'completedByPriority': completedByPriority,
      'categoryCounts': categoryCounts,
      'topCategory': topCategory,
      'topOverdueTitle': topOverdueTitle,
      'topOverdueMinutes': topOverdueMinutes,
      'incompleteOverdueCount': incompleteOverdueCount,
      'completedLateCount': completedLateCount,
      'completedLateTotalMinutes': completedLateTotalMinutes,
      'earliestCompletionTitle': earliestCompletionTitle,
      'earliestCompletionMinutes': earliestCompletionMinutes,
      'categoryStats': categoryStats.map((k, v) => MapEntry(k, v.toMap())),
      'notes': notes,
      'generatedAt': generatedAt,
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

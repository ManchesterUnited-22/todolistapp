part of mentor_ai;

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
  final Map<String, int>? priorityCountsMap;
  final Map<String, int>? completedByPriorityMap;

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
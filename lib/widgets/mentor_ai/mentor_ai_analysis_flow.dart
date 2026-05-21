part of mentor_ai;

Future<void> showAiAnalysisSheet(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || uid.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để xem phân tích.')),
    );
    return;
  }

  final now = DateTime.now();
  final picked = await _showStyledDateRangePicker(context);
  if (picked == null) return;

  final periodStart = DateTime(picked.start.year, picked.start.month, picked.start.day);
  final periodEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

  final tasksSnap = await FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: uid).get();
  final tasks = tasksSnap.docs.map((d) => d.data()).toList();

  final periodTasks = <Map<String, dynamic>>[];
  for (final map in tasks) {
    final dueTs = map['dueAt'] as Timestamp?;
    final completedTs = map['completedAt'] as Timestamp?;
    final due = dueTs?.toDate();
    final completed = completedTs?.toDate();
    final inPeriod =
        (due != null && !due.isBefore(periodStart) && !due.isAfter(periodEnd)) ||
        (completed != null && !completed.isBefore(periodStart) && !completed.isAfter(periodEnd));
    if (inPeriod) periodTasks.add(map);
  }

  if (periodTasks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có báo cáo cho khoảng thời gian đã chọn.')),
    );
    return;
  }

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
    } else if (priorityRaw.contains('thấp') || priorityRaw.contains('thap') || priorityRaw.contains('low')) {
      lowPriority++;
    } else {
      mediumPriority++;
    }

    String catKey;
    if (categoryRaw.contains('cá nhân') || categoryRaw.contains('ca nhan') || categoryRaw.contains('personal') || categoryRaw == 'cá nhân' || categoryRaw == 'canhan') {
      catKey = 'Cá nhân';
    } else if (categoryRaw.contains('sức') || categoryRaw.contains('suc') || categoryRaw.contains('health') || categoryRaw.contains('khỏe') || categoryRaw.contains('khoe')) {
      catKey = 'Sức khỏe';
    } else {
      catKey = 'Công việc';
    }
    categoryCounts[catKey] = (categoryCounts[catKey] ?? 0) + 1;

    final dueTs = map['dueAt'] as Timestamp?;
    final completedTs = map['completedAt'] as Timestamp?;

    final isCompleted = stat.toLowerCase().contains('hoàn') || stat.toLowerCase().contains('hoan') || completedTs != null;
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
      } else if (priorityRaw.contains('thấp') || priorityRaw.contains('thap') || priorityRaw.contains('low')) {
        lowCompleted++;
      } else {
        mediumCompleted++;
      }
    }
  }

  final avgDelay = lateCount > 0 ? (totalDelayMinutes / lateCount).round() : 0;
  final topCategory = categoryCounts.entries.fold<MapEntry<String, int>?>(null, (prev, e) => prev == null || e.value > prev.value ? e : prev)?.key ?? 'Không rõ';

  String topOverdueTitle = 'Không có';
  int topOverdueMinutes = 0;
  int incompleteOverdueCount = 0;
  int completedLateCount = 0;
  int completedLateTotalMinutes = 0;
  String earliestCompletionTitle = 'Không có';
  int earliestCompletionMinutes = 0;
  final Map<String, int> priorityCountsMap = {'high': 0, 'medium': 0, 'low': 0};
  final Map<String, int> completedByPriorityMap = {'high': 0, 'medium': 0, 'low': 0};

  for (final map in periodTasks) {
    final title = (map['title'] as String?) ?? 'Untitled';
    final priorityRaw = ((map['priority'] as String?) ?? '').toLowerCase();

    String pKey = 'medium';
    if (priorityRaw.contains('cao') || priorityRaw.contains('high')) {
      pKey = 'high';
    } else if (priorityRaw.contains('thấp') || priorityRaw.contains('thap') || priorityRaw.contains('low')) {
      pKey = 'low';
    }
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

  String? aiNotes;
  Map<String, dynamic>? matchedReport;
  try {
    final reportsSnap = await FirebaseFirestore.instance.collection('report').where('uid', isEqualTo: uid).orderBy('generatedAt', descending: true).get();

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
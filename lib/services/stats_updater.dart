import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/stats_viewmodel.dart';
import '../views/task_viewmodel.dart';
import '../views/report_viewmodel.dart';
import 'stats_service.dart';
import 'report_service.dart';

class StatsUpdater {
  StatsUpdater._();
  static final StatsUpdater instance = StatsUpdater._();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _taskSub;

  Future<void> initialize() async {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _taskSub?.cancel();

    final uid = user?.uid ?? '';
    if (uid.isEmpty) return;

    // If user has no reports yet, create a sample one for quick inspection
    try {
      final q = await FirebaseFirestore.instance
          .collection('report')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (q.docs.isEmpty) {
        // ignore: avoid_print
        print(
          'StatsUpdater: no reports found for uid=$uid — creating sample report',
        );
        await ReportService.instance.createSampleReportForUser(uid);
      }
    } catch (e) {
      // ignore: avoid_print
      print('StatsUpdater: error checking/creating sample report: $e');
    }

    _taskSub = FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen(
          (snap) async {
            try {
              final tasks = snap.docs
                  .map((d) => TaskViewModel.fromMap(d.data()))
                  .toList();
              final stats = StatsViewModel.fromTasks(uid: uid, tasks: tasks);
              StatsService.instance.saveUserStats(stats);
              // Build and save a report document for this user (period = last 7 days)
              try {
                final now = DateTime.now();
                final periodStart = Timestamp.fromDate(
                  now.subtract(const Duration(days: 7)),
                );
                final periodEnd = Timestamp.fromDate(now);

                int onTimeCount = 0;
                int lateCount = 0;
                int totalDelayMinutes = 0;

                final priorityCounts = <String, int>{
                  'high': 0,
                  'medium': 0,
                  'low': 0,
                };
                final completedByPriority = <String, int>{
                  'high': 0,
                  'medium': 0,
                  'low': 0,
                };

                String topOverdueTitle = '';
                int topOverdueMinutes = 0;
                int incompleteOverdueCount = 0;
                int completedLateCount = 0;
                int completedLateTotalMinutes = 0;
                String earliestCompletionTitle = '';
                int earliestCompletionMinutes = 0;

                final Map<String, ReportCategoryStat> categoryStats = {};

                for (final task in tasks) {
                  final priorityRaw = (task.priority ?? '').toLowerCase();
                  String pKey = 'medium';
                  if (priorityRaw.contains('cao') ||
                      priorityRaw.contains('high'))
                    pKey = 'high';
                  else if (priorityRaw.contains('thấp') ||
                      priorityRaw.contains('low') ||
                      priorityRaw.contains('thap'))
                    pKey = 'low';
                  priorityCounts[pKey] = (priorityCounts[pKey] ?? 0) + 1;

                  final categoryRaw = task.category.trim().isEmpty
                      ? 'Khác'
                      : task.category.trim();
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

                  final due = task.dueAt?.toDate();
                  final completed = task.completedAt?.toDate();

                  final isCompleted =
                      task.stat.toLowerCase().contains('hoàn') ||
                      task.stat.toLowerCase().contains('hoan') ||
                      completed != null;
                  if (isCompleted) {
                    // Completed by priority
                    completedByPriority[pKey] =
                        (completedByPriority[pKey] ?? 0) + 1;
                  }

                  if (isCompleted && completed != null && due != null) {
                    final diff = completed.difference(due).inMinutes;
                    if (diff <= 0) {
                      onTimeCount++;
                      // early completion
                      final earlyMins = due.difference(completed).inMinutes;
                      if (earlyMins > 0 &&
                          earlyMins > earliestCompletionMinutes) {
                        earliestCompletionMinutes = earlyMins;
                        earliestCompletionTitle = task.title;
                      }
                    } else {
                      lateCount++;
                      totalDelayMinutes += diff;
                      completedLateCount++;
                      completedLateTotalMinutes += diff;
                      // update category stats
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
                  } else if (!isCompleted && due != null && due.isBefore(now)) {
                    // incomplete overdue
                    final overdueMins = now.difference(due).inMinutes;
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

                final avgDelay = lateCount > 0
                    ? (totalDelayMinutes / lateCount).round()
                    : 0;

                final report = ReportViewModel(
                  uid: uid,
                  periodStart: periodStart,
                  periodEnd: periodEnd,
                  totalTasks: stats.totalTasks,
                  completedTasks: stats.completedTasks,
                  overdueTasks: stats.overdueTasks,
                  onTimeCount: onTimeCount,
                  lateCount: lateCount,
                  avgDelayMinutes: avgDelay,
                  priorityCounts: priorityCounts,
                  completedByPriority: completedByPriority,
                  categoryCounts: stats.categoryCounts,
                  topCategory: stats.categoryShares.isNotEmpty
                      ? stats.categoryShares.first.name
                      : '',
                  topOverdueTitle: topOverdueTitle,
                  topOverdueMinutes: topOverdueMinutes,
                  incompleteOverdueCount: incompleteOverdueCount,
                  completedLateCount: completedLateCount,
                  completedLateTotalMinutes: completedLateTotalMinutes,
                  earliestCompletionTitle: earliestCompletionTitle,
                  earliestCompletionMinutes: earliestCompletionMinutes,
                  categoryStats: categoryStats,
                  notes: '',
                  generatedAt: Timestamp.fromDate(now),
                );

                await ReportService.instance.saveReport(report);
              } catch (e, st) {
                // ignore: avoid_print
                print('StatsUpdater: failed to build/save report: $e $st');
              }
            } catch (e, st) {
              // Best-effort: do not rethrow to avoid crashing app
              // ignore: avoid_print
              print('StatsUpdater error: $e $st');
            }
          },
          onError: (e) {
            // ignore: avoid_print
            print('StatsUpdater stream error: $e');
          },
        );
  }

  Future<void> dispose() async {
    await _taskSub?.cancel();
    await _authSub?.cancel();
  }
}

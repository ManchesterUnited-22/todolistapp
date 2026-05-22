import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/stats_viewmodel.dart';
import '../views/task_viewmodel.dart';
import '../views/report_viewmodel.dart';
import 'stats_service.dart';
import 'report_service.dart';
import 'notification_service.dart';

class StatsUpdater {
  StatsUpdater._();
  static final StatsUpdater instance = StatsUpdater._();

  static const String _achievementUnlockPrefsPrefix =
      'achievement_unlocked_keys_';

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
              await _syncAchievements(uid: uid, tasks: tasks, stats: stats);

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
                    completedByPriority[pKey] =
                        (completedByPriority[pKey] ?? 0) + 1;
                  }

                  if (isCompleted && completed != null && due != null) {
                    final diff = completed.difference(due).inMinutes;
                    if (diff <= 0) {
                      onTimeCount++;
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

  Future<void> _syncAchievements({
    required String uid,
    required List<TaskViewModel> tasks,
    required StatsViewModel stats,
  }) async {
    if (uid.isEmpty) return;

    final now = DateTime.now();
    final achievements = _buildAchievementMap(
      tasks: tasks,
      stats: stats,
      now: now,
    );

    await FirebaseFirestore.instance
        .collection('achievements')
        .doc(uid)
        .set({
          'uid': uid,
          ...achievements,
          'updatedAt': Timestamp.fromDate(now),
        }, SetOptions(merge: true));

    await _notifyUnlockedAchievements(uid: uid, achievements: achievements);
  }

  Map<String, dynamic> _buildAchievementMap({
    required List<TaskViewModel> tasks,
    required StatsViewModel stats,
    required DateTime now,
  }) {
    int earlyMorningSessions = 0;
    int lateNightSessions = 0;

    for (final task in tasks) {
      if (task.stat != 'Hoàn thành') continue;

      final completedAt =
          task.completedAt?.toDate() ??
          task.timestamp?.toDate() ??
          task.createdAt?.toDate();
      if (completedAt == null) continue;

      if (completedAt.hour < 8) {
        earlyMorningSessions += 1;
      }

      if (completedAt.hour >= 22) {
        lateNightSessions += 1;
      }
    }

    return {
      'earlyMorningSessions': earlyMorningSessions,
      'focusStreakDays': stats.streakDays,
      'totalFocusMinutes': stats.totalFocusTime,
      'tasksCompleted': stats.completedTasks,
      'lateNightSessions': lateNightSessions,
      'computedAt': Timestamp.fromDate(now),
    };
  }

  Future<void> _notifyUnlockedAchievements({
    required String uid,
    required Map<String, dynamic> achievements,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = '$_achievementUnlockPrefsPrefix$uid';
    final knownKeys = prefs.getStringList(prefKey)?.toSet() ?? <String>{};
    final currentKeys = <String>{};
    final unlockedBadges = <_AchievementNotification>[];

    for (final definition in _achievementDefinitions) {
      final value = (achievements[definition.field] as num?)?.toInt() ?? 0;
      if (value >= definition.threshold) {
        currentKeys.add(definition.id);
        if (!knownKeys.contains(definition.id)) {
          unlockedBadges.add(definition);
        }
      }
    }

    await prefs.setStringList(prefKey, currentKeys.toList());

    if (knownKeys.isEmpty || unlockedBadges.isEmpty) {
      return;
    }

    for (final badge in unlockedBadges) {
      await NotificationService.instance.showSimpleNotification(
        id: badge.id.hashCode & 0x7fffffff,
        title: 'Huy hiệu mới: ${badge.label}',
        body: badge.message,
      );
    }
  }

  Future<void> dispose() async {
    await _taskSub?.cancel();
    await _authSub?.cancel();
  }
}

class _AchievementNotification {
  final String id;
  final String label;
  final String field;
  final int threshold;
  final String message;

  const _AchievementNotification({
    required this.id,
    required this.label,
    required this.field,
    required this.threshold,
    required this.message,
  });
}

const List<_AchievementNotification> _achievementDefinitions = [
  _AchievementNotification(
    id: 'earlyMorningSessions',
    label: 'Bình Minh',
    field: 'earlyMorningSessions',
    threshold: 1,
    message: 'Bạn đã mở khóa huy hiệu Bình Minh. Một khởi đầu rất đẹp.',
  ),
  _AchievementNotification(
    id: 'focusStreakDays_3',
    label: 'Tự tại',
    field: 'focusStreakDays',
    threshold: 3,
    message: 'Bạn đã mở khóa huy hiệu Tự tại nhờ streak tập trung ấn tượng.',
  ),
  _AchievementNotification(
    id: 'totalFocusMinutes_60',
    label: 'Tập Trung',
    field: 'totalFocusMinutes',
    threshold: 60,
    message: 'Bạn đã mở khóa huy hiệu Tập Trung sau khi tích lũy đủ thời gian.',
  ),
  _AchievementNotification(
    id: 'focusStreakDays_7',
    label: 'Bền Bỉ',
    field: 'focusStreakDays',
    threshold: 7,
    message: 'Bạn đã mở khóa huy hiệu Bền Bỉ. Sự kiên trì đang được đền đáp.',
  ),
  _AchievementNotification(
    id: 'tasksCompleted_20',
    label: 'Trưởng Thành',
    field: 'tasksCompleted',
    threshold: 20,
    message: 'Bạn đã mở khóa huy hiệu Trưởng Thành sau nhiều nhiệm vụ hoàn tất.',
  ),
  _AchievementNotification(
    id: 'totalFocusMinutes_600',
    label: 'Thông tuệ',
    field: 'totalFocusMinutes',
    threshold: 600,
    message: 'Bạn đã mở khóa huy hiệu Thông tuệ. Thành quả của sự bền bỉ.',
  ),
  _AchievementNotification(
    id: 'lateNightSessions',
    label: 'Đêm Thâu Tĩnh Lặng',
    field: 'lateNightSessions',
    threshold: 5,
    message: 'Bạn đã mở khóa huy hiệu Đêm Thâu Tĩnh Lặng.',
  ),
  _AchievementNotification(
    id: 'tasksCompleted_100',
    label: 'Trọn vẹn',
    field: 'tasksCompleted',
    threshold: 100,
    message: 'Bạn đã mở khóa huy hiệu Trọn vẹn. Một cột mốc rất đáng nhớ.',
  ),
];
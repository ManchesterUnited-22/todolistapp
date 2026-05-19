import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_history.dart';

class VoiceNudgeResult {
  final bool shouldWarn;
  final String message;
  final DateTime? suggestedTime;

  VoiceNudgeResult({required this.shouldWarn, required this.message, this.suggestedTime});
}

class VoiceNudgeService {
  static const _kHistoryKey = 'task_history_v1';

  Future<List<TaskHistoryItem>> _readHistory() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kHistoryKey);
    return TaskHistoryItem.listFromJson(raw);
  }

  Future<void> _writeHistory(List<TaskHistoryItem> items) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kHistoryKey, TaskHistoryItem.listToJson(items));
  }

  /// Record a task outcome into local history. Call this whenever a task is
  /// completed or becomes overdue so the nudge model can learn.
  Future<void> recordOutcome(TaskHistoryItem item) async {
    final list = await _readHistory();
    list.add(item);
    // keep recent 200 entries to limit size
    final trimmed = list.length > 200 ? list.sublist(list.length - 200) : list;
    await _writeHistory(trimmed);
  }

  /// Analyze a proposed due time and decide whether to warn the user.
  /// Heuristic: find past items with same hour in recent window and compute miss ratio.
  Future<VoiceNudgeResult> analyzeProposed(DateTime proposedDue) async {
    final now = DateTime.now();
    final history = await _readHistory();

    // consider last 21 days
    final cutoff = now.subtract(const Duration(days: 21));
    final recent = history.where((h) => h.dueAt.isAfter(cutoff)).toList();
    if (recent.isEmpty) {
      return VoiceNudgeResult(shouldWarn: false, message: 'Không đủ dữ liệu lịch sử.');
    }

    final targetHour = proposedDue.hour;
    final sameHour = recent.where((h) => h.dueAt.hour == targetHour).toList();
    if (sameHour.length < 3) {
      return VoiceNudgeResult(shouldWarn: false, message: 'Không đủ số lần cùng khung giờ để kết luận.');
    }

    final missed = sameHour.where((h) {
      // missed if not completed and due in past relative to now at the time of analysis
      final isCompleted = h.completedAt != null;
      final dueBeforeNow = h.dueAt.isBefore(now);
      return !isCompleted && dueBeforeNow;
    }).toList();

    final missRatio = missed.length / sameHour.length;
    if (missRatio >= 0.6) {
      // suggest alternative hour: try nearby hours with lower miss ratio
      DateTime? suggested;
      for (var offset in [1, -1, 2, -2, 3, -3]) {
        final h = (targetHour + offset) % 24;
        final same = recent.where((r) => r.dueAt.hour == h).toList();
        if (same.isEmpty) continue;
        final m = same.where((r) => (r.completedAt == null) && r.dueAt.isBefore(now)).length / same.length;
        if (m < missRatio) {
          suggested = DateTime(proposedDue.year, proposedDue.month, proposedDue.day, h, proposedDue.minute);
          break;
        }
      }

      final msg = 'Phát hiện bạn thường xuyên trễ tại khung ${targetHour}h (tỷ lệ bỏ lỡ ${ (missRatio*100).round() }%). Gợi ý dời sang khung giờ khác.';
      return VoiceNudgeResult(shouldWarn: true, message: msg, suggestedTime: suggested);
    }

    return VoiceNudgeResult(shouldWarn: false, message: 'Không thấy vấn đề với khung giờ này.');
  }
}

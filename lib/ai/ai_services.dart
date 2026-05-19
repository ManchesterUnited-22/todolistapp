import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceTaskDraft {
  final String way;
  final String title;
  final String category;
  final int durationMinutes;
  final String priority;
  final DateTime? dueAt;

  const VoiceTaskDraft({
    required this.way,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.priority,
    this.dueAt,
  });
}

enum VoiceTaskStep {
  chooseWay,
  askTitle,
  askCategory,
  askDuration,
  askPriority,
  askDueAt,
  confirmWay,
  confirm,
  done,
}

class VoiceTaskConversationState {
  final VoiceTaskStep step;
  final String? way;
  final String? title;
  final String? category;
  final int? durationMinutes;
  final String? priority;
  final DateTime? dueAt;

  const VoiceTaskConversationState({
    required this.step,
    this.way,
    this.title,
    this.category,
    this.durationMinutes,
    this.priority,
    this.dueAt,
  });

  factory VoiceTaskConversationState.initial() => const VoiceTaskConversationState(step: VoiceTaskStep.chooseWay);

  VoiceTaskConversationState copyWith({
    VoiceTaskStep? step,
    String? way,
    String? title,
    String? category,
    int? durationMinutes,
    String? priority,
    DateTime? dueAt,
    bool clearDueAt = false,
  }) {
    return VoiceTaskConversationState(
      step: step ?? this.step,
      way: way ?? this.way,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      priority: priority ?? this.priority,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
    );
  }
}

class VoiceTaskConversationReply {
  final VoiceTaskConversationState state;
  final String prompt;
  final bool isComplete;
  final VoiceTaskDraft? draft;

  const VoiceTaskConversationReply({
    required this.state,
    required this.prompt,
    required this.isComplete,
    this.draft,
  });
}

class AiRecommendation {
  final int suggestedFocusMinutes;
  final int suggestedBreakMinutes;
  final String message;

  AiRecommendation({
    required this.suggestedFocusMinutes,
    required this.suggestedBreakMinutes,
    required this.message,
  });
}

class AIService {
  final String _apiKey = "AIzaSyAFY1zf_yrzVvcn_0thkoqr9PwklwBzTpw";
  final FlutterTts _tts = FlutterTts();
  AIService._();
  static final instance = AIService._();

  /// Public getter to expose the configured API key for reuse by other modules.
  String get apiKey => _apiKey;

  Future<void> speakText(String text) async {
    try {
      await _tts.stop();
      await _tts.setLanguage('vi-VN');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(0.98);
      await _tts.setVolume(1.0);

      // Use a Completer with completion handler for more reliable await across platforms.
      final completer = Completer<void>();

      _tts.setStartHandler(() {
        if (kDebugMode) debugPrint('TTS started');
      });
      _tts.setCompletionHandler(() {
        if (!completer.isCompleted) completer.complete();
        if (kDebugMode) debugPrint('TTS completed');
      });
      _tts.setErrorHandler((msg) {
        if (!completer.isCompleted) completer.complete();
        if (kDebugMode) debugPrint('TTS error: $msg');
      });

      // Some platforms honor awaitSpeakCompletion; keep it as a hint but rely on handlers.
      try {
        await _tts.awaitSpeakCompletion(true);
      } catch (_) {}

      await _tts.speak(text);

      // Wait for completion, but guard with a timeout to avoid hanging forever.
      try {
        await completer.future.timeout(Duration(seconds: max(5, (text.length ~/ 15) + 1)));
      } catch (_) {
        // Timeout: proceed so UI isn't blocked indefinitely.
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AIService TTS error: $e');
    }
  }

  String voicePromptForStep(VoiceTaskConversationState state) {
    switch (state.step) {
      case VoiceTaskStep.chooseWay:
        return 'Mình hỏi nhanh từng bước nhé. Bạn muốn tạo nhiệm vụ dài hạn hay Promodoro (nhiệm vụ ngắn hạn)? Nhiệm vụ dài hạn là việc kéo dài nhiều bước. Promodoro là nhiệm vụ ngắn theo phiên tập trung.';
      case VoiceTaskStep.confirmWay:
        return state.way == 'promodoro'
            ? 'Mình nghe là bạn muốn tạo Promodoro tức nhiệm vụ ngắn hạn. Bạn xác nhận chứ?'
            : 'Mình nghe là bạn muốn tạo nhiệm vụ dài hạn. Bạn xác nhận chứ?';
      case VoiceTaskStep.askTitle:
        return 'Tên nhiệm vụ là gì, nói ngắn gọn giúp mình nhé.';
      case VoiceTaskStep.askCategory:
        return 'Nhiệm vụ này thuộc nhóm nào: Công việc, Học tập, Cá nhân hay Sức khỏe?';
      case VoiceTaskStep.askDuration:
        return state.way == 'promodoro'
            ? 'Promodoro này bạn sẽ tập trung bao nhiêu phút?'
            : 'Nhiệm vụ này dự kiến kéo dài bao lâu (tính theo phút)?';
      case VoiceTaskStep.askPriority:
        return 'Mức độ ưu tiên của nhiệm vụ dài hạn là cao, vừa hay thấp?';
      case VoiceTaskStep.askDueAt:
        return 'Bạn muốn lên lịch nhiệm vụ vào ngày và giờ nào?';
      case VoiceTaskStep.confirm:
        return 'Mình sẽ lưu task này. Bạn nghe lại và xác nhận giúp mình nhé.';
      case VoiceTaskStep.done:
        return 'Đã xong.';
    }
  }

  VoiceTaskConversationReply advanceVoiceTaskConversation(
    String userText,
    VoiceTaskConversationState state,
  ) {
    final text = userText.trim().toLowerCase();

    if (state.step == VoiceTaskStep.chooseWay) {
      final way = _parseWay(text);
      if (way == null) {
        return VoiceTaskConversationReply(
          state: state,
          prompt: 'Mình chưa rõ, bạn chọn task dài hạn hay Promodoro nhé.',
          isComplete: false,
        );
      }
      // Nếu đã nhận dạng được, chuyển sang bước xác nhận loại nhiệm vụ
      return VoiceTaskConversationReply(
        state: state.copyWith(way: way, step: VoiceTaskStep.confirmWay),
        prompt: voicePromptForStep(state.copyWith(way: way, step: VoiceTaskStep.confirmWay)),
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.confirmWay) {
      if (_isAffirmative(text)) {
        final next = state.copyWith(step: VoiceTaskStep.askTitle);
        return VoiceTaskConversationReply(
          state: next,
          prompt: voicePromptForStep(next),
          isComplete: false,
        );
      }
      // Không xác nhận: quay lại từ đầu
      return VoiceTaskConversationReply(
        state: VoiceTaskConversationState.initial(),
        prompt: 'Được, mình bắt đầu lại. Bạn muốn nhiệm vụ dài hạn hay Promodoro?',
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.askTitle) {
      if (text.isEmpty) {
        return VoiceTaskConversationReply(
          state: state,
          prompt: 'Tên task chưa rõ, bạn nói lại giúp mình nhé.',
          isComplete: false,
        );
      }
      final next = state.copyWith(title: userText.trim(), step: VoiceTaskStep.askCategory);
      return VoiceTaskConversationReply(
        state: next,
        prompt: voicePromptForStep(next),
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.askCategory) {
      final category = _parseCategory(text);
      if (category == null) {
        return VoiceTaskConversationReply(
          state: state,
          prompt: 'Mình chưa nhận ra loại task. Bạn nói Công việc, Học tập, Cá nhân hoặc Sức khỏe nhé.',
          isComplete: false,
        );
      }
      final next = state.copyWith(category: category, step: VoiceTaskStep.askDuration);
      return VoiceTaskConversationReply(
        state: next,
        prompt: voicePromptForStep(next),
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.askDuration) {
      final duration = _parseDurationMinutes(text);
      if (duration == null) {
        return VoiceTaskConversationReply(
          state: state,
          prompt: 'Mình cần một con số phút hợp lệ nhé.',
          isComplete: false,
        );
      }
      if (state.way == 'promodoro') {
        final next = state.copyWith(durationMinutes: duration, priority: 'Cao', step: VoiceTaskStep.askDueAt);
        return VoiceTaskConversationReply(
          state: next,
          prompt: voicePromptForStep(next),
          isComplete: false,
        );
      }
      final next = state.copyWith(durationMinutes: duration, step: VoiceTaskStep.askPriority);
      return VoiceTaskConversationReply(
        state: next,
        prompt: voicePromptForStep(next),
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.askPriority) {
      final priority = _parsePriority(text);
      if (priority == null) {
        return VoiceTaskConversationReply(
          state: state,
          prompt: 'Mức ưu tiên chưa rõ. Bạn nói cao, vừa hay thấp nhé.',
          isComplete: false,
        );
      }
      final next = state.copyWith(priority: priority, step: VoiceTaskStep.askDueAt);
      return VoiceTaskConversationReply(
        state: next,
        prompt: voicePromptForStep(next),
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.askDueAt) {
      final dueAt = _parseDueAtVoice(text);
      final next = state.copyWith(dueAt: dueAt, step: VoiceTaskStep.confirm);
      final summary = _buildSummary(next);
      return VoiceTaskConversationReply(
        state: next,
        prompt: 'Xác nhận lại giúp mình: $summary',
        isComplete: false,
      );
    }

    if (state.step == VoiceTaskStep.confirm) {
      if (_isAffirmative(text)) {
        final draft = VoiceTaskDraft(
          way: state.way ?? 'long_term_task',
          title: state.title ?? 'Công việc mới',
          category: state.category ?? 'Công việc',
          durationMinutes: state.durationMinutes ?? 0,
          priority: state.priority ?? 'Vừa',
          dueAt: state.dueAt,
        );
        return VoiceTaskConversationReply(
          state: state.copyWith(step: VoiceTaskStep.done),
          prompt: 'Đã ghi nhận rồi.',
          isComplete: true,
          draft: draft,
        );
      }
      return VoiceTaskConversationReply(
        state: VoiceTaskConversationState.initial(),
        prompt: 'Được, mình làm lại từ đầu nhé.',
        isComplete: false,
      );
    }

    return VoiceTaskConversationReply(
      state: state,
      prompt: voicePromptForStep(state),
      isComplete: false,
    );
  }

  String? _parseWay(String text) {
    // Accept many variants and common mispronunciations/spellings for Promodoro/Pomodoro
    final t = text.replaceAll(RegExp(r"[^a-z0-9ạáàảãâấầẩẫăắằẳẵêếềếëễìíìỉĩòóỏõôốồổỗơớờởỡùúủũưứừửữỳýỷỹđ\\s]", caseSensitive: false), '');
    if (t.contains('promodoro') || t.contains('pomodoro') || t.contains('promodor') || t.contains('promodo') || t.contains('promodo') || t.contains('pomod') || t.contains('promod') || t.contains('prodmod') || t.contains('promodoro')) return 'promodoro';
    // Vietnamese synonyms
    if (text.contains('nhiệm vụ ngắn') || text.contains('ngắn hạn') || text.contains('nhiem vu ngan') || text.contains('ngan han')) return 'promodoro';
    if (text.contains('dài hạn') || text.contains('dai han') || text.contains('long term') || text.contains('nhiệm vụ dài') || text.contains('nhiem vu dai')) return 'long_term_task';
    return null;
  }

  String? _parseCategory(String text) {
    if (text.contains('công việc') || text.contains('cong viec') || text.contains('work')) return 'Công việc';
    if (text.contains('học tập') || text.contains('hoc tap') || text.contains('study')) return 'Học tập';
    if (text.contains('sức khỏe') || text.contains('suc khoe') || text.contains('health')) return 'Sức khỏe';
    if (text.contains('cá nhân') || text.contains('ca nhan') || text.contains('personal')) return 'Cá nhân';
    return null;
  }

  int? _parseDurationMinutes(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(0) ?? '');
  }

  String? _parsePriority(String text) {
    if (text.contains('cao')) return 'Cao';
    if (text.contains('thấp') || text.contains('thap')) return 'Thấp';
    if (text.contains('vừa') || text.contains('vua') || text.contains('trung bình') || text.contains('trung binh')) return 'Vừa';
    return null;
  }

  DateTime? _parseDueAtVoice(String text) {
    final now = DateTime.now();
    if (text.contains('hôm nay')) {
      final time = _extractTime(text) ?? TimeOfDay.fromDateTime(now);
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }
    if (text.contains('ngày mai')) {
      final d = now.add(const Duration(days: 1));
      final time = _extractTime(text) ?? const TimeOfDay(hour: 9, minute: 0);
      return DateTime(d.year, d.month, d.day, time.hour, time.minute);
    }
    final date = RegExp(r'(\d{1,2}[\/-]\d{1,2}(?:[\/-]\d{2,4})?)').firstMatch(text)?.group(0);
    final time = _extractTime(text);
    if (date == null) return null;
    final parts = date.replaceAll('/', '-').split('-');
    if (parts.length < 2) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (day == null || month == null) return null;
    final year = parts.length >= 3 ? int.tryParse(parts[2]) ?? now.year : now.year;
    final safeTime = time ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(year, month, day, safeTime.hour, safeTime.minute);
  }

  TimeOfDay? _extractTime(String text) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isAffirmative(String text) {
    return text.contains('đúng') || text.contains('ok') || text.contains('xác nhận') || text.contains('có') || text.contains('đồng ý');
  }

  String _buildSummary(VoiceTaskConversationState state) {
    final parts = <String>[];
    parts.add('loại ${state.way == 'promodoro' ? 'Promodoro (nhiệm vụ ngắn hạn)' : 'nhiệm vụ dài hạn'}');
    parts.add('tên ${state.title ?? ''}');
    parts.add('nhóm ${state.category ?? ''}');
    parts.add('thời lượng ${state.durationMinutes ?? 0} phút');
    if (state.priority != null) parts.add('ưu tiên ${state.priority}');
    if (state.dueAt != null) {
      final d = state.dueAt!;
      parts.add('lịch ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} ngày ${d.day}/${d.month}');
    }
    return parts.join(', ');
  }

  /// Recommendation result returned to the UI
  /// Matches fields used by the TimerCard logic.

  /// Recommend focus/break durations. Tries model first, falls back to
  /// a deterministic heuristic when the model fails.
  Future<AiRecommendation> recommendFocusBreak({
    required int focusMinutes,
    required int breakMinutes,
  }) async {
    // Build system prompt asking the model to return JSON only
    final now = DateTime.now();
    final df = DateFormat.Hm();

    final system = Content.system('''
Bạn là trợ lý đưa ra đề xuất về chia khung thời gian tập trung và giải lao.
Input: một cặp số nguyên: focusMinutes (phút), breakMinutes (phút).
Yêu cầu: Trả về CHỈ MỘT ĐỐI TƯỢNG JSON, KHÔNG GIẢI THÍCH.
JSON phải có các trường: "suggested_focus_minutes" (integer), "suggested_break_minutes" (integer), "message" (string).
"message" nên là một câu ngắn giải thích tại sao đề xuất đó hợp lý và kèm khung thời gian hoàn thành (ví dụ 09:30 → 10:00).
''');

    final prompt = 'focusMinutes: $focusMinutes, breakMinutes: $breakMinutes';

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey, systemInstruction: system);
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final clean = text.replaceAll('```', '').replaceAll('json', '').trim();
      try {
        final map = jsonDecode(clean) as Map<String, dynamic>;
        final sF = (map['suggested_focus_minutes'] as num).toInt();
        final sB = (map['suggested_break_minutes'] as num).toInt();
        final msg = (map['message'] as String?) ?? '';
        return AiRecommendation(suggestedFocusMinutes: sF, suggestedBreakMinutes: sB, message: msg);
      } catch (_) {
        // continue to heuristic fallback
      }
    } catch (e) {
      // model call failed — fallback to heuristic
    }

    // Heuristic fallback (same logic as earlier):
    int suggestedFocus = focusMinutes;
    if (focusMinutes < 20) {
      suggestedFocus = 25;
    } else if (focusMinutes <= 50) {
      suggestedFocus = focusMinutes;
    } else if (focusMinutes <= 90) {
      suggestedFocus = 50;
    } else {
      suggestedFocus = 90;
    }

    int suggestedBreak = (suggestedFocus * 0.15).round();
    if (suggestedBreak < 3) {
      suggestedBreak = 3;
    }

    final finish = now.add(Duration(minutes: suggestedFocus));
    final message = 'Dựa trên $focusMinutes phút bạn nhập, đề xuất: tập trung $suggestedFocus phút, giải lao $suggestedBreak phút. Dự kiến hoàn thành ${df.format(now)} → ${df.format(finish)}.';
    return AiRecommendation(suggestedFocusMinutes: suggestedFocus, suggestedBreakMinutes: suggestedBreak, message: message);
  }

  Future<Map<String, dynamic>?> extractIntentFromText(String userText) async {
    try {
      // Truyền ngày giờ hiện tại vào prompt để AI tính đúng
      final now = DateTime.now();
      final todayStr =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final tomorrowDate = now.add(const Duration(days: 1));
      final tomorrowStr =
          '${tomorrowDate.year.toString().padLeft(4, '0')}-'
          '${tomorrowDate.month.toString().padLeft(2, '0')}-'
          '${tomorrowDate.day.toString().padLeft(2, '0')}';

      final candidateModels = [
        'gemini-2.5-flash',
        'gemini-1.5-flash',
        'gemini-1.5-pro',
        'gemini-1.0-pro',
      ];

      Exception? lastException;

      for (final m in candidateModels) {
        try {
          final model = GenerativeModel(
            model: m,
            apiKey: _apiKey,
            systemInstruction: Content.system('''
Bạn là trợ lý trích xuất ý định từ câu nói cho ứng dụng Todo. Chỉ trả về JSON duy nhất, không Markdown, không giải thích.

=== THÔNG TIN THỜI GIAN HIỆN TẠI ===
- Hôm nay: $todayStr
- Ngày mai: $tomorrowStr
- Giờ hiện tại: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
=====================================

Khi người dùng nói "ngày mai" → date = "$tomorrowStr"
Khi người dùng nói "hôm nay" → date = "$todayStr"
Khi người dùng nói "tuần sau" → cộng thêm 7 ngày từ hôm nay.
Trường "date" LUÔN theo định dạng YYYY-MM-DD hoặc null.
Trường "time" LUÔN theo định dạng HH:mm (24h) hoặc null.

Có ba kiểu JSON hợp lệ:

1) Task:
{
  "type": "task",
  "way": "long_term_task" | "promodoro" hoặc null,
  "task_name": "Tiêu đề công việc",
  "date": "YYYY-MM-DD" hoặc null,
  "time": "HH:mm" hoặc null,
  "person": "Tên người" hoặc null,
  "category": "Công việc" | "Học tập" | "Cá nhân" hoặc null
}

2) Command (điều hướng):
{
  "type": "command",
  "action": "navigate",
  "target": "charts" | "calendar" | "dashboard" | "profile" | "stats",
  "params": {}
}

3) Không hiểu:
{
  "type": "noop"
}

CHỈ TRẢ VỀ JSON. KHÔNG THÊM BẤT KỲ VĂN BẢN NÀO KHÁC.
'''),
          );

          final response = await model.generateContent([Content.text(userText)]);
          final jsonText = response.text;
          if (jsonText != null) {
            final cleanJson =
                jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
              try {
                return jsonDecode(cleanJson) as Map<String, dynamic>;
              } catch (_) {
                try {
                  final start = cleanJson.indexOf('{');
                  final end = cleanJson.lastIndexOf('}');
                  if (start != -1 && end != -1 && end > start) {
                    return jsonDecode(cleanJson.substring(start, end + 1))
                        as Map<String, dynamic>;
                  }
                } catch (_) {}
                if (kDebugMode) debugPrint('AIService: cannot parse JSON: $cleanJson');
                return null;
              }
          }
        } catch (e) {
          lastException = e as Exception? ?? Exception(e.toString());
          if (kDebugMode) debugPrint('AIService: model "$m" failed: $e');
          continue;
        }
      }

      if (kDebugMode) debugPrint('AIService: all models failed. Last error: $lastException');
      // Fallback heuristic
      final heuristic = _heuristicExtract(userText);
      if (heuristic != null) {
        if (kDebugMode) debugPrint('AIService: heuristic fallback: $heuristic');
        return heuristic;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Lỗi xử lý AI: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> extractTaskFromText(String userText) async {
    final intent = await extractIntentFromText(userText);
    if (intent == null) {
      return null;
    }
    if ((intent['type'] as String?) == 'task') {
      return intent;
    }
    return null;
  }

  void handleVoiceInput(String resultText) async {
    final intent = await extractIntentFromText(resultText);
    if (intent != null && intent['type'] == 'task') {
      if (kDebugMode) debugPrint('Đã bóc tách: ${intent['task_name']} ngày ${intent['date']} lúc ${intent['time']}');
    }
  }

  Map<String, dynamic>? _heuristicExtract(String text) {
    final raw = text.trim().toLowerCase();
    if (raw.isEmpty) {
      return null;
    }

    if (!(raw.contains('thêm') ||
        raw.contains('tạo') ||
        raw.contains('nhiệm vụ') ||
        raw.contains('việc'))) {
      return null;
    }

    final now = DateTime.now();
    String? date;
    String? time;
    bool dateFromRelative = false;

    // Relative dates
    if (raw.contains('ngày mai')) {
      final d = now.add(const Duration(days: 1));
      date =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      dateFromRelative = true;
    } else if (raw.contains('hôm nay')) {
      date =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      dateFromRelative = true;
    } else if (raw.contains('tuần sau')) {
      final d = now.add(const Duration(days: 7));
      date =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      dateFromRelative = true;
    }

    // Explicit date dd/MM/yyyy hoặc dd-MM-yyyy
    final dateRegex = RegExp(r'(\d{1,2}[\/\-]\d{1,2}(?:[\/\-]\d{2,4})?)');
    final dateMatch = dateRegex.firstMatch(raw);
    if (dateMatch != null && !dateFromRelative) {
      final parts = dateMatch.group(0)!.replaceAll('/', '-').split('-');
      if (parts.length >= 2) {
        final d = parts[0].padLeft(2, '0');
        final mo = parts[1].padLeft(2, '0');
        String y;
        if (parts.length >= 3) {
          y = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
        } else {
          y = now.year.toString();
        }
        date = '${y.padLeft(4, '0')}-$mo-$d';
      }
    }

    // Time HH:mm
    final timeRegex = RegExp(r'(\d{1,2}:\d{2})');
    final timeMatch = timeRegex.firstMatch(raw);
    if (timeMatch != null) {
      final tp = timeMatch.group(0)!.split(':');
      time =
          '${tp[0].padLeft(2, '0')}:${tp[1].padLeft(2, '0')}';
    } else {
      final vnTime = RegExp(r'lúc\s*(\d{1,2})(?:\s*giờ)?(?:\s*(\d{1,2}))?');
      final vm = vnTime.firstMatch(raw);
      if (vm != null) {
        final hh = int.tryParse(vm.group(1) ?? '0') ?? 0;
        final mm = int.tryParse(vm.group(2) ?? '0') ?? 0;
        time =
            '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
      }
    }

    // Task name
    var name = raw;
    name = name.replaceAll(
        RegExp(r'\b(thêm|tạo|nhiệm vụ|việc|cho|vào|lúc|ngày mai|hôm nay|tuần sau|vào ngày|vào lúc)\b'),
        '');
    if (dateMatch != null) name = name.replaceAll(dateMatch.group(0)!, '');
    if (timeMatch != null) name = name.replaceAll(timeMatch.group(0)!, '');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (name.isEmpty) {
      name = 'Công việc mới';
    }

    return {
      'type': 'task',
      'task_name': name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : ''),
      'date': date,
      'time': time,
      'person': null,
    };
  }
}
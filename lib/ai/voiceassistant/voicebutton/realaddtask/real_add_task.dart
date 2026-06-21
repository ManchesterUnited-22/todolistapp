import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_input_dialog.dart';
import 'package:smart_app/views/task_viewmodel.dart';

Future<void> collectLongTaskWithVoiceForm(
  BuildContext context, {
  String? initialTranscript,
  ValueChanged<String>? onTaskAdded,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để lưu nhiệm vụ')),
    );
    return;
  }

  // Nếu đã có transcript từ màn hình trước thì dùng luôn, không cần ghi âm lại
  final String? firstTranscript =
      (initialTranscript != null && initialTranscript.trim().isNotEmpty)
          ? initialTranscript.trim()
          : null;

  await _runVoiceTaskFlow(
    context,
    uid: user.uid,
    firstTranscript: firstTranscript,
    onTaskAdded: onTaskAdded,
  );
}

// ─── Toàn bộ luồng chạy tuần tự, không có form UI ──────────────────────────
Future<void> _runVoiceTaskFlow(
  BuildContext context, {
  required String uid,
  String? firstTranscript,
  ValueChanged<String>? onTaskAdded,
}) async {
  final ai = VoiceAiService.instance;

  // ── Bước 1: Ghi âm nhiệm vụ ─────────────────────────────────────────────
  String? transcript = firstTranscript;

  if (transcript == null) {
    await SystemSound.play(SystemSoundType.click);
    await ai.speakText('Mình đang nghe đây. Bạn nói câu đầy đủ nhé, ví dụ: dọn dẹp nhà cửa vào lúc chín giờ sáng mai.');

    if (!context.mounted) return;
    transcript = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(
        prompt: 'Nói câu đầy đủ: tên việc, thời gian, ưu tiên...',
        longListen: true,
      ),
    );
  }

  if (!context.mounted) return;
  if (transcript == null || transcript.trim().isEmpty) return;
  transcript = transcript.trim();

  // ── Bước 2: Parse thông tin ──────────────────────────────────────────────
  String title    = _extractTitle(transcript) ?? transcript;
  String priority = _parsePriority(transcript) ?? 'Vừa';
  String category = _parseCategory(transcript) ?? 'Công việc';
  DateTime? dueAt = _parseDueAt(transcript);

  // ── Bước 3: AI đọc lại tóm tắt ──────────────────────────────────────────
  await ai.speakText(
    'Được rồi! ${_buildSummary(title, priority, category, dueAt)} '
    'Bạn có muốn chỉnh sửa gì không?',
  );

  // ── Bước 4 & 5: Vòng lặp chỉnh sửa → xác nhận lưu ──────────────────────
  //
  // Luồng:
  //   [hỏi chỉnh gì không?]
  //     ├─ user chỉnh → apply → đọc lại → [hỏi lưu chưa?]
  //     └─ user không chỉnh → [hỏi lưu chưa?]
  //
  //   [hỏi lưu chưa?]
  //     ├─ user đồng ý → break → lưu
  //     └─ user chưa → quay lại [hỏi chỉnh gì không?]

  while (true) {
    if (!context.mounted) return;

    // ── 4a: Nghe xem user muốn chỉnh gì (longListen để nghe câu dài) ──────
    final editAnswer = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(
        prompt: 'Bạn muốn chỉnh gì không?',
        longListen: true,
      ),
    );

    if (!context.mounted) return;
    if (editAnswer == null || editAnswer.trim().isEmpty) return;

    final trimmed = editAnswer.trim();

    if (_wantsToEdit(trimmed)) {
      // ── 4b: Apply chỉnh sửa ───────────────────────────────────────────
      final newPriority = _parsePriority(trimmed);
      final newCategory = _parseCategory(trimmed);
      final newDueAt    = _parseDueAt(trimmed);
      final newTitle    = _extractEditTitle(trimmed);

      if (newPriority != null) priority = newPriority;
      if (newCategory != null) category = newCategory;
      if (newDueAt != null)    dueAt    = newDueAt;
      if (newTitle != null)    title    = newTitle;

      await ai.speakText(
        'Đã cập nhật. ${_buildSummary(title, priority, category, dueAt)}',
      );
    }

    // ── 5: Hỏi xác nhận lưu (luôn hỏi, dù có chỉnh hay không) ──────────
    if (!context.mounted) return;
    await ai.speakText('Bạn muốn lưu nhiệm vụ này chứ?');

    final confirmAnswer = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(
        prompt: 'Lưu nhiệm vụ này không?',
        longListen: true,
      ),
    );

    if (!context.mounted) return;

    if (confirmAnswer != null && _wantsToConfirm(confirmAnswer.trim())) {
      await ai.speakText('Okie! Mình lưu lại nhé!');
      break; // thoát → lưu
    }

    // Chưa đồng ý → hỏi lại chỉnh gì nữa
    await ai.speakText('Được, bạn muốn chỉnh thêm gì nữa không?');
  }

  // ── Bước 6: Lưu Firestore ────────────────────────────────────────────────
  if (!context.mounted) return;

  try {
    final now = DateTime.now();
    final due = dueAt ?? now.add(const Duration(days: 1));
    final task = TaskViewModel(
      id: now.microsecondsSinceEpoch,
      title: title,
      detail: '',
      category: category,
      priority: priority,
      way: 'long_term_task',
      stat: 'Đang làm',
      createdAt: Timestamp.fromDate(now),
      dueAt: Timestamp.fromDate(due),
      dateString:
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}',
      timestamp: Timestamp.fromDate(now),
      uid: uid,
    );

    await FirebaseFirestore.instance.collection('tasks').add(task.toFirestoreMap());
    onTaskAdded?.call(task.title);

    await SystemSound.play(SystemSoundType.click);
    await ai.speakText('Đã lưu nhiệm vụ "${task.title}" thành công!');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ Đã lưu: ${task.title}')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu: $e')),
      );
    }
  }
}

// ── Tạo câu tóm tắt đọc rõ ràng, không viết tắt tháng/ngày ────────────────
String _buildSummary(String title, String priority, String category, DateTime? dueAt) {
  String dueText;
  if (dueAt != null) {
    final hour   = dueAt.hour;
    final minute = dueAt.minute;
    final day    = dueAt.day;
    final month  = dueAt.month;
    final year   = dueAt.year;

    final minuteStr = minute == 0 ? '' : ' $minute phút';
    final ampm = hour < 12 ? 'sáng' : (hour < 18 ? 'chiều' : 'tối');
    final h12  = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    dueText = 'vào lúc $h12 giờ$minuteStr $ampm, '
        'ngày $day tháng $month năm $year';
  } else {
    dueText = 'chưa có thời gian cụ thể';
  }

  return 'Mình hiểu bạn muốn thêm nhiệm vụ "$title", '
      'loại $category, '
      'ưu tiên $priority, '
      '$dueText.';
}

// ── Phát hiện user đồng ý lưu ───────────────────────────────────────────────
bool _wantsToConfirm(String answer) {
  final lower = answer.toLowerCase().trim();
  const yesPhrases = [
    'có', 'ừ', 'uh', 'ok', 'oke', 'được', 'đúng', 'lưu', 'lưu đi',
    'lưu luôn', 'đồng ý', 'xác nhận', 'chắc', 'chắc rồi', 'chuẩn',
    'yes', 'yep', 'sure', 'right',
  ];
  for (final p in yesPhrases) {
    if (lower == p || lower.startsWith(p) || lower.contains(p)) return true;
  }
  return false;
}

// ── Phát hiện user muốn chỉnh hay không ────────────────────────────────────
bool _wantsToEdit(String answer) {
  final lower = answer.toLowerCase().trim();
  // Các cụm từ "không cần chỉnh"
  const noEditPhrases = [
    'không', 'ko', 'k', 'thôi', 'oke', 'ok', 'được rồi',
    'không cần', 'lưu đi', 'lưu luôn', 'không chỉnh', 'không sửa',
    'bình thường', 'vậy thôi', 'xong rồi', 'đúng rồi', 'chuẩn',
  ];
  for (final phrase in noEditPhrases) {
    if (lower == phrase || lower.startsWith(phrase) || lower.contains(phrase)) {
      return false;
    }
  }
  return true; // còn lại đều coi là muốn chỉnh
}

// ── Trích tên mới khi user nói chỉnh (ví dụ "đổi tên thành X") ─────────────
String? _extractEditTitle(String input) {
  final m = RegExp(
    r'(?:đổi tên|tên mới|tên là|đặt tên)\s*(?:thành|là|:)?\s*([^,;.]+)',
    caseSensitive: false,
  ).firstMatch(input);
  return m?.group(1)?.trim();
}

// ─── Parse helpers (giữ nguyên từ trước) ────────────────────────────────────
String? _extractTitle(String input) {
  final normalized = input.trim();
  if (normalized.isEmpty) return null;

  final explicitName = RegExp(
    r'(?:tên(?:\s+(?:công\s+)?việc)?|nhiệm\s+vụ)\s*(?:là|:)?\s*([^,;.]+)',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (explicitName != null) {
    final v = (explicitName.group(1) ?? '').trim();
    if (v.isNotEmpty) return _capitalizeFirst(v);
  }

  final cutKeywords = [
    'vào lúc', 'vào', 'lúc', 'hạn', 'đến', 'trước',
    'ngày mai', 'hôm nay', 'tuần sau', 'sáng mai', 'chiều mai', 'tối nay',
    'ưu tiên', 'độ ưu', 'loại', 'danh mục',
  ];

  final lower = normalized.toLowerCase();
  int cutIndex = normalized.length;

  for (final kw in cutKeywords) {
    final idx = lower.indexOf(kw);
    if (idx > 2 && idx < cutIndex) cutIndex = idx;
  }

  final timeNumRegex = RegExp(r'\d{1,2}\s*giờ|\d{1,2}:\d{2}');
  for (final m in timeNumRegex.allMatches(lower)) {
    if (m.start > 2 && m.start < cutIndex) cutIndex = m.start;
  }

  if (cutIndex > 0 && cutIndex < normalized.length) {
    var title = normalized.substring(0, cutIndex).trim();
    title = title.replaceAll(RegExp(r'[,;.\-]+$'), '').trim();
    if (title.isNotEmpty) return _capitalizeFirst(title);
  }

  return _capitalizeFirst(normalized);
}

String _capitalizeFirst(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String? _parsePriority(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('cao') || lower.contains('high')) return 'Cao';
  if (lower.contains('thấp') || lower.contains('thap') || lower.contains('low')) return 'Thấp';
  if (lower.contains('vừa') || lower.contains('vua') || lower.contains('medium')) return 'Vừa';
  return null;
}

String? _parseCategory(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('ca nhan') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('suc') || lower.contains('health')) return 'Sức khỏe';
  if (lower.contains('công') || lower.contains('cong') || lower.contains('work')) return 'Công việc';
  return null;
}

DateTime? _parseDueAt(String input) {
  final lower = input.toLowerCase().trim();
  final now = DateTime.now();
  DateTime base = now;

  final dateRegex = RegExp(r'(\d{1,2})[\/-](\d{1,2})(?:[\/-](\d{2,4}))?');
  final dateMatch = dateRegex.firstMatch(lower);
  if (dateMatch != null) {
    final d = int.tryParse(dateMatch.group(1) ?? '') ?? now.day;
    final m = int.tryParse(dateMatch.group(2) ?? '') ?? now.month;
    int y;
    if (dateMatch.group(3) != null) {
      y = int.tryParse(dateMatch.group(3)!) ?? now.year;
      if (y < 100) y += 2000;
    } else {
      y = now.year;
    }
    base = DateTime(y, m, d);
  } else if (lower.contains('ngày mai') || lower.contains('mai')) {
    base = now.add(const Duration(days: 1));
  } else if (lower.contains('tuần sau')) {
    base = now.add(const Duration(days: 7));
  }

  int? hour;
  int minute = 0;

  final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
  if (hm != null) {
    hour   = int.tryParse(hm.group(1) ?? '0') ?? 0;
    minute = int.tryParse(hm.group(2) ?? '0') ?? 0;
  } else {
    final gioPhut = RegExp(r'(\d{1,2})\s*gi[oờ]\s*(\d{1,2})\s*ph[uú]t').firstMatch(lower);
    if (gioPhut != null) {
      hour   = int.tryParse(gioPhut.group(1) ?? '0') ?? 0;
      minute = int.tryParse(gioPhut.group(2) ?? '0') ?? 0;
    } else {
      final gioRuoi = RegExp(r'(\d{1,2})\s*gi[oờ]\s*r[uư][ỡo]i').firstMatch(lower);
      if (gioRuoi != null) {
        hour   = int.tryParse(gioRuoi.group(1) ?? '0') ?? 0;
        minute = 30;
      } else {
        final gioOnly = RegExp(r'(\d{1,2})\s*gi[oờ]').firstMatch(lower);
        if (gioOnly != null) {
          hour = int.tryParse(gioOnly.group(1) ?? '0') ?? 0;
        }
      }
    }
  }

  if (hour == null) return null;
  if ((lower.contains('chiều') || lower.contains('tối')) && hour < 12) hour += 12;

  return DateTime(base.year, base.month, base.day, hour, minute);
}
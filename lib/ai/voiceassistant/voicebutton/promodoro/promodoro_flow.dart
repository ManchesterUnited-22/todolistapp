import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/views/task_viewmodel.dart';
import '../voice_input_dialog.dart';

/// Promodoro voice form: user speaks one sentence, system asks for missing info.
Future<void> collectPromodoroFlow(BuildContext context, {String? initialTranscript}) async {
  final scaffold = ScaffoldMessenger.of(context);
  try {
    final ai = VoiceAiService.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu nhiệm vụ')),
      );
      return;
    }

    await SystemSound.play(SystemSoundType.click);
    await ai.speakText(
      'Mình đang nghe đây. Hãy nói một câu gồm tên task, thời gian tập trung và thời gian nghỉ.',
    );

    String? transcript = initialTranscript?.trim();
    if (transcript == null || transcript.isEmpty) {
      transcript = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const VoiceInputDialog(
          prompt: 'Ví dụ: Tạo promodoro ôn toán, làm 25 phút, nghỉ 5 phút',
          longListen: true,
        ),
      );
    }

    final parsed = _parsePromodoroFromSpeech(transcript ?? '');

    String? title = parsed.title;
    int? focusMinutes = parsed.focusMinutes;
    int? breakMinutes = parsed.breakMinutes;
    String category = parsed.category ?? 'Công việc';

    if (title == null || title.trim().isEmpty) {
      title = await _askByVoice(
        context,
        ai,
        'Tên task promodoro là gì vậy nhỉ?',
      );
      title = title?.trim();
    }

    if (focusMinutes == null) {
      final focusInput = await _askByVoice(
        context,
        ai,
        'Thời gian tập trung bao nhiêu phút vậy nhỉ?',
      );
      focusMinutes = _extractFirstMinute(focusInput ?? '');
    }

    if (breakMinutes == null) {
      final breakInput = await _askByVoice(
        context,
        ai,
        'Thời gian giải lao bao nhiêu phút vậy nhỉ?',
      );
      breakMinutes = _extractFirstMinute(breakInput ?? '');
    }

    // Optional category follow-up.
    if ((parsed.category ?? '').isEmpty) {
      final categoryInput = await _askByVoice(
        context,
        ai,
        'Bạn muốn xếp task này vào loại gì? Ví dụ Công việc, Học tập, Cá nhân hoặc Sức khỏe',
      );
      if (categoryInput != null && categoryInput.trim().isNotEmpty) {
        category = _parseCategory(categoryInput);
      }
    }

    if (title == null || title.trim().isEmpty) {
      scaffold.showSnackBar(const SnackBar(content: Text('Huỷ: không có tiêu đề')));
      return;
    }

    focusMinutes ??= 25;
    breakMinutes ??= 5;

    // Priority: always Cao for Promodoro
    final priority = 'Cao';

    // Build TaskViewModel
    final task = TaskViewModel(
      title: title.trim(),
      detail: '',
      category: category,
      priority: priority,
      way: 'promodoro',
      stat: 'Đang làm',
      createdAt: null,
      dueAt: null,
      focusDuration: focusMinutes,
      breakDuration: breakMinutes,
      uid: currentUser.uid,
    );

    // AI readback and confirm
    final summary = 'Promodoro: "${task.title}", làm $focusMinutes phút, nghỉ $breakMinutes phút, loại ${task.category}. Lưu không?';
    await ai.speakText(summary);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Promodoro'),
        content: Text(summary),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Lưu')),
        ],
      ),
    );
    if (confirmed != true) {
      scaffold.showSnackBar(const SnackBar(content: Text('Đã hủy')));
      return;
    }

    // Save to Firestore with promodoro fields
    final doc = task.toFirestoreMap(useServerTimestampForCreatedAt: true);
    await FirebaseFirestore.instance.collection('tasks').add(doc);

    scaffold.showSnackBar(SnackBar(content: Text('✓ Đã lưu Promodoro: ${task.title}')));
  } catch (e) {
    scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi lưu Promodoro: $e')));
  }
}

Future<String?> _askByVoice(
  BuildContext context,
  VoiceAiService ai,
  String prompt,
) async {
  await SystemSound.play(SystemSoundType.click);
  await ai.speakText(prompt);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => VoiceInputDialog(prompt: prompt, longListen: true),
  );
}

_PromodoroSpeechParse _parsePromodoroFromSpeech(String input) {
  final normalized = input.trim();
  if (normalized.isEmpty) {
    return const _PromodoroSpeechParse();
  }

  final lower = normalized.toLowerCase();
  final numbers = RegExp(r'(\d{1,3})').allMatches(lower).map((m) => int.tryParse(m.group(1)!)).whereType<int>().toList();

  int? focus;
  int? rest;
  final focusRegex = RegExp(r'(làm|tập trung|focus)\s*(\d{1,3})');
  final breakRegex = RegExp(r'(nghỉ|break)\s*(\d{1,3})');
  final focusMatch = focusRegex.firstMatch(lower);
  final breakMatch = breakRegex.firstMatch(lower);

  if (focusMatch != null) {
    focus = int.tryParse(focusMatch.group(2) ?? '');
  }
  if (breakMatch != null) {
    rest = int.tryParse(breakMatch.group(2) ?? '');
  }

  if (focus == null && numbers.isNotEmpty) focus = numbers.first;
  if (rest == null && numbers.length >= 2) rest = numbers[1];

  String title = normalized;
  title = title
      .replaceAll(RegExp(r'\b(tạo|tao|thêm|lam|làm|promodoro|pomodoro|timer|task|nhiệm vụ)\b', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\b(nghỉ|break|phút|minute|minutes|focus|tập trung)\b\s*\d{0,3}', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\d{1,3}'), ' ')
      .replaceAll(RegExp(r'[,:;\-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (title.length < 2) {
    title = '';
  }

  return _PromodoroSpeechParse(
    title: title.isEmpty ? null : _normalizeTitle(title),
    focusMinutes: focus,
    breakMinutes: rest,
    category: _parseCategory(input),
  );
}

int? _extractFirstMinute(String input) {
  final match = RegExp(r'(\d{1,3})').firstMatch(input);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

String _normalizeTitle(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

String _parseCategory(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('health')) return 'Sức khỏe';
  return 'Công việc';
}

class _PromodoroSpeechParse {
  final String? title;
  final int? focusMinutes;
  final int? breakMinutes;
  final String? category;

  const _PromodoroSpeechParse({
    this.title,
    this.focusMinutes,
    this.breakMinutes,
    this.category,
  });
}
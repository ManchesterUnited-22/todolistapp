import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../ai/voice_ai_service.dart';
import '../../views/task_viewmodel.dart';
import 'voice_input_dialog.dart';

Future<void> collectVoiceTaskSequential(BuildContext context, {String? initialTranscript}) async {
  final scaffold = ScaffoldMessenger.of(context);
  try {
    final ai = VoiceAiService.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      scaffold.showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để lưu nhiệm vụ')));
      return;
    }

    // Title
    String? title;
    if (initialTranscript != null && initialTranscript.trim().isNotEmpty) {
      final use = await _confirmUseTranscript(context, initialTranscript.trim());
      if (use == true) title = initialTranscript.trim();
    }
    if (title == null) {
      await ai.speakText('Tiêu đề công việc là gì?');
      title = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Tiêu đề công việc là gì?'));
    }
    if (title == null || title.trim().isEmpty) {
      scaffold.showSnackBar(const SnackBar(content: Text('Huỷ: không có tiêu đề')));
      return;
    }

    // Priority
    await ai.speakText('Độ ưu tiên? Cao, Vừa hay Thấp?');
    final priorityInput = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Độ ưu tiên: Cao, Vừa hay Thấp?'));
    if (priorityInput == null) {
      final saved = await _offerSaveDraft(context, title: title.trim());
      if (!saved) scaffold.showSnackBar(const SnackBar(content: Text('Đã huỷ')));
      return;
    }
    final priority = _parsePriority(priorityInput);

    // Category
    await ai.speakText('Loại công việc? Ví dụ: Công việc, Học tập, Cá nhân, Sức khỏe');
    final categoryInput = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Loại công việc? (Công việc / Học tập / Cá nhân / Sức khỏe)'));
    if (categoryInput == null) {
      final saved = await _offerSaveDraft(context, title: title.trim(), priority: priority);
      if (!saved) scaffold.showSnackBar(const SnackBar(content: Text('Đã huỷ')));
      return;
    }
    final category = _parseCategory(categoryInput);

    // DueAt
    await ai.speakText('Có thời gian hẹn không? Nói "không" nếu không.');
    final dueAtInput = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Thời gian hẹn? (Nói "không" hoặc ví dụ "ngày mai 15:00")'));
    if (dueAtInput == null) {
      final saved = await _offerSaveDraft(context, title: title.trim(), priority: priority, category: category);
      if (!saved) scaffold.showSnackBar(const SnackBar(content: Text('Đã huỷ')));
      return;
    }
    Timestamp? dueAt;
    if (dueAtInput.toLowerCase().trim() != 'không') {
      dueAt = _parseDueAtToTimestamp(dueAtInput);
    }

    final task = TaskViewModel(
      title: title.trim(),
      detail: '',
      category: category,
      priority: priority,
      way: 'long_term_task',
      stat: 'Đang làm',
      createdAt: null,
      dueAt: dueAt,
      uid: currentUser.uid,
    );

    // AI confirmation
    final dueStr = dueAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(dueAt.toDate()) : 'không có';
    final summary = 'Bạn muốn lưu nhiệm vụ "${task.title}" với độ ưu tiên ${task.priority}, loại ${task.category}, thời hạn: $dueStr. Bạn có đồng ý không?';
    await ai.speakText(summary);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận nhiệm vụ'),
        content: Text(summary),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Lưu')),
        ],
      ),
    );
    if (confirmed != true) {
      final saved = await _offerSaveDraft(context, title: title.trim(), priority: priority, category: category, dueAt: dueAt);
      if (!saved) scaffold.showSnackBar(const SnackBar(content: Text('Đã hủy lưu nhiệm vụ')));
      return;
    }

    await FirebaseFirestore.instance.collection('tasks').add(task.toFirestoreMap(useServerTimestampForCreatedAt: true));
    scaffold.showSnackBar(SnackBar(content: Text('✓ Đã lưu nhiệm vụ: ${task.title}')));
  } catch (e) {
    scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi lưu nhiệm vụ: $e')));
  }
}

String _parsePriority(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('cao') || lower.contains('high')) return 'Cao';
  if (lower.contains('thấp') || lower.contains('low')) return 'Thấp';
  return 'Vừa';
}

String _parseCategory(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('health')) return 'Sức khỏe';
  return 'Công việc';
}

Timestamp _parseDueAtToTimestamp(String input) {
  final lower = input.toLowerCase().trim();
  final now = DateTime.now();
  DateTime base = now;

  final dateRegex = RegExp(r'(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?');
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
  } else {
    if (lower.contains('ngày mai') || lower.contains('mai')) base = now.add(const Duration(days: 1));
    else if (lower.contains('hôm nay') || lower.contains('hom nay')) base = now;
    else if (lower.contains('tuần sau')) base = now.add(const Duration(days: 7));
  }

  int? hour;
  int minute = 0;
  final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
  if (hm != null) {
    hour = int.tryParse(hm.group(1) ?? '0') ?? 0;
    minute = int.tryParse(hm.group(2) ?? '0') ?? 0;
  } else {
    final ampm = RegExp(r'(\d{1,2})\s*(am|pm)\b').firstMatch(lower);
    if (ampm != null) {
      hour = int.tryParse(ampm.group(1) ?? '0') ?? 0;
      final t = ampm.group(2);
      if (t == 'pm' && hour < 12) hour += 12;
      if (t == 'am' && hour == 12) hour = 0;
    } else {
      final hmatch = RegExp(r'(\d{1,2})\s*(h|giờ)\s*(sáng|trưa|chiều|tối)?').firstMatch(lower);
      if (hmatch != null) {
        hour = int.tryParse(hmatch.group(1) ?? '0') ?? 0;
        final suff = hmatch.group(3);
        if (suff != null) {
          if (suff.contains('chiều') || suff.contains('tối')) {
            if (hour < 12) hour = hour + 12;
          } else if (suff.contains('trưa')) {
            if (hour < 11) hour = hour + 12;
          } else if (suff.contains('sáng')) {
            if (hour == 12) hour = 0;
          }
        }
      } else {
        final onlyNum = RegExp(r'\b(\d{1,2})\b').firstMatch(lower);
        if (onlyNum != null) {
          hour = int.tryParse(onlyNum.group(1) ?? '0') ?? 0;
        }
      }
    }
  }

  if (hour != null) {
    if ((lower.contains('chiều') || lower.contains('tối')) && hour < 12) hour = hour + 12;
    if (lower.contains('sáng') && hour == 12) hour = 0;
    if (lower.contains('trưa') && hour < 11) hour = hour + 12;
  }

  final finalHour = hour ?? 9;
  final dt = DateTime(base.year, base.month, base.day, finalHour, minute);
  return Timestamp.fromDate(dt);
}

Future<bool> _offerSaveDraft(BuildContext context, {required String title, String? priority, String? category, Timestamp? dueAt}) async {
  final scaffold = ScaffoldMessenger.of(context);
  if ((title.trim()).isEmpty && priority == null && category == null && dueAt == null) {
    scaffold.showSnackBar(const SnackBar(content: Text('Không có dữ liệu để lưu nháp')));
    return false;
  }

  final save = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Lưu nháp'),
      content: const Text('Bạn có muốn lưu nháp công việc này không?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Lưu nháp')),
      ],
    ),
  );

  if (save != true) return false;
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    scaffold.showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để lưu nháp')));
    return false;
  }

  final task = TaskViewModel(
    title: title.trim().isEmpty ? 'Nháp không tiêu đề' : title.trim(),
    detail: '',
    category: category ?? 'Chưa rõ',
    priority: priority ?? 'Vừa',
    way: 'long_term_task',
    stat: 'Nháp',
    createdAt: null,
    dueAt: dueAt,
    uid: currentUser.uid,
  );

  await FirebaseFirestore.instance.collection('tasks').add(task.toFirestoreMap(useServerTimestampForCreatedAt: true));
  scaffold.showSnackBar(const SnackBar(content: Text('Đã lưu nháp')));
  return true;
}

Future<bool?> _confirmUseTranscript(BuildContext context, String transcript) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Sử dụng nội dung phát hiện'),
      content: Text('Phát hiện: "$transcript"\nBạn có muốn sử dụng làm tiêu đề không?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Có')),
      ],
    ),
  );
}

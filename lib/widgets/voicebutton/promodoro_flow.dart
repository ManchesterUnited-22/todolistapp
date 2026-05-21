import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ai/voice_ai_service.dart';
import '../../views/task_viewmodel.dart';
import 'voice_input_dialog.dart';

/// Promodoro flow: title, duration, category. Priority fixed to 'Cao'.
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

    // Title (use initial transcript if provided)
    String? title;
    if (initialTranscript != null && initialTranscript.trim().isNotEmpty) {
      final use = await _confirmUseTranscript(context, initialTranscript.trim());
      if (use == true) title = initialTranscript.trim();
    }
    if (title == null) {
      await ai.speakText('Tiêu đề nhiệm vụ Promodoro là gì?');
      title = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Tiêu đề nhiệm vụ Promodoro là gì?'));
    }
    if (title == null || title.trim().isEmpty) {
      scaffold.showSnackBar(const SnackBar(content: Text('Huỷ: không có tiêu đề')));
      return;
    }

    // Duration
    await ai.speakText('Thời lượng tập trung tính bằng phút, ví dụ 25 phút.');
    final durationInput = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VoiceInputDialog(prompt: 'Thời lượng (phút)? Ví dụ 25'),
    );
    int focusMinutes = 25;
    if (durationInput != null) {
      final m = RegExp(r'(\d{1,3})').firstMatch(durationInput);
      if (m != null) focusMinutes = int.tryParse(m.group(1) ?? '25') ?? 25;
    }

    // Break duration
    await ai.speakText('Thời gian giải lao bao nhiêu phút?');
    final breakInput = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VoiceInputDialog(prompt: 'Thời gian giải lao? Ví dụ 25'),
    );
    int breakMinutes = 5;
    if (breakInput != null) {
      final m = RegExp(r'(\d{1,3})').firstMatch(breakInput);
      if (m != null) breakMinutes = int.tryParse(m.group(1) ?? '5') ?? 5;
    }

    // Category
    await ai.speakText('Loại công việc? Ví dụ: Công việc, Học tập, Cá nhân, Sức khỏe');
    final categoryInput = await showDialog<String>(context: context, barrierDismissible: false, builder: (_) => VoiceInputDialog(prompt: 'Loại công việc cho Promodoro?'));
    final category = categoryInput == null ? 'Công việc' : _parseCategory(categoryInput);

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
    final summary = 'Promodoro: "${task.title}", thời lượng làm $focusMinutes phút, nghỉ $breakMinutes phút, loại ${task.category}. Lưu không?';
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

String _parseCategory(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('health')) return 'Sức khỏe';
  return 'Công việc';
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

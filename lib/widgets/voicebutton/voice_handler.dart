import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ai/ai_services.dart';
import 'voice_identity.dart';
import 'promodoro_process.dart';

class VoiceHandler {
  static Future<void> process(String transcript, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
        const SnackBar(content: Text('Đang xử lý giọng nói...')));

    try {
        final ai = AIService.instance;
        final Map<String, dynamic>? intent =
          await ai.extractIntentFromText(transcript);

      final extractedIntent = intent ?? <String, dynamic>{};
      final String? type = (extractedIntent['type'] as String?)?.trim();

      // --- Điều hướng ---
      if (type == 'command' && (extractedIntent['action'] as String?) == 'navigate') {
        final String? target = extractedIntent['target'] as String?;
        final Map<String, dynamic> params =
          (extractedIntent['params'] as Map<String, dynamic>?) ?? {};

        switch (target) {
          case 'charts':
          case 'stats':
            Navigator.of(context).pushNamed('/stats', arguments: params);
            scaffold.showSnackBar(
                const SnackBar(content: Text('Đang mở trang thống kê')));
            return;
          case 'calendar':
            Navigator.of(context).pushNamed('/calendar', arguments: params);
            scaffold.showSnackBar(
                const SnackBar(content: Text('Đang mở lịch')));
            return;
          case 'dashboard':
            Navigator.of(context).pushNamed('/dashboard', arguments: params);
            scaffold.showSnackBar(
                const SnackBar(content: Text('Quay về trang chính')));
            return;
          case 'profile':
            Navigator.of(context).pushNamed('/profile', arguments: params);
            scaffold.showSnackBar(
                const SnackBar(content: Text('Đang mở trang hồ sơ')));
            return;
          default:
            scaffold.showSnackBar(
                const SnackBar(content: Text('Lệnh điều hướng không hợp lệ')));
            return;
        }
        return;
      }

      // --- Không hiểu ---
      if (type == 'noop') {
        scaffold.showSnackBar(
            const SnackBar(content: Text('Không hiểu lệnh, sẽ chuyển sang nhập từng bước.')));
      }

      // --- Lưu task theo wizard từng bước ---
      final draft = await collectVoiceTaskDraft(
        context,
        transcript: transcript,
        intent: extractedIntent,
      );
      if (draft == null) return;

      final currentUser = FirebaseAuth.instance.currentUser;

      DateTime? dueAt = draft.dueAt;
      if (dueAt != null) {
        try {
          final alt = await showVoiceScheduleNudge(context, draft.title, dueAt);
          if (alt != null) dueAt = alt;
        } catch (_) {}
      }

      final now = DateTime.now();
      final dateString =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final doc = <String, dynamic>{
        'task_name': draft.title,
        'title': draft.title,
        'detail': null,
        'category': draft.category,
        'priority': draft.priority,
        'way': draft.way,
        'stat': 'Đang làm',
        if (draft.way == 'promodoro') 'focus_duration': draft.durationMinutes,
        if (draft.way == 'promodoro') 'break_duration': 5,
        if (draft.way == 'long_term_task') 'total_focus_time': draft.durationMinutes,
        if (dueAt != null) 'dueAt': Timestamp.fromDate(dueAt),
        'createdAt': FieldValue.serverTimestamp(),
        'date_string': dateString,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': currentUser?.uid ?? '',
      };

      await FirebaseFirestore.instance.collection('tasks').add(doc);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Đã lưu nhiệm vụ từ giọng nói'),
          action: draft.way == 'promodoro'
              ? SnackBarAction(
                  label: 'Promodoro',
                  onPressed: () {
                    showPromodoroQuickDialog(
                      context,
                      taskTitle: draft.title,
                      initialFocusMinutes: draft.durationMinutes,
                      initialBreakMinutes: 5,
                    );
                  },
                )
              : null,
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi lưu task: $e')));
    }
  }
}
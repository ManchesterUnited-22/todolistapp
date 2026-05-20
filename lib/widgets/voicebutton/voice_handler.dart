import 'package:flutter/material.dart';
import '../../ai/ai_services.dart';
import 'promodoro_flow.dart';
import 'sequential_flow.dart';

class VoiceHandler {
  static Future<void> process(String transcript, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Đang xử lý giọng nói...')),
    );

    try {
      final ai = AIService.instance;
      final Map<String, dynamic>? intent = await ai.extractIntentFromText(transcript);

      final extractedIntent = intent ?? <String, dynamic>{};
      final String? type = (extractedIntent['type'] as String?)?.trim();

      // --- Điều hướng ---
      if (type == 'command' && (extractedIntent['action'] as String?) == 'navigate') {
        final String? target = extractedIntent['target'] as String?;
        final Map<String, dynamic> params = (extractedIntent['params'] as Map<String, dynamic>?) ?? {};

        switch (target) {
          case 'charts':
          case 'stats':
            Navigator.of(context).pushNamed('/stats', arguments: params);
            scaffold.showSnackBar(const SnackBar(content: Text('Đang mở trang thống kê')));
            return;
          case 'calendar':
            Navigator.of(context).pushNamed('/calendar', arguments: params);
            scaffold.showSnackBar(const SnackBar(content: Text('Đang mở lịch')));
            return;
          case 'dashboard':
            Navigator.of(context).pushNamed('/dashboard', arguments: params);
            scaffold.showSnackBar(const SnackBar(content: Text('Quay về trang chính')));
            return;
          case 'profile':
            Navigator.of(context).pushNamed('/profile', arguments: params);
            scaffold.showSnackBar(const SnackBar(content: Text('Đang mở trang hồ sơ')));
            return;
          default:
            scaffold.showSnackBar(const SnackBar(content: Text('Lệnh điều hướng không hợp lệ')));
            return;
        }
      }

      // Nếu không phải lệnh, hỏi user muốn tạo loại nhiệm vụ nào (Promodoro / Dài hạn)
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Tạo nhiệm vụ'),
          content: const Text('Bạn muốn tạo nhiệm vụ dạng nào?\n\n- Promodoro: tạo nhanh nhiệm vụ tập trung (ưu tiên mặc định là Cao).\n- Dài hạn: quy trình thu thập đầy đủ thông tin.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop('long'), child: const Text('Dài hạn')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop('promodoro'), child: const Text('Promodoro')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Hủy')),
          ],
        ),
      );

      if (choice == 'promodoro') {
        await collectPromodoroFlow(context, initialTranscript: transcript);
      } else if (choice == 'long') {
        await collectVoiceTaskSequential(context, initialTranscript: transcript);
      }
      // else: user canceled, do nothing

    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi xử lý giọng nói: $e')));
    }
  }
}
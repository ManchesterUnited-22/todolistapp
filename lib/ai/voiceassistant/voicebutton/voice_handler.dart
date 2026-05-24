import 'package:flutter/material.dart';
import 'package:smart_app/ai/voice_ai_service.dart';

import 'diagram/diagram_flow.dart';
import 'promodoro/promodoro_flow.dart';
import 'realaddtask/real_add_task.dart';

class VoiceHandler {
  static Future<void> process(String transcript, BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Đang xử lý giọng nói...')),
    );

    try {
      final ai = VoiceAiService.instance;
      final normalizedTranscript = transcript.trim();

      if (normalizedTranscript.isEmpty) {
        await ai.speakText(
          'Chào mừng bạn, muốn bắt đầu với biểu đồ, promodoro hay nhiệm vụ dài hạn?',
        );

        final choice = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const _VoiceStartDialog(),
        );

        if (choice == 'diagram') {
          await collectDiagramWithVoiceForm(context);
        } else if (choice == 'promodoro') {
          await collectPromodoroFlow(context);
        } else if (choice == 'long') {
          await collectLongTaskWithVoiceForm(context);
        }
        return;
      }

      final Map<String, dynamic>? intent = await ai.extractIntentFromText(normalizedTranscript);

      final extractedIntent = intent ?? <String, dynamic>{};
      final String? type = (extractedIntent['type'] as String?)?.trim();

      if (type == 'command' && (extractedIntent['action'] as String?) == 'navigate') {
        final String? target = extractedIntent['target'] as String?;
        final Map<String, dynamic> params =
            (extractedIntent['params'] as Map<String, dynamic>?) ?? {};

        switch (target) {
          case 'charts':
          case 'stats':
            final shouldOpenVoiceDiagram =
                (params['diagram'] == true) ||
                (params['view'] as String?) == 'voice_diagram' ||
                params.containsKey('rangeType') ||
                params.containsKey('timeRange') ||
                params.containsKey('anchorDate') ||
                params.containsKey('anchor');

            if (shouldOpenVoiceDiagram) {
              await collectDiagramWithVoiceForm(context, initialTranscript: normalizedTranscript, initialParams: params);
              scaffold.showSnackBar(
                const SnackBar(content: Text('Đang mở biểu đồ theo mốc thời gian đã chọn')),
              );
              return;
            }

            Navigator.of(context).pushNamed('/stats', arguments: params);
            scaffold.showSnackBar(
              const SnackBar(content: Text('Đang mở trang thống kê')),
            );
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
            scaffold.showSnackBar(
              const SnackBar(content: Text('Lệnh điều hướng không hợp lệ')),
            );
            return;
        }
      }

      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Trợ lý giọng nói'),
          content: const Text(
            'Bạn muốn làm gì?\n\n- Biểu đồ: AI chào, hỏi mốc thời gian và hiển thị cả phân tích cùng thời gian đó.\n- Promodoro: tạo nhanh nhiệm vụ tập trung (ưu tiên mặc định là Cao).\n- Dài hạn: quy trình thu thập đầy đủ thông tin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('diagram'),
              child: const Text('Biểu đồ'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('long'),
              child: const Text('Dài hạn'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('promodoro'),
              child: const Text('Promodoro'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Hủy'),
            ),
          ],
        ),
      );

      if (choice == 'diagram') {
        await collectDiagramWithVoiceForm(context, initialTranscript: normalizedTranscript);
      } else if (choice == 'promodoro') {
        await collectPromodoroFlow(context, initialTranscript: normalizedTranscript);
      } else if (choice == 'long') {
        await collectLongTaskWithVoiceForm(context, initialTranscript: normalizedTranscript);
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi xử lý giọng nói: $e')));
    }
  }
}

class _VoiceStartDialog extends StatelessWidget {
  const _VoiceStartDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3FF),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4648D4).withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4648D4),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4648D4).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Trợ lý giọng nói',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Đang lắng nghe...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF4648D4), height: 1.35, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            _VoiceStartOption(
              icon: Icons.bar_chart_rounded,
              title: 'Phân tích biểu đồ',
              subtitle: 'Hỏi mốc thời gian để xem báo cáo ngay.',
              onTap: () => Navigator.of(context).pop('diagram'),
            ),
            const SizedBox(height: 10),
            _VoiceStartOption(
              icon: Icons.timer_outlined,
              title: 'Tập trung Promodoro',
              subtitle: 'Tạo nhanh phiên làm việc và nghỉ ngắn.',
              onTap: () => Navigator.of(context).pop('promodoro'),
            ),
            const SizedBox(height: 10),
            _VoiceStartOption(
              icon: Icons.task_alt_rounded,
              title: 'Nhiệm vụ dài hạn',
              subtitle: 'Thu thập đủ tiêu đề, ưu tiên và thời hạn.',
              onTap: () => Navigator.of(context).pop('long'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceStartOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VoiceStartOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF4648D4).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4648D4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191C1E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: Color(0xFF6F6B82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C98B5)),
            ],
          ),
        ),
      ),
    );
  }
}

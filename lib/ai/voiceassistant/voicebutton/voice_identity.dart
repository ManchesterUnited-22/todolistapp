import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/voice_nudge_service.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/services/stt_service.dart';

Future<VoiceTaskDraft?> collectVoiceTaskDraft(
  BuildContext context, {
  String transcript = '',
  Map<String, dynamic>? intent,
}) async {
  final state = VoiceTaskConversationState.initial();
  var currentState = state;
  final initialHint = (intent?['task_name'] as String?)?.trim();

  while (true) {
    final prompt = VoiceAiService.instance.voicePromptForStep(currentState);
    await VoiceAiService.instance.speakText(prompt);

    final answer = await _askVoiceAnswer(
      context,
      prompt: prompt,
      hintText:
          initialHint != null && currentState.step == VoiceTaskStep.askTitle
          ? initialHint
          : null,
      keyboardType:
          currentState.step == VoiceTaskStep.askDuration ||
              currentState.step == VoiceTaskStep.askPriority
          ? TextInputType.number
          : TextInputType.text,
    );

    if (answer == null) return null;

    final reply = VoiceAiService.instance.advanceVoiceTaskConversation(
      answer,
      currentState,
    );
    currentState = reply.state;

    if (reply.isComplete && reply.draft != null) {
      return reply.draft;
    }
  }
}

Future<String?> _askVoiceAnswer(
  BuildContext context, {
  required String prompt,
  String? hintText,
  TextInputType keyboardType = TextInputType.text,
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _VoiceAnswerDialog(prompt: prompt, hintText: hintText),
  );
}

class _VoiceAnswerDialog extends StatefulWidget {
  final String prompt;
  final String? hintText;

  const _VoiceAnswerDialog({required this.prompt, this.hintText});

  @override
  State<_VoiceAnswerDialog> createState() => _VoiceAnswerDialogState();
}

class _VoiceAnswerDialogState extends State<_VoiceAnswerDialog> {
  String _spokenText = '';
  bool _isListening = false;
  bool _isReady = false;
  bool _isFinal = false;
  bool _starting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    if (_starting || _isListening) return;
    _starting = true;
    _errorText = null;
    if (mounted) setState(() {});

    final ok = await SttService.instance.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          _spokenText = text;
          _isFinal = isFinal;
          if (isFinal) _isListening = false;
        });
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _errorText = message;
        });
      },
    );

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _starting = false;
        _isListening = false;
        _errorText ??= 'Không khởi động được mic. Hãy bấm "Nghe lại".';
      });
      return;
    }

    setState(() {
      _isReady = true;
      _isListening = true;
      _starting = false;
    });
  }

  Future<void> _stopListening() async {
    await SttService.instance.stopListening();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    SttService.instance.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.prompt),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.hintText != null) ...[
            Text(
              widget.hintText!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF464554)),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _spokenText.isEmpty
                  ? (_isListening ? 'Đang nghe...' : 'Chờ ghi âm')
                  : _spokenText,
              style: const TextStyle(fontSize: 14, color: Color(0xFF191C1E)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isReady
                ? 'Mic đã sẵn sàng, bạn có thể nói'
                : 'Đang khởi tạo mic...',
            style: const TextStyle(fontSize: 11, color: Color(0xFF767586)),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await _stopListening();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            if (_isListening) {
              await _stopListening();
            } else {
              await _startListening();
            }
          },
          icon: Icon(
            _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
          ),
          label: Text(_isListening ? 'Dừng ghi âm' : 'Nghe lại'),
        ),
        FilledButton.icon(
          onPressed: _spokenText.trim().isEmpty && !_isFinal
              ? null
              : () async {
                  await _stopListening();
                  if (context.mounted)
                    Navigator.of(context).pop(_spokenText.trim());
                },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Xác nhận'),
        ),
      ],
    );
  }
}

/// Hiển thị dialog nudge khi người dùng tạo task bằng giọng nói.
/// Trả về `DateTime?` mới nếu người dùng chọn dời giờ, hoặc `null` để giữ nguyên.
Future<DateTime?> showVoiceScheduleNudge(
  BuildContext context,
  String title,
  DateTime proposedDue,
) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null; // nếu chưa đăng nhập, cho phép tiếp tục

  final svc = VoiceNudgeService();
  final result = await svc.analyzeProposed(proposedDue);
  if (!result.shouldWarn) return null;

  final suggested = result.suggestedTime;

  return showDialog<DateTime?>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (ctx) {
      return AlertDialog(
        title: Text('Gợi ý thông minh: $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 12),
            if (suggested != null)
              Text(
                'Gợi ý: ${suggested.hour}h ${suggested.minute.toString().padLeft(2, '0')}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Giữ nguyên'),
          ),
          if (suggested != null)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(suggested),
              child: const Text('Dời sang gợi ý'),
            ),
          TextButton(
            onPressed: () async {
              final t = await showTimePicker(
                context: ctx,
                initialTime: TimeOfDay(
                  hour: proposedDue.hour,
                  minute: proposedDue.minute,
                ),
              );
              if (t != null) {
                final newDt = DateTime(
                  proposedDue.year,
                  proposedDue.month,
                  proposedDue.day,
                  t.hour,
                  t.minute,
                );
                Navigator.of(ctx).pop(newDt);
              }
            },
            child: const Text('Chọn giờ khác'),
          ),
        ],
      );
    },
  );
}
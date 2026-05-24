library promodoro_timer_sheet;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_app/services/timer_service.dart';
import 'package:smart_app/views/task_viewmodel.dart';

part 'promodoro_timer_sheet/promodoro_timer_sheet_view.dart';

Future<void> showPromodoroTimerSheet(
  BuildContext context, {
  required String taskDocId,
  required TaskViewModel task,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PromodoroTimerSheet(
      taskDocId: taskDocId,
      task: task,
    ),
  );
}

class _PromodoroTimerSheet extends StatefulWidget {
  final String taskDocId;
  final TaskViewModel task;

  const _PromodoroTimerSheet({
    required this.taskDocId,
    required this.task,
  });

  @override
  State<_PromodoroTimerSheet> createState() => _PromodoroTimerSheetState();
}

class _PromodoroTimerSheetState extends State<_PromodoroTimerSheet> {
  TimerService get _svc => TimerService.instance;

  late int _focusMinutes;

  late int _breakMinutes;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.task.focusDuration ?? 25;
    _breakMinutes = widget.task.breakDuration ?? 5;
    _initialized = true;
  }

  String _formatClockFromSeconds(int seconds) {
    if (seconds < 0) seconds = 0;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startTimer() async {
    await _svc.startExistingTaskSession(
      taskDocId: widget.taskDocId,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      uid: widget.task.uid,
    );
    if (mounted) setState(() {});
  }

  Future<void> _updateDuration({
    required bool editFocus,
  }) async {
    final controller = TextEditingController(
      text: editFocus ? _focusMinutes.toString() : _breakMinutes.toString(),
    );
    final label = editFocus ? 'Thời gian làm task' : 'Thời gian giải lao';

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập số phút',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value <= 0) return;
              Navigator.of(ctx).pop(value);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == null) return;

    final isRunning =
        _svc.phase != TimerPhase.idle && _svc.phase != TimerPhase.stopped;
    if (isRunning) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đang có timer chạy'),
          content: const Text(
            'Nếu đổi thời gian lúc này, timer sẽ cập nhật cho các chu kỳ tiếp theo. Bạn có muốn tiếp tục?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Không'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Có'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() {
      if (editFocus) {
        _focusMinutes = result;
      } else {
        _breakMinutes = result;
      }
    });

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskDocId)
          .set(
        {
          if (editFocus) 'focus_duration': result else 'break_duration': result,
        },
        SetOptions(merge: true),
      );

      if (isRunning) {
        _svc.focusDurationMinutes = _focusMinutes;
        _svc.breakDurationMinutes = _breakMinutes;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật $label thành $result phút')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu thay đổi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => buildPromodoroTimerSheet(this, context);
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onEdit;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../ai/voice_ai_service.dart';
import '../../services/timer_service.dart';

Future<void> handlePromodoroAiPress(
  BuildContext context,
  TextEditingController focusController,
  TextEditingController breakController,
) async {
  final focusMinutes = _parseMinutes(focusController);
  final breakMinutes = _parseMinutes(breakController);

  if (focusMinutes == null || breakMinutes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nhập số phút hợp lệ cho cả tập trung và giải lao.'),
      ),
    );
    return;
  }

  final rec = await VoiceAiService.instance.recommendFocusBreak(
    focusMinutes: focusMinutes,
    breakMinutes: breakMinutes,
  );

  final agree = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 36,
          color: Color(0xFF4648D4),
        ),
      ),
      content: Text(rec.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Hủy bỏ'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );

  final appliedFocus = agree == true ? rec.suggestedFocusMinutes : focusMinutes;
  final appliedBreak = agree == true ? rec.suggestedBreakMinutes : breakMinutes;

  if (agree == true) {
    focusController.text = appliedFocus.toString();
    breakController.text = appliedBreak.toString();
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng đăng nhập trước khi bắt đầu phiên.'),
      ),
    );
    return;
  }

  await TimerService.instance.startSession(
    focusMinutes: appliedFocus,
    breakMinutes: appliedBreak,
    uid: user.uid,
  );
}

Future<void> showPromodoroQuickDialog(
  BuildContext context, {
  String? taskTitle,
  int? initialFocusMinutes,
  int? initialBreakMinutes,
}) async {
  final focusController = TextEditingController(
    text: (initialFocusMinutes ?? 25).toString(),
  );
  final breakController = TextEditingController(
    text: (initialBreakMinutes ?? 5).toString(),
  );

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Icon(
                      Icons.timer_outlined,
                      size: 42,
                      color: Color(0xFF4648D4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Promodoro',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  if (taskTitle != null && taskTitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      taskTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF464554),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _NumberField(
                    label: 'Tập trung (phút)',
                    controller: focusController,
                  ),
                  const SizedBox(height: 12),
                  _NumberField(
                    label: 'Giải lao (phút)',
                    controller: breakController,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'AI sẽ xem xét thời gian bạn nhập và gợi ý cấu hình phù hợp.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF464554),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => handlePromodoroAiPress(
                      ctx,
                      focusController,
                      breakController,
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Tư vấn AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4648D4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

int? _parseMinutes(TextEditingController controller) {
  final value = int.tryParse(controller.text.trim());
  if (value == null || value <= 0) return null;
  return value;
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NumberField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

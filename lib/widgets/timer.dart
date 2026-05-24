library timer_widget;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_app/ai/voice_ai_service.dart';

import '../services/timer_service.dart';

part 'timer/timer_view.dart';
part 'timer/timer_controls.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({super.key});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  final TimerService _svc = TimerService.instance;
  final TextEditingController _focusController = TextEditingController(text: '25');
  final TextEditingController _breakController = TextEditingController(text: '5');

  int _focusMinutes = 25;
  int _breakMinutes = 5;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_handleTimerChanged);
    _svc.initialize();
    _syncFromService();
  }

  @override
  void dispose() {
    _svc.removeListener(_handleTimerChanged);
    _focusController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  void _handleTimerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncFromService() {
    if (_svc.focusDurationMinutes > 0) {
      _focusMinutes = _svc.focusDurationMinutes;
    }
    if (_svc.breakDurationMinutes > 0) {
      _breakMinutes = _svc.breakDurationMinutes;
    }
    _focusController.text = _focusMinutes.toString();
    _breakController.text = _breakMinutes.toString();
  }

  String _formatClockFromSeconds(int totalSeconds) {
    final clamped = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (clamped ~/ 60).toString().padLeft(2, '0');
    final seconds = (clamped % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _updateDuration({required bool editFocus}) async {
    final currentValue = editFocus ? _focusMinutes : _breakMinutes;
    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(editFocus ? 'Đổi thời gian tập trung' : 'Đổi thời gian giải lao'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số phút'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                Navigator.of(dialogContext).pop();
                return;
              }
              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      if (editFocus) {
        _focusMinutes = result;
        _focusController.text = result.toString();
        _svc.focusDurationMinutes = result;
      } else {
        _breakMinutes = result;
        _breakController.text = result.toString();
        _svc.breakDurationMinutes = result;
      }
    });
  }

  Future<void> _onPressAi() async {
    final focusMinutes = _parseMinutes(_focusController.text);
    final breakMinutes = _parseMinutes(_breakController.text);

    if (focusMinutes == null || breakMinutes == null) {
      if (!mounted) return;
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

    if (!mounted) return;
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

    setState(() {
      _focusMinutes = appliedFocus;
      _breakMinutes = appliedBreak;
      _focusController.text = appliedFocus.toString();
      _breakController.text = appliedBreak.toString();
      _svc.focusDurationMinutes = appliedFocus;
      _svc.breakDurationMinutes = appliedBreak;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước khi bắt đầu phiên.'),
        ),
      );
      return;
    }

    await _svc.startSession(
      focusMinutes: appliedFocus,
      breakMinutes: appliedBreak,
      uid: user.uid,
    );
  }

  int? _parseMinutes(String input) {
    final value = int.tryParse(input.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) => buildTimerCardView(this, context);
}

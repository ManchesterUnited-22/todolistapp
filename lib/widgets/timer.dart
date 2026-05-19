import 'dart:async';

import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import 'voicebutton/promodoro_process.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({super.key});

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> with WidgetsBindingObserver {
  final TextEditingController _focusController = TextEditingController();
  final TextEditingController _breakController = TextEditingController();

  TimerService get _svc => TimerService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _svc.addListener(_onTimerChange);
    _svc.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _svc.removeListener(_onTimerChange);
    _focusController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  void _onTimerChange() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // user left app -> pause session and persist
      _svc.pauseSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phiên tạm dừng khi thoát ứng dụng.')),
        );
      }
    }
  }

  Future<void> _onPressAi() async {
    await handlePromodoroAiPress(context, _focusController, _breakController);
  }

  String _formatClockFromSeconds(int seconds) {
    if (seconds < 0) seconds = 0;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final phase = _svc.phase;
    final remaining = _svc.remainingSeconds;

    Widget centerChild;
    if (phase == TimerPhase.idle) {
      centerChild = const Text(
        'Nhập\nthời gian',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4648D4),
          letterSpacing: -0.6,
          height: 1.1,
        ),
      );
    } else if (phase == TimerPhase.preStart) {
      centerChild = Text(
        'Bắt đầu sau\n${_formatClockFromSeconds(remaining)}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF4648D4)),
      );
    } else if (phase == TimerPhase.focusing) {
      centerChild = Text(
        _formatClockFromSeconds(remaining),
        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF4648D4)),
      );
    } else if (phase == TimerPhase.overtime) {
      final over = _svc.overrunSeconds;
      centerChild = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Quá giờ', style: TextStyle(fontSize: 14, color: Colors.red)),
          const SizedBox(height: 4),
          Text(
            _formatClockFromSeconds(over),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.red),
          ),
        ],
      );
    } else if (phase == TimerPhase.breaking) {
      centerChild = Text(
        _formatClockFromSeconds(remaining),
        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF0060AC)),
      );
    } else if (phase == TimerPhase.paused) {
      centerChild = const Text('Tạm dừng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700));
    } else {
      centerChild = const Text('...');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Cân bằng thời gian',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191C1E),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 236,
                height: 236,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4648D4).withValues(alpha: 0.04),
                ),
              ),
              Container(
                width: 202,
                height: 202,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE1E0FF).withValues(alpha: 0.70),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 172,
                height: 172,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    centerChild,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Color(0xFF4648D4)),
                        SizedBox(width: 8),
                        Text(
                          'Tập trung',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF464554),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _focusController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Số phút cần hoàn thành task này',
                          hintMaxLines: 2,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: const Color(0xFFE1E0FF).withValues(alpha: 0.20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF4648D4), width: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFC7C4D7)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: Color(0xFF0060AC)),
                        SizedBox(width: 8),
                        Text(
                          'Giải lao',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF464554),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _breakController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Khoảng time nhỏ giải lao trong phút đó',
                          hintMaxLines: 2,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: const Color(0xFF0060AC).withValues(alpha: 0.16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF0060AC), width: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'AI sẽ xem xét thời gian nghỉ bạn nhập vào có hợp lý với thời gian tập trung hay không.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF464554),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onPressAi,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Tư vấn AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4648D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                shadowColor: const Color(0xFF4648D4).withValues(alpha: 0.20),
                elevation: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Control buttons: Pause/Resume/Stop/Skip-to-break
          if (_svc.phase != TimerPhase.idle && _svc.phase != TimerPhase.stopped)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_svc.phase == TimerPhase.paused) {
                        _svc.resumeSession();
                      } else {
                        _svc.pauseSession();
                      }
                    },
                    child: Text(_svc.phase == TimerPhase.paused ? 'Resume' : 'Pause'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _svc.stopSession(markCompleted: true);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã dừng phiên.')));
                    },
                    child: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_svc.phase == TimerPhase.focusing || _svc.phase == TimerPhase.overtime)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _svc.stopOverrunAndStartBreak();
                      },
                      child: const Text('Sang giải lao'),
                    ),
                  ),
              ],
            ),
           ],
         ),
       );
     }
   }

part of timer_widget;

Widget buildTimerCardView(_TimerCardState state, BuildContext context) {
  final phase = state._svc.phase;
  final remaining = state._svc.remainingSeconds;

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
      'Bắt đầu sau\n${state._formatClockFromSeconds(remaining)}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4648D4),
      ),
    );
  } else if (phase == TimerPhase.focusing) {
    centerChild = Text(
      state._formatClockFromSeconds(remaining),
      style: const TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4648D4),
      ),
    );
  } else if (phase == TimerPhase.overtime) {
    final over = state._svc.overrunSeconds;
    centerChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Quá giờ', style: TextStyle(fontSize: 14, color: Colors.red)),
        const SizedBox(height: 4),
        Text(
          state._formatClockFromSeconds(over),
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
      ],
    );
  } else {
    centerChild = Text(
      state._formatClockFromSeconds(remaining),
      style: const TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4648D4),
      ),
    );
  }

  return Column(
    children: [
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.timer_rounded, color: Color(0xFF4648D4)),
                  SizedBox(width: 8),
                  Text(
                    'Promodoro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE1E0FF).withValues(alpha: 0.22),
                  border: Border.all(
                    color: const Color(0xFF4648D4).withValues(alpha: 0.12),
                  ),
                ),
                child: Center(child: centerChild),
              ),
              const SizedBox(height: 18),
              buildTimerDurationRow(state),
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
                  onPressed: state._onPressAi,
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
              if (state._svc.phase != TimerPhase.idle &&
                  state._svc.phase != TimerPhase.stopped)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (state._svc.phase == TimerPhase.paused) {
                            state._svc.resumeSession();
                          } else {
                            state._svc.pauseSession();
                          }
                        },
                        child: Text(
                          state._svc.phase == TimerPhase.paused ? 'Resume' : 'Pause',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          state._svc.stopSession(markCompleted: true);
                          if (state.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã dừng phiên.')),
                            );
                          }
                        },
                        child: const Text('Stop'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state._svc.phase == TimerPhase.focusing ||
                        state._svc.phase == TimerPhase.overtime)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            state._svc.stopOverrunAndStartBreak();
                          },
                          child: const Text('Sang giải lao'),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

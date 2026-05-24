part of promodoro_timer_sheet;

Widget buildPromodoroTimerSheet(
  _PromodoroTimerSheetState state,
  BuildContext context,
) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.78,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: state._svc,
        builder: (context, _) {
          final phase = state._svc.phase;
          final remaining = state._svc.remainingSeconds;
          final isRunning = phase != TimerPhase.idle && phase != TimerPhase.stopped;

          String phaseLabel;
          Color phaseColor;
          switch (phase) {
            case TimerPhase.preStart:
              phaseLabel = 'Chuẩn bị bắt đầu';
              phaseColor = const Color(0xFF4648D4);
              break;
            case TimerPhase.focusing:
              phaseLabel = 'Đang làm task';
              phaseColor = const Color(0xFF4648D4);
              break;
            case TimerPhase.breaking:
              phaseLabel = 'Đang nghỉ';
              phaseColor = const Color(0xFF0060AC);
              break;
            case TimerPhase.overtime:
              phaseLabel = 'Quá giờ';
              phaseColor = Colors.red;
              break;
            case TimerPhase.paused:
              phaseLabel = 'Tạm dừng';
              phaseColor = Colors.grey;
              break;
            case TimerPhase.stopped:
              phaseLabel = 'Đã dừng';
              phaseColor = Colors.grey;
              break;
            case TimerPhase.idle:
              phaseLabel = 'Sẵn sàng';
              phaseColor = const Color(0xFF4648D4);
              break;
          }

          final displaySeconds =
              phase == TimerPhase.idle || phase == TimerPhase.stopped
                  ? state._focusMinutes * 60
                  : remaining;

          final totalSeconds = switch (phase) {
            TimerPhase.breaking => state._breakMinutes * 60,
            TimerPhase.preStart => 5,
            _ => state._focusMinutes * 60,
          };
          final progress = totalSeconds <= 0
              ? 0.0
              : ((totalSeconds - displaySeconds) / totalSeconds)
                  .clamp(0.0, 1.0)
                  .toDouble();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_rounded, color: Color(0xFF4648D4), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.widget.task.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: SizedBox(
                        width: 228,
                        height: 228,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 228,
                              height: 228,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: phaseColor.withValues(alpha: 0.12),
                                color: phaseColor,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Container(
                              width: 176,
                              height: 176,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phaseColor.withValues(alpha: 0.06),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    phaseLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: phaseColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    state._formatClockFromSeconds(displaySeconds),
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: phaseColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            label: 'Làm task',
                            value: '${state._focusMinutes} phút',
                            color: const Color(0xFF4648D4),
                            onEdit: () => state._updateDuration(editFocus: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoBox(
                            label: 'Giải lao',
                            value: '${state._breakMinutes} phút',
                            color: const Color(0xFF0060AC),
                            onEdit: () => state._updateDuration(editFocus: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (!isRunning)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state._startTimer,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Bắt đầu chạy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4648D4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      )
                    else
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
                                state._svc.phase == TimerPhase.paused
                                    ? 'Tiếp tục'
                                    : 'Tạm dừng',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                state._svc.stopSession(markCompleted: false);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Dừng'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Timer sẽ tự chuyển sang giải lao khi hết thời gian làm task, rồi quay lại chu kỳ làm task tiếp theo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
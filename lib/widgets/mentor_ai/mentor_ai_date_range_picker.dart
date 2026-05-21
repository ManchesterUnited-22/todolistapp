part of mentor_ai;

Future<DateTimeRange?> _showStyledDateRangePicker(BuildContext context) async {
  final now = DateTime.now();
  DateTime? rangeStart;
  DateTime? rangeEnd;
  DateTime displayMonth = DateTime(now.year, now.month);

  return showDialog<DateTimeRange>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final daysInMonth = DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
          final firstWeekday = DateTime(displayMonth.year, displayMonth.month, 1).weekday;
          final leadingBlanks = firstWeekday - 1;

          final monthName = _monthName(displayMonth.month);
          final year = displayMonth.year;

          String summaryText = '';
          if (rangeStart != null && rangeEnd != null) {
            summaryText = 'Báo cáo sẽ tổng hợp từ ngày ${rangeStart!.day} đến ngày ${rangeEnd!.day} tháng ${rangeStart!.month}.';
          } else if (rangeStart != null) {
            summaryText = 'Đã chọn ngày bắt đầu: ${rangeStart!.day}/${rangeStart!.month}.';
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0x1AC7C4D7))),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6063EE),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4648D4).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chọn thời gian báo cáo',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF191C1E), letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$monthName, $year', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF191C1E))),
                                  Row(
                                    children: [
                                      _NavButton(
                                        icon: Icons.chevron_left_rounded,
                                        onTap: () => setState(() {
                                          displayMonth = DateTime(displayMonth.year, displayMonth.month - 1);
                                        }),
                                      ),
                                      const SizedBox(width: 8),
                                      _NavButton(
                                        icon: Icons.chevron_right_rounded,
                                        onTap: () => setState(() {
                                          displayMonth = DateTime(displayMonth.year, displayMonth.month + 1);
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Row(
                                children: [
                                  _DayLabel('T2'),
                                  _DayLabel('T3'),
                                  _DayLabel('T4'),
                                  _DayLabel('T5'),
                                  _DayLabel('T6'),
                                  _DayLabel('T7'),
                                  _DayLabel('CN'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: MediaQuery.of(ctx).size.height * 0.38,
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: leadingBlanks + daysInMonth,
                                  itemBuilder: (_, index) {
                                    if (index < leadingBlanks) return const SizedBox.shrink();
                                    final day = index - leadingBlanks + 1;
                                    final date = DateTime(displayMonth.year, displayMonth.month, day);
                                    final isStart = rangeStart != null && DateUtils.isSameDay(date, rangeStart);
                                    final isEnd = rangeEnd != null && DateUtils.isSameDay(date, rangeEnd);
                                    final inRange = rangeStart != null && rangeEnd != null && date.isAfter(rangeStart!) && date.isBefore(rangeEnd!);
                                    final isSelected = isStart || isEnd;

                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        if (rangeStart == null || (rangeStart != null && rangeEnd != null)) {
                                          rangeStart = date;
                                          rangeEnd = null;
                                        } else {
                                          if (date.isBefore(rangeStart!)) {
                                            rangeEnd = rangeStart;
                                            rangeStart = date;
                                          } else {
                                            rangeEnd = date;
                                          }
                                        }
                                      }),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF4648D4)
                                              : inRange
                                                  ? const Color(0xFF4648D4).withValues(alpha: 0.15)
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(32),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                            color: isSelected ? Colors.white : const Color(0xFF191C1E),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (summaryText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFF4648D4), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  summaryText,
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF464554)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xFF767586)),
                              foregroundColor: const Color(0xFF464554),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(null),
                            child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: const Color(0xFF4648D4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                              shadowColor: const Color(0xFF4648D4).withValues(alpha: 0.4),
                            ),
                            onPressed: rangeStart != null && rangeEnd != null
                                ? () => Navigator.of(ctx).pop(DateTimeRange(start: rangeStart!, end: rangeEnd!))
                                : null,
                            child: const Text('Tạo báo cáo', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, color: const Color(0xFF464554), size: 22),
  );
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF464554)),
      ),
    ),
  );
}
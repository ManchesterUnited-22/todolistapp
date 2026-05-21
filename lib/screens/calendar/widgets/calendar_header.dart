import 'package:flutter/material.dart';
import '../calendar_colors.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime displayedMonth;
  final VoidCallback onToday;

  const CalendarHeader({super.key, required this.displayedMonth, required this.onToday});

  String _monthLabel(DateTime dt) {
    const names = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${names[dt.month - 1]}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = displayedMonth.year == now.year && displayedMonth.month == now.month;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch biểu',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: CalendarColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                _monthLabel(displayedMonth),
                style: const TextStyle(fontSize: 16, color: CalendarColors.onSurfaceVariant, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onToday,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CalendarColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.today_outlined, size: 18, color: isCurrentMonth ? CalendarColors.primary : CalendarColors.outline),
                const SizedBox(width: 6),
                Text(
                  'Hôm nay',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isCurrentMonth ? CalendarColors.primary : CalendarColors.outline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

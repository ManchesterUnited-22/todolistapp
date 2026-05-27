import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'calendar_colors.dart';
import 'widgets/calendar_day_cell.dart';
import 'widgets/calendar_nav_button.dart';

class CalendarCard extends StatelessWidget {
  final int selectedDay;
  final DateTime displayedMonth;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const CalendarCard({super.key, required this.selectedDay, required this.displayedMonth, required this.onDaySelected, required this.onPrevMonth, required this.onNextMonth});

  static const _weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const _monthNames = ['Tháng Một', 'Tháng Hai', 'Tháng Ba', 'Tháng Tư', 'Tháng Năm', 'Tháng Sáu', 'Tháng Bảy', 'Tháng Tám', 'Tháng Chín', 'Tháng Mười', 'Tháng Mười Một', 'Tháng Mười Hai'];

  DateTime? _taskDate(Map<String, dynamic>? data) {
    if (data == null) return null;

    final dueAt = (data['dueAt'] as Timestamp?)?.toDate();
    if (dueAt != null) return dueAt;

    final dateString = (data['date_string'] as String? ?? data['dateString'] as String?)?.trim();
    if (dateString != null && dateString.isNotEmpty) {
      try {
        return DateTime.parse(dateString);
      } catch (_) {}
    }

    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    if (timestamp != null) return timestamp;

    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt != null) return createdAt;

    final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
    return completedAt;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: calendarGlassCard,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CalendarNavButton(icon: Icons.chevron_left, onTap: onPrevMonth),
              Text('${_monthNames[displayedMonth.month - 1]} ${displayedMonth.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: CalendarColors.onSurface)),
              CalendarNavButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: _weekdays.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: CalendarColors.outlineVariant))))).toList(),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '').snapshots(),
            builder: (context, snap) {
              final Map<int, List<Color>> dayColors = {};

              if (snap.hasData) {
                for (final doc in snap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>?;
                  final taskDate = _taskDate(data);
                  if (taskDate != null && taskDate.year == displayedMonth.year && taskDate.month == displayedMonth.month) {
                    final day = taskDate.day;
                    final category = (data?['category'] as String?) ?? '';
                    Color col = CalendarColors.primary;
                    if (category.toLowerCase().contains('sức')) {
                      col = CalendarColors.error;
                    } else if (category.toLowerCase().contains('cá nhân')) {
                      col = CalendarColors.tertiary;
                    } else {
                      col = CalendarColors.primaryContainer;
                    }
                    dayColors.putIfAbsent(day, () => []);
                    if (!dayColors[day]!.contains(col)) {
                      dayColors[day]!.add(col);
                    }
                  }
                }
              }

              final year = displayedMonth.year;
              final month = displayedMonth.month;
              final first = DateTime(year, month, 1);
              final startOffset = first.weekday % 7;
              final daysInMonth = DateTime(year, month + 1, 0).day;

              return GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                children: List.generate(42, (i) {
                  final dayNumber = i - startOffset + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () => onDaySelected(dayNumber),
                    child: CalendarDayCell(
                      day: dayNumber,
                      isSelected: dayNumber == selectedDay,
                      dots: dayColors[dayNumber] ?? const [],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

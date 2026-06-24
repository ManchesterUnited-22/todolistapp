// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Timeline",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Mini Calendar Strip
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = DateTime.now().add(Duration(days: index));
                  final isToday = index == 0;
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF6366F1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isToday
                          ? null
                          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ["T2", "T3", "T4", "T5", "T6", "T7", "CN"][day.weekday - 1],
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Today's Tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Hôm nay", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  Text("3 nhiệm vụ", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildTaskCard("Học Flutter - State Management", "09:00", "11:00", true),
                  const SizedBox(height: 12),
                  _buildTaskCard("Làm bài tập AI", "14:00", "15:30", false),
                  const SizedBox(height: 12),
                  _buildTaskCard("Review code Todo App", "16:00", "17:00", false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String title, String start, String end, bool isDone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.circle_outlined,
            color: isDone ? Colors.green : const Color(0xFF6366F1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text("$start - $end", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(start, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
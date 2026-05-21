import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../views/task_viewmodel.dart';
import '../calendar_colors.dart';
import 'calendar_task_card.dart';

class CalendarTaskSection extends StatelessWidget {
  final int selectedDay;
  final DateTime displayedMonth;

  const CalendarTaskSection({super.key, required this.selectedDay, required this.displayedMonth});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final start = DateTime(displayedMonth.year, displayedMonth.month, selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NHIỆM VỤ - NGÀY $selectedDay',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: CalendarColors.onSurfaceVariant),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: user == null ? null : FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: user.uid).snapshots(),
              builder: (context, snap) {
                final count = snap.hasData
                    ? snap.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>?;
                        final due = (data?['dueAt'] as Timestamp?)?.toDate();
                        return due != null && due.year == start.year && due.month == start.month && due.day == start.day;
                      }).length
                    : 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CalendarColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count CÔNG VIỆC',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: CalendarColors.onSecondaryFixed),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (user == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Vui lòng đăng nhập để xem nhiệm vụ', style: TextStyle(color: CalendarColors.outline, fontSize: 15)),
            ),
          )
        else
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: user.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>?;
                final due = (data?['dueAt'] as Timestamp?)?.toDate();
                return due != null && due.year == start.year && due.month == start.month && due.day == start.day;
              }).toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('Chưa có nhiệm vụ nào', style: TextStyle(color: CalendarColors.outline, fontSize: 15)),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final task = TaskViewModel.fromMap(doc.data() as Map<String, dynamic>);
                  final isCompleted = task.stat == 'Hoàn thành';
                  final dueAt = task.dueAt?.toDate();
                  final isOverdue = !isCompleted && (dueAt != null ? dueAt.isBefore(DateTime.now()) : task.stat == 'Quá hạn');

                  return CalendarTaskCard(
                    task: task,
                    isCompleted: isCompleted,
                    isOverdue: isOverdue,
                    onToggle: (val) async {
                      final stat = (val ?? false) ? 'Hoàn thành' : (isOverdue ? 'Quá hạn' : 'Đang làm');
                      final updates = <String, dynamic>{'stat': stat};
                      if (val == true) {
                        updates['completedAt'] = FieldValue.serverTimestamp();
                      } else {
                        updates['completedAt'] = FieldValue.delete();
                      }
                      await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update(updates);
                    },
                    onDelete: () async {
                      await FirebaseFirestore.instance.collection('tasks').doc(doc.id).delete();
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

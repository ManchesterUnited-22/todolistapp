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

    return (data['completedAt'] as Timestamp?)?.toDate();
  }

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
                          final taskDate = _taskDate(data);
                          return taskDate != null && taskDate.year == start.year && taskDate.month == start.month && taskDate.day == start.day;
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
                final taskDate = _taskDate(data);
                return taskDate != null && taskDate.year == start.year && taskDate.month == start.month && taskDate.day == start.day;
              }).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E8F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.task_alt_rounded,
                            size: 34,
                            color: Color(0xFFA7A7EA),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Mọi thứ đã gọn gàng',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A4B5C),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chưa có nhiệm vụ đang làm. Nhấn\nnút micro để thêm nhiệm vụ mới\nbằng giọng nói.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF707388),
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                  final dueAt = task.dueAt?.toDate() ?? _taskDate(doc.data() as Map<String, dynamic>);
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
                        updates['timestamp'] = FieldValue.serverTimestamp();
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

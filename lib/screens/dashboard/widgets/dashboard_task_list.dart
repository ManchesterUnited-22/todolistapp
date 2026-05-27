import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../views/task_viewmodel.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/promodoro/promodoro_timer_sheet.dart';
import '../dashboard_colors.dart';
import 'dashboard_task_card.dart';

class DashboardTaskList extends StatelessWidget {
  final String userUid;
  final String? selectedCategory;
  final Future<void> Function(String docId, TaskViewModel task, bool checked) onToggleTask;
  final ValueChanged<String> onDeleteTask;

  const DashboardTaskList({
    super.key,
    required this.userUid,
    required this.selectedCategory,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  bool _isTaskCompleted(TaskViewModel task) => task.stat == 'Hoàn thành';

  bool _isTaskOverdue(TaskViewModel task) {
    if (_isTaskCompleted(task)) return false;
    final dueAt = task.dueAt?.toDate();
    if (dueAt == null) return task.stat == 'Quá hạn';
    return dueAt.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('tasks').where('uid', isEqualTo: userUid);
    if (selectedCategory != null) {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Lỗi tải dữ liệu'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Chưa có nhiệm vụ nào phù hợp',
                style: TextStyle(color: DashboardColors.outline, fontSize: 15),
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
            final isCompleted = _isTaskCompleted(task);
            final isOverdue = _isTaskOverdue(task);

            return DashboardTaskCard(
              docId: doc.id,
              task: task,
              isCompleted: isCompleted,
              isOverdue: isOverdue,
              onToggle: (val) => onToggleTask(doc.id, task, val ?? false),
              onDelete: () => onDeleteTask(doc.id),
              onTimerTap: task.way == 'promodoro'
                  ? () => showPromodoroTimerSheet(
                        context,
                        taskDocId: doc.id,
                        task: task,
                      )
                  : null,
            );
          },
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../views/task_viewmodel.dart';
import 'add_task_sheet.dart';

class AddTaskFab extends StatelessWidget {
  final ValueChanged<String>? onTaskAdded;

  const AddTaskFab({super.key, this.onTaskAdded});

  Future<void> _openAddTaskSheet(BuildContext context) async {
    final draft = await showAddTaskSheet(context);
    if (draft == null || !context.mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    final taskViewModel = TaskViewModel(
      id: now.microsecondsSinceEpoch,
      title: draft.title,
      detail: draft.detail,
      category: draft.category,
      priority: draft.priority,
      way: 'long_term_task',
      stat: 'Đang làm',
      createdAt: Timestamp.fromDate(now),
      dueAt: draft.dueAt != null ? Timestamp.fromDate(draft.dueAt!) : null,
      dateString:
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      timestamp: Timestamp.fromDate(now),
      uid: currentUser?.uid ?? '',
    );

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .add(taskViewModel.toFirestoreMap());

      onTaskAdded?.call(taskViewModel.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm task: ${taskViewModel.title}')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu task: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'main_dashboard_add_task',
      onPressed: () => _openAddTaskSheet(context),
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}
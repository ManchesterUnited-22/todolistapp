import 'package:flutter/material.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/realaddtask/real_add_task.dart';

import '../../core/app_colors.dart';

class AddTaskFab extends StatelessWidget {
  final ValueChanged<String>? onTaskAdded;

  const AddTaskFab({super.key, this.onTaskAdded});

  Future<void> _openVoiceLongTask(BuildContext context) async {
    await collectLongTaskWithVoiceForm(context, onTaskAdded: onTaskAdded);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'main_dashboard_add_task',
      onPressed: () => _openVoiceLongTask(context),
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.mic_none_rounded, size: 28),
    );
  }
}
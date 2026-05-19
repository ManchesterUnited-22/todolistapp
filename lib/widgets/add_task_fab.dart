import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_app/core/app_colors.dart';
import 'package:smart_app/views/task_viewmodel.dart';

class AddTaskFab extends StatelessWidget {
  final ValueChanged<String>? onTaskAdded;

  const AddTaskFab({super.key, this.onTaskAdded});

  Future<void> _openAddTaskSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    TimeOfDay selectedStartTime = TimeOfDay.now();
    DateTime selectedStartDate = DateTime.now();

    // Hạn chót (Deadline)
    TimeOfDay? selectedDeadlineTime;
    DateTime? selectedDeadlineDate;

    String selectedCategory = 'Công việc';
    String selectedPriority = 'Vừa';

    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext, false),
                          icon: const Icon(Icons.close_rounded, size: 28),
                          color: Colors.grey[700],
                        ),
                        const Expanded(
                          child: Text(
                            'Thêm công việc mới',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4648D4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://lh3.googleusercontent.com/aida/ADBb0uhbD5XXHWIBotA981jxUvc9BV7E4JHroOM9na50zPAjMqddH5-96EdYrsxpELtu__YY7aGGTWFcdci0liNE2wXXplyTQbKPtrylOHZIVopc4RNexyxof9Q6opfaF6leJEBXl5zztxoS-xwTLPr9OI0hdNHrdXQuVCfdTkvEddYbtQ9Jq9eCHCfsGnEopd7BN-_0x_z4TRNxPETpOQLI5qtnEvXnhAYrEyVmoZ0Rqlk1cNEqkumNiG_RnFc',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Tip
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida/ADBb0uhbD5XXHWIBotA981jxUvc9BV7E4JHroOM9na50zPAjMqddH5-96EdYrsxpELtu__YY7aGGTWFcdci0liNE2wXXplyTQbKPtrylOHZIVopc4RNexyxof9Q6opfaF6leJEBXl5zztxoS-xwTLPr9OI0hdNHrdXQuVCfdTkvEddYbtQ9Jq9eCHCfsGnEopd7BN-_0x_z4TRNxPETpOQLI5qtnEvXnhAYrEyVmoZ0Rqlk1cNEqkumNiG_RnFc',
                                  width: 48,
                                  height: 48,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Serene gợi ý:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4648D4),
                                        ),
                                      ),
                                      Text(
                                        'Hãy chia nhỏ công việc để hoàn thành dễ dàng hơn nhé!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tên công việc
                          const Text(
                            'Tên công việc',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: Hoàn thành thiết kế UI',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Ghi chú
                          const Text(
                            'Ghi chú',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Mô tả chi tiết nhiệm vụ của bạn...',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Bắt đầu
                          const Text(
                            'Bắt đầu',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeDateSelector(
                                  icon: Icons.schedule_rounded,
                                  label: 'Thời gian',
                                  value: selectedStartTime.format(context),
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: selectedStartTime,
                                    );
                                    if (picked != null)
                                      setModalState(
                                        () => selectedStartTime = picked,
                                      );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeDateSelector(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Ngày',
                                  value: 'Hôm nay',
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedStartDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (picked != null)
                                      setModalState(
                                        () => selectedStartDate = picked,
                                      );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ==================== HẠN CHỐT (MỚI) ====================
                          const Text(
                            'Hạn chót',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeDateSelector(
                                  icon: Icons.schedule_rounded,
                                  label: 'Thời gian',
                                  value:
                                      selectedDeadlineTime?.format(context) ??
                                      'Chọn giờ',
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime:
                                          selectedDeadlineTime ??
                                          TimeOfDay(hour: 17, minute: 0),
                                    );
                                    if (picked != null) {
                                      setModalState(
                                        () => selectedDeadlineTime = picked,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeDateSelector(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Ngày',
                                  value: selectedDeadlineDate != null
                                      ? '${selectedDeadlineDate!.day}/${selectedDeadlineDate!.month}'
                                      : 'Chọn ngày',
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          selectedDeadlineDate ??
                                          DateTime.now().add(
                                            const Duration(days: 1),
                                          ),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (picked != null) {
                                      setModalState(
                                        () => selectedDeadlineDate = picked,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Danh mục
                          const Text(
                            'Danh mục',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildCategoryChip(
                                'Công việc',
                                Icons.work_rounded,
                                selectedCategory == 'Công việc',
                                () => setModalState(
                                  () => selectedCategory = 'Công việc',
                                ),
                              ),
                              _buildCategoryChip(
                                'Cá nhân',
                                Icons.person_rounded,
                                selectedCategory == 'Cá nhân',
                                () => setModalState(
                                  () => selectedCategory = 'Cá nhân',
                                ),
                              ),
                              _buildCategoryChip(
                                'Sức khỏe',
                                Icons.favorite_rounded,
                                selectedCategory == 'Sức khỏe',
                                () => setModalState(
                                  () => selectedCategory = 'Sức khỏe',
                                ),
                              ),
                              _buildCategoryChip(
                                'Khác',
                                Icons.add_rounded,
                                false,
                                () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Mức độ ưu tiên
                          const Text(
                            'Mức độ ưu tiên',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildPriorityButton(
                                'Thấp',
                                Icons.low_priority,
                                Colors.green,
                                selectedPriority == 'Thấp',
                                () => setModalState(
                                  () => selectedPriority = 'Thấp',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityButton(
                                'Vừa',
                                Icons.drag_handle_rounded,
                                const Color(0xFF4648D4),
                                selectedPriority == 'Vừa',
                                () => setModalState(
                                  () => selectedPriority = 'Vừa',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPriorityButton(
                                'Cao',
                                Icons.priority_high,
                                Colors.red,
                                selectedPriority == 'Cao',
                                () => setModalState(
                                  () => selectedPriority = 'Cao',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;
                          Navigator.of(sheetContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Lưu công việc',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (didSave == true &&
        titleController.text.trim().isNotEmpty &&
        context.mounted) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final now = DateTime.now();

      DateTime? dueAtDateTime;
      if (selectedDeadlineDate != null || selectedDeadlineTime != null) {
        final date = selectedDeadlineDate ?? now;
        final time = selectedDeadlineTime ?? TimeOfDay.now();
        dueAtDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }

      final taskViewModel = TaskViewModel(
        id: DateTime.now().microsecondsSinceEpoch,
        title: titleController.text.trim(),
        detail: descriptionController.text.trim(),
        category: selectedCategory,
        priority: selectedPriority,
        way: 'long_term_task',
        stat: 'Đang làm',
        createdAt: Timestamp.fromDate(now),
        dueAt: dueAtDateTime != null ? Timestamp.fromDate(dueAtDateTime) : null,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu task: $error')));
      }
    }
  }

  // Các hàm helper giữ nguyên...
  Widget _buildTimeDateSelector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brand),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brand : Colors.grey[100],
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey[600]),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'add_task_sheet_parts.dart';

class AddTaskDraft {
  final String title;
  final String detail;
  final String category;
  final String priority;
  final DateTime? dueAt;

  const AddTaskDraft({
    required this.title,
    required this.detail,
    required this.category,
    required this.priority,
    required this.dueAt,
  });
}

Future<AddTaskDraft?> showAddTaskSheet(BuildContext context) {
  return showModalBottomSheet<AddTaskDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => const _AddTaskSheet(),
  );
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TimeOfDay? _selectedDeadlineTime;
  DateTime? _selectedDeadlineDate;
  String _selectedCategory = 'Công việc';
  String _selectedPriority = 'Vừa';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    DateTime? dueAtDateTime;
    if (_selectedDeadlineDate != null || _selectedDeadlineTime != null) {
      final date = _selectedDeadlineDate ?? DateTime.now();
      final time = _selectedDeadlineTime ?? TimeOfDay.now();
      dueAtDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    Navigator.of(context).pop(
      AddTaskDraft(
        title: title,
        detail: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueAt: dueAtDateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.92;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          AddTaskSheetHeader(onClose: () => Navigator.pop(context)),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AddTaskSheetTip(),
                  const SizedBox(height: 24),
                  const AddTaskSectionTitle('Tên công việc'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
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
                  const AddTaskSectionTitle('Ghi chú'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
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
                  const AddTaskSectionTitle('Hạn chót'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AddTaskTimeDateSelector(
                          icon: Icons.schedule_rounded,
                          label: 'Thời gian',
                          value:
                              _selectedDeadlineTime?.format(context) ??
                              'Chọn giờ',
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  _selectedDeadlineTime ??
                                  const TimeOfDay(hour: 17, minute: 0),
                            );
                            if (picked != null) {
                              setState(() => _selectedDeadlineTime = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AddTaskTimeDateSelector(
                          icon: Icons.calendar_today_rounded,
                          label: 'Ngày',
                          value: _selectedDeadlineDate != null
                              ? '${_selectedDeadlineDate!.day}/${_selectedDeadlineDate!.month}'
                              : 'Chọn ngày',
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  _selectedDeadlineDate ??
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setState(() => _selectedDeadlineDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const AddTaskSectionTitle('Danh mục'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AddTaskCategoryChip(
                        label: 'Công việc',
                        icon: Icons.work_rounded,
                        isSelected: _selectedCategory == 'Công việc',
                        onTap: () => setState(() => _selectedCategory = 'Công việc'),
                      ),
                      AddTaskCategoryChip(
                        label: 'Cá nhân',
                        icon: Icons.person_rounded,
                        isSelected: _selectedCategory == 'Cá nhân',
                        onTap: () => setState(() => _selectedCategory = 'Cá nhân'),
                      ),
                      AddTaskCategoryChip(
                        label: 'Sức khỏe',
                        icon: Icons.favorite_rounded,
                        isSelected: _selectedCategory == 'Sức khỏe',
                        onTap: () => setState(() => _selectedCategory = 'Sức khỏe'),
                      ),
                      AddTaskCategoryChip(
                        label: 'Khác',
                        icon: Icons.add_rounded,
                        isSelected: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const AddTaskSectionTitle('Mức độ ưu tiên'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AddTaskPriorityButton(
                        label: 'Thấp',
                        icon: Icons.low_priority,
                        color: Colors.green,
                        isSelected: _selectedPriority == 'Thấp',
                        onTap: () => setState(() => _selectedPriority = 'Thấp'),
                      ),
                      const SizedBox(width: 8),
                      AddTaskPriorityButton(
                        label: 'Vừa',
                        icon: Icons.drag_handle_rounded,
                        color: const Color(0xFF4648D4),
                        isSelected: _selectedPriority == 'Vừa',
                        onTap: () => setState(() => _selectedPriority = 'Vừa'),
                      ),
                      const SizedBox(width: 8),
                      AddTaskPriorityButton(
                        label: 'Cao',
                        icon: Icons.priority_high,
                        color: Colors.red,
                        isSelected: _selectedPriority == 'Cao',
                        onTap: () => setState(() => _selectedPriority = 'Cao'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                onPressed: _submit,
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
  }
}
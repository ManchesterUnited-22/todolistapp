import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/ai/voiceassistant/voicebutton/voice_input_dialog.dart';
import 'package:smart_app/views/task_viewmodel.dart';



Future<void> collectLongTaskWithVoiceForm(
  BuildContext context, {
  String? initialTranscript,
  ValueChanged<String>? onTaskAdded,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để lưu nhiệm vụ')),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LongTaskVoiceFormDialog(
      uid: user.uid,
      initialTranscript: initialTranscript,
      onTaskAdded: onTaskAdded,
    ),
  );
}

class _LongTaskVoiceFormDialog extends StatefulWidget {
  final String uid;
  final String? initialTranscript;
  final ValueChanged<String>? onTaskAdded;

  const _LongTaskVoiceFormDialog({
    required this.uid,
    required this.initialTranscript,
    required this.onTaskAdded,
  });

  @override
  State<_LongTaskVoiceFormDialog> createState() => _LongTaskVoiceFormDialogState();
}

class _LongTaskVoiceFormDialogState extends State<_LongTaskVoiceFormDialog> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();

  String _priority = 'Vừa';
  String _category = 'Công việc';
  DateTime? _dueAt;
  String _voiceStatus = 'Sẵn sàng ghi âm';
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialTranscript != null && widget.initialTranscript!.trim().isNotEmpty) {
        _applyTranscript(widget.initialTranscript!.trim());
      }
      await _greetAndListen();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _playTing() async {
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> _greetAndListen() async {
    if (!mounted) return;
    setState(() => _voiceStatus = 'AI đang chào bạn...');

    await _playTing();
    await VoiceAiService.instance.speakText('Mình đang nghe đây, bạn muốn thêm việc gì?');

    if (!mounted) return;
    setState(() => _voiceStatus = 'Đang ghi âm...');

    final transcript = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(
        prompt: 'Nói một câu đầy đủ: tên việc, ưu tiên, loại, thời gian',
      ),
    );

    if (!mounted) return;
    if (transcript == null || transcript.trim().isEmpty) {
      setState(() => _voiceStatus = 'Chưa ghi nhận câu nói');
      return;
    }

    _applyTranscript(transcript.trim());
    await _playTing();
    if (!mounted) return;
    setState(() => _voiceStatus = 'Đã ghi nhận thành công. Bạn kiểm tra form và bấm Lưu.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã ghi nhận giọng nói thành công')), 
    );
  }

  void _applyTranscript(String transcript) {
    final title = _extractTitle(transcript);
    final priority = _parsePriority(transcript);
    final category = _parseCategory(transcript);
    final dueAt = _parseDueAt(transcript);

    if (title != null && title.trim().isNotEmpty) {
      _titleController.text = title;
    }
    if (priority != null) _priority = priority;
    if (category != null) _category = category;
    if (dueAt != null) _dueAt = dueAt;

    if (mounted) setState(() {});
  }

  Future<String?> _askByVoice(String prompt) async {
    await _playTing();
    await VoiceAiService.instance.speakText(prompt);
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VoiceInputDialog(prompt: prompt),
    );
  }

  Future<bool> _fillMissingRequiredFields() async {
    if (_titleController.text.trim().isEmpty) {
      final answer = await _askByVoice('Tên công việc là gì vậy nhỉ?');
      if (answer != null && answer.trim().isNotEmpty) {
        _titleController.text = answer.trim();
      }
    }

    if (_priority.trim().isEmpty || _priority == 'Không rõ') {
      final answer = await _askByVoice('Độ ưu tiên của công việc là gì vậy nhỉ?');
      final parsed = answer == null ? null : _parsePriority(answer);
      if (parsed != null) _priority = parsed;
    }

    if (_category.trim().isEmpty || _category == 'Không rõ') {
      final answer = await _askByVoice('Loại công việc là gì vậy nhỉ?');
      final parsed = answer == null ? null : _parseCategory(answer);
      if (parsed != null) _category = parsed;
    }

    if (_dueAt == null) {
      final answer = await _askByVoice('Thời gian thực hiện công việc là khi nào vậy nhỉ?');
      final parsed = answer == null ? null : _parseDueAt(answer);
      if (parsed != null) _dueAt = parsed;
    }

    if (mounted) setState(() {});

    return _titleController.text.trim().isNotEmpty &&
        _priority.trim().isNotEmpty &&
        _category.trim().isNotEmpty &&
        _dueAt != null;
  }

  Future<void> _saveTask() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final ok = await _fillMissingRequiredFields();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thiếu thông tin bắt buộc, chưa thể lưu task.')),
          );
        }
        return;
      }

      final now = DateTime.now();
      final task = TaskViewModel(
        id: now.microsecondsSinceEpoch,
        title: _titleController.text.trim(),
        detail: _detailController.text.trim(),
        category: _category,
        priority: _priority,
        way: 'long_term_task',
        stat: 'Đang làm',
        createdAt: Timestamp.fromDate(now),
        dueAt: Timestamp.fromDate(_dueAt!),
        dateString:
            '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        timestamp: Timestamp.fromDate(now),
        uid: widget.uid,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .add(task.toFirestoreMap());

      widget.onTaskAdded?.call(task.title);
      await _playTing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm task dài hạn: ${task.title}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueText = _dueAt == null ? 'Chưa chọn' : DateFormat('dd/MM/yyyy HH:mm').format(_dueAt!);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Task dài hạn (Voice Form)'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _voiceStatus,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF464554)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên công việc',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cao', child: Text('Cao')),
                  DropdownMenuItem(value: 'Vừa', child: Text('Vừa')),
                  DropdownMenuItem(value: 'Thấp', child: Text('Thấp')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 'Vừa'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Loại công việc',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Công việc', child: Text('Công việc')),
                  DropdownMenuItem(value: 'Học tập', child: Text('Học tập')),
                  DropdownMenuItem(value: 'Cá nhân', child: Text('Cá nhân')),
                  DropdownMenuItem(value: 'Sức khỏe', child: Text('Sức khỏe')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Công việc'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueAt ?? now,
                    firstDate: DateTime(now.year - 1, 1, 1),
                    lastDate: DateTime(now.year + 5, 12, 31),
                  );
                  if (date == null) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dueAt ?? now),
                  );
                  if (time == null) return;
                  setState(() {
                    _dueAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Thời gian',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dueText),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        OutlinedButton.icon(
          onPressed: _saving ? null : _greetAndListen,
          icon: const Icon(Icons.mic_none_rounded),
          label: const Text('Nói lại'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveTask,
          child: Text(_saving ? 'Đang lưu...' : 'Lưu task'),
        ),
      ],
    );
  }
}

String? _extractTitle(String input) {
  final normalized = input.trim();
  if (normalized.isEmpty) return null;

  final nameRegex = RegExp(r'(?:tên|việc|công việc)\s*(?:là)?\s*([^,.;]+)', caseSensitive: false);
  final match = nameRegex.firstMatch(normalized);
  if (match != null) {
    final value = (match.group(1) ?? '').trim();
    if (value.isNotEmpty) return value;
  }

  var cleaned = normalized
      .replaceAll(RegExp(r'ưu tiên[^,.;]*', caseSensitive: false), '')
      .replaceAll(RegExp(r'(loại|danh mục)[^,.;]*', caseSensitive: false), '')
      .replaceAll(RegExp(r'(hạn|thời gian|ngày|lúc)[^,.;]*', caseSensitive: false), '')
      .trim();
  if (cleaned.isEmpty) return null;
  return cleaned;
}

String? _parsePriority(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('cao') || lower.contains('high')) return 'Cao';
  if (lower.contains('thấp') || lower.contains('thap') || lower.contains('low')) return 'Thấp';
  if (lower.contains('vừa') || lower.contains('vua') || lower.contains('medium')) return 'Vừa';
  return null;
}

String? _parseCategory(String input) {
  final lower = input.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('ca nhan') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('suc') || lower.contains('health')) return 'Sức khỏe';
  if (lower.contains('công') || lower.contains('cong') || lower.contains('work')) return 'Công việc';
  return null;
}

DateTime? _parseDueAt(String input) {
  final lower = input.toLowerCase().trim();
  final now = DateTime.now();
  DateTime base = now;

  final dateRegex = RegExp(r'(\d{1,2})[\/-](\d{1,2})(?:[\/-](\d{2,4}))?');
  final dateMatch = dateRegex.firstMatch(lower);
  if (dateMatch != null) {
    final d = int.tryParse(dateMatch.group(1) ?? '') ?? now.day;
    final m = int.tryParse(dateMatch.group(2) ?? '') ?? now.month;
    int y;
    if (dateMatch.group(3) != null) {
      y = int.tryParse(dateMatch.group(3)!) ?? now.year;
      if (y < 100) y += 2000;
    } else {
      y = now.year;
    }
    base = DateTime(y, m, d);
  } else if (lower.contains('ngày mai') || lower.contains('mai')) {
    base = now.add(const Duration(days: 1));
  } else if (lower.contains('tuần sau')) {
    base = now.add(const Duration(days: 7));
  }

  int? hour;
  int minute = 0;
  final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
  if (hm != null) {
    hour = int.tryParse(hm.group(1) ?? '0') ?? 0;
    minute = int.tryParse(hm.group(2) ?? '0') ?? 0;
  } else {
    final onlyNum = RegExp(r'\b(\d{1,2})\b').firstMatch(lower);
    if (onlyNum != null) {
      hour = int.tryParse(onlyNum.group(1) ?? '0') ?? 0;
    }
  }

  if (hour == null) return null;

  if ((lower.contains('chiều') || lower.contains('tối')) && hour < 12) {
    hour += 12;
  }

  return DateTime(base.year, base.month, base.day, hour, minute);
}

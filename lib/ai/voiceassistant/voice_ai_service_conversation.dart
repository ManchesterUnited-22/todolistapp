part of voice_ai_service;

String? _parseWay(String text) {
  if (text.contains('pomodoro') || text.contains('pomodo') || text.contains('pomodoro')) return 'pomodoro';
  if (text.contains('dài hạn') || text.contains('dai han') || text.contains('dài') || text.contains('dài hạn')) return 'long_term_task';
  // try common short forms
  if (text.contains('ngắn') || text.contains('pom')) return 'pomodoro';
  return null;
}

bool _isAffirmative(String text) {
  final t = text.toLowerCase();
  return t.contains('có') || t.contains('đồng ý') || t.contains('ok') || t.contains('được') || t.contains('yes') || t.contains('okie') || t.contains('đồngy');
}

String? _parseCategory(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('học')) return 'Học tập';
  if (lower.contains('cá nhân') || lower.contains('ca nhan') || lower.contains('personal')) return 'Cá nhân';
  if (lower.contains('sức') || lower.contains('suc') || lower.contains('health')) return 'Sức khỏe';
  if (lower.contains('công') || lower.contains('cong')) return 'Công việc';
  return null;
}

int? _parseDurationMinutes(String text) {
  final numMatch = RegExp(r'(\d{1,3})').firstMatch(text);
  if (numMatch != null) {
    final v = int.tryParse(numMatch.group(1) ?? '');
    if (v != null && v > 0) return v;
  }
  return null;
}

String? _parsePriority(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('cao')) return 'Cao';
  if (lower.contains('thấp') || lower.contains('thap')) return 'Thấp';
  if (lower.contains('vừa') || lower.contains('vua') || lower.contains('vừa')) return 'Vừa';
  return null;
}

DateTime? _parseDueAtVoice(String text) {
  final lower = text.toLowerCase();
  final now = DateTime.now();

  if (lower.contains('không') || lower.contains('khong') || lower.contains('no')) return null;

  // hôm nay / ngày mai
  DateTime base = now;
  if (lower.contains('ngày mai') || lower.contains('mai')) base = now.add(const Duration(days: 1));
  else if (lower.contains('hôm nay') || lower.contains('hom nay') || lower.contains('hôm nay')) base = now;

  // time hh:mm
  final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(lower);
  if (hm != null) {
    final h = int.tryParse(hm.group(1) ?? '0') ?? 0;
    final m = int.tryParse(hm.group(2) ?? '0') ?? 0;
    return DateTime(base.year, base.month, base.day, h, m);
  }

  // number only -> hour
  final onlyNum = RegExp(r'\b(\d{1,2})\b').firstMatch(lower);
  if (onlyNum != null) {
    final h = int.tryParse(onlyNum.group(1) ?? '0') ?? 0;
    return DateTime(base.year, base.month, base.day, h, 0);
  }

  return null;
}

String _buildVisualSummary(VoiceTaskConversationState state) {
  final parts = <String>[];
  parts.add('"${state.title ?? 'Nhiệm vụ'}"');
  parts.add('loại ${state.category ?? 'Chưa rõ'}');
  parts.add('thời lượng ${state.durationMinutes ?? 0} phút');
  parts.add('ưu tiên ${state.priority ?? 'Vừa'}');
  if (state.dueAt != null) {
    parts.add('hẹn ${DateFormat('yyyy-MM-dd HH:mm').format(state.dueAt!)}');
  }
  return parts.join(', ');
}

/// Dùng cho AI NÓI (ngắn gọn theo yêu cầu)
String _buildSpokenSummary(VoiceTaskConversationState state) {
  final title = state.title?.trim() ?? 'Nhiệm vụ mới';
  return "Đây là nhiệm vụ của bạn: $title. Bạn có muốn thay đổi gì không?";
}

// Hàm gốc - giữ nguyên tên để không làm hỏng các file khác
String _buildSummary(VoiceTaskConversationState state) {
  return _buildSpokenSummary(state);   // ← Đã thay đổi theo yêu cầu của bạn
}

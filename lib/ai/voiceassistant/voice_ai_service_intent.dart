part of voice_ai_service;

Future<Map<String, dynamic>?> voiceAiExtractIntentFromText(
  VoiceAiService self,
  String userText,
) async {
  try {
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final tomorrowDate = now.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrowDate.year.toString().padLeft(4, '0')}-'
        '${tomorrowDate.month.toString().padLeft(2, '0')}-'
        '${tomorrowDate.day.toString().padLeft(2, '0')}';

    final candidateModels = [
      'gemini-2.5-flash',
    ];

    Exception? lastException;

    for (final m in candidateModels) {
      try {
        final model = GenerativeModel(
          model: m,
          apiKey: self._apiKey,
          systemInstruction: Content.system('''
Bạn là trợ lý trích xuất ý định từ câu nói cho ứng dụng Todo. Chỉ trả về JSON duy nhất, không Markdown, không giải thích.

=== THÔNG TIN THỜI GIAN HIỆN TẠI ===
- Hôm nay: $todayStr
- Ngày mai: $tomorrowStr
- Giờ hiện tại: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
=====================================

Ghi chú về ngày/giờ:
- Khi người dùng nói "ngày mai" → date = "$tomorrowStr"
- Khi người dùng nói "hôm nay" → date = "$todayStr"
- Khi người dùng nói "tuần sau" → cộng thêm 7 ngày từ hôm nay.
- Trường "date" LUÔN theo định dạng YYYY-MM-DD hoặc null.
- Trường "time" LUÔN theo định dạng HH:mm (24h) hoặc null.

Hãy phân loại ý định thành một trong các kiểu JSON sau (chỉ chọn 1 kiểu):

1) Promodoro (nhanh):
{
  "type": "promodoro",
  "task_name": "Tiêu đề công việc",
  "duration_minutes": 25,         // số phút tập trung (int)
  "category": "Công việc" | "Học tập" | "Cá nhân" | "Sức khỏe" | null,
  "priority": "Cao" | "Vừa" | "Thấp" | null
}

2) Task dài hạn:
{
  "type": "task",
  "way": "long_term_task",
  "task_name": "Tiêu đề công việc",
  "date": "YYYY-MM-DD" hoặc null,
  "time": "HH:mm" hoặc null,
  "category": "Công việc" | "Học tập" | "Cá nhân" | "Sức khỏe" | null,
  "priority": "Cao" | "Vừa" | "Thấp" | null
}

3) Command (điều hướng):
{
  "type": "command",
  "action": "navigate",
  "target": "charts" | "calendar" | "dashboard" | "profile" | "stats",
  "params": {
    "diagram": true | false,
    "view": "voice_diagram" | null,
    "rangeType": "day" | "week" | "month" | "year" | null,
    "anchorDate": "YYYY-MM-DD" | null,
    "label": "..." | null
  }
}

Ghi chú cho biểu đồ:
- Nếu người dùng yêu cầu "xem biểu đồ", "xem hiệu suất" hoặc "thống kê theo thời gian", trả target = "charts" và params.diagram = true.
- rangeType = "day" khi người dùng nói ngày cụ thể hoặc các cụm như "hôm qua", "hôm nay".
- rangeType = "week" cho "tuần này", "tuần trước", "tuần sau".
- rangeType = "month" cho "tháng này", "tháng trước", "tháng sau".
- rangeType = "year" cho "năm nay", "năm ngoái", "năm sau".
- anchorDate LUÔN theo định dạng YYYY-MM-DD nếu có giá trị.

4) Không hiểu / noop:
{
  "type": "noop"
}

Hướng dẫn quan trọng:
- Nếu câu nói chứa từ khoá "pomodoro" hoặc "promodoro" hoặc đề cập rõ ràng đến thời lượng phút, trả kiểu "promodoro".
- Nếu người dùng rõ ràng nói muốn tạo lịch/hẹn ngày giờ, trả kiểu "task" với trường date/time.
- Trả giá trị null cho các trường không có dữ liệu.
- CHỈ TRẢ VỀ JSON. KHÔNG THÊM BẤT KỲ VĂN BẢN NÀO KHÁC.
'''),
        );

        final response = await model.generateContent([
          Content.text(userText),
        ]);
        final jsonText = response.text;
        if (jsonText != null) {
          final cleanJson = jsonText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          try {
            return jsonDecode(cleanJson) as Map<String, dynamic>;
          } catch (_) {
            try {
              final start = cleanJson.indexOf('{');
              final end = cleanJson.lastIndexOf('}');
              if (start != -1 && end != -1 && end > start) {
                return jsonDecode(cleanJson.substring(start, end + 1))
                    as Map<String, dynamic>;
              }
            } catch (_) {}
            if (kDebugMode)
              debugPrint('AIService: cannot parse JSON: $cleanJson');
            return null;
          }
        }
      } catch (e) {
        lastException = e as Exception? ?? Exception(e.toString());
        if (kDebugMode) debugPrint('AIService: model "$m" failed: $e');
        continue;
      }
    }

    if (kDebugMode)
      debugPrint('AIService: all models failed. Last error: $lastException');
    final heuristic = _heuristicExtract(userText);
    if (heuristic != null) {
      if (kDebugMode) debugPrint('AIService: heuristic fallback: $heuristic');
      return heuristic;
    }
    return null;
  } catch (e) {
    if (kDebugMode) debugPrint('Lỗi xử lý AI: $e');
  }
  return null;
}

Future<Map<String, dynamic>?> voiceAiExtractTaskFromText(
  VoiceAiService self,
  String userText,
) async {
  final intent = await voiceAiExtractIntentFromText(self, userText);
  if (intent == null) return null;
  if ((intent['type'] as String?) == 'task') return intent;
  return null;
}

Future<void> voiceAiHandleVoiceInput(VoiceAiService self, String resultText) async {
  final intent = await voiceAiExtractIntentFromText(self, resultText);
  if (intent != null && intent['type'] == 'task') {
    if (kDebugMode)
      debugPrint(
        'Đã bóc tách: ${intent['task_name']} ngày ${intent['date']} lúc ${intent['time']}',
      );
  }
}

Map<String, dynamic>? _heuristicExtract(String text) {
  final raw = text.trim().toLowerCase();
  if (raw.isEmpty) return null;
  final chartIntent = _heuristicExtractChartNavigation(raw);
  if (chartIntent != null) return chartIntent;
  if (!(raw.contains('thêm') || raw.contains('tạo') || raw.contains('nhiệm vụ') || raw.contains('việc'))) return null;

  final now = DateTime.now();
  String? date;
  String? time;
  bool dateFromRelative = false;

  if (raw.contains('ngày mai')) {
    final d = now.add(const Duration(days: 1));
    date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    dateFromRelative = true;
  } else if (raw.contains('hôm nay')) {
    date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    dateFromRelative = true;
  } else if (raw.contains('tuần sau')) {
    final d = now.add(const Duration(days: 7));
    date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    dateFromRelative = true;
  }

  final dateRegex = RegExp(r'(\d{1,2}[\/\-]\d{1,2}(?:[\/\-]\d{2,4})?)');
  final dateMatch = dateRegex.firstMatch(raw);
  if (dateMatch != null && !dateFromRelative) {
    final parts = dateMatch.group(0)!.replaceAll('/', '-').split('-');
    if (parts.length >= 2) {
      final d = parts[0].padLeft(2, '0');
      final mo = parts[1].padLeft(2, '0');
      String y;
      if (parts.length >= 3) {
        y = parts[2].length == 2 ? '20${parts[2]}' : parts[2];
      } else {
        y = now.year.toString();
      }
      date = '${y.padLeft(4, '0')}-$mo-$d';
    }
  }

  final timeRegex = RegExp(r'(\d{1,2}:\d{2})');
  final timeMatch = timeRegex.firstMatch(raw);
  if (timeMatch != null) {
    final tp = timeMatch.group(0)!.split(':');
    time = '${tp[0].padLeft(2, '0')}:${tp[1].padLeft(2, '0')}';
  } else {
    final vnTime = RegExp(r'lúc\s*(\d{1,2})(?:\s*giờ)?(?:\s*(\d{1,2}))?');
    final vm = vnTime.firstMatch(raw);
    if (vm != null) {
      final hh = int.tryParse(vm.group(1) ?? '0') ?? 0;
      final mm = int.tryParse(vm.group(2) ?? '0') ?? 0;
      time = '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
    }
  }

  var name = raw;
  name = name.replaceAll(
    RegExp(r'\b(thêm|tạo|nhiệm vụ|việc|cho|vào|lúc|ngày mai|hôm nay|tuần sau|vào ngày|vào lúc)\b'),
    '',
  );
  if (dateMatch != null) name = name.replaceAll(dateMatch.group(0)!, '');
  if (timeMatch != null) name = name.replaceAll(timeMatch.group(0)!, '');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (name.isEmpty) {
    name = 'Công việc mới';
  }

  return {
    'type': 'task',
    'task_name': name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : ''),
    'date': date,
    'time': time,
    'person': null,
  };
}

Map<String, dynamic>? _heuristicExtractChartNavigation(String raw) {
  final chartKeywords = <String>[
    'biểu đồ',
    'thống kê',
    'hiệu suất',
    'xem biểu đồ',
    'mở biểu đồ',
    'xem thống kê',
    'xem hiệu suất',
  ];
  final hasChartKeyword = chartKeywords.any(raw.contains);
  if (!hasChartKeyword) return null;

  final now = DateTime.now();
  final period = _chartPeriodFromText(raw);
  final anchor = _chartAnchorFromText(raw, now, period);

  return {
    'type': 'command',
    'action': 'navigate',
    'target': 'charts',
    'params': {
      'diagram': true,
      'view': 'voice_diagram',
      'rangeType': period,
      'anchorDate': _formatIsoDate(anchor),
      'label': _chartLabelFromText(raw, period, anchor),
    },
  };
}

String _chartPeriodFromText(String raw) {
  if (raw.contains('năm')) return 'year';
  if (raw.contains('tháng')) return 'month';
  if (raw.contains('tuần')) return 'week';
  return 'day';
}

DateTime _chartAnchorFromText(String raw, DateTime now, String period) {
  if (raw.contains('hôm qua')) return now.subtract(const Duration(days: 1));
  if (raw.contains('hôm nay')) return now;
  if (raw.contains('ngày mai')) return now.add(const Duration(days: 1));
  if (raw.contains('tuần trước')) return now.subtract(const Duration(days: 7));
  if (raw.contains('tuần sau')) return now.add(const Duration(days: 7));
  if (raw.contains('tháng trước')) return DateTime(now.year, now.month - 1, 1);
  if (raw.contains('tháng sau')) return DateTime(now.year, now.month + 1, 1);
  if (raw.contains('năm ngoái')) return DateTime(now.year - 1, 1, 1);
  if (raw.contains('năm sau')) return DateTime(now.year + 1, 1, 1);

  final explicitDate = RegExp(r'(\d{1,2}[\/-]\d{1,2}(?:[\/-]\d{2,4})?)').firstMatch(raw);
  if (explicitDate != null) {
    final parsed = _parseDateLike(explicitDate.group(0)!, now);
    if (parsed != null) return parsed;
  }

  final monthMatch = RegExp(r'tháng\s*(\d{1,2})(?:\s*năm\s*(\d{4}))?').firstMatch(raw);
  if (monthMatch != null) {
    final month = int.tryParse(monthMatch.group(1) ?? '') ?? now.month;
    final year = int.tryParse(monthMatch.group(2) ?? '') ?? now.year;
    return DateTime(year, month, 1);
  }

  final yearMatch = RegExp(r'năm\s*(\d{4})').firstMatch(raw);
  if (yearMatch != null) {
    final year = int.tryParse(yearMatch.group(1) ?? '') ?? now.year;
    return DateTime(year, 1, 1);
  }

  switch (period) {
    case 'week':
      return now;
    case 'month':
      return DateTime(now.year, now.month, 1);
    case 'year':
      return DateTime(now.year, 1, 1);
    case 'day':
    default:
      return now;
  }
}

String _chartLabelFromText(String raw, String period, DateTime anchor) {
  if (raw.contains('hôm qua')) return 'Hôm qua';
  if (raw.contains('hôm nay')) return 'Hôm nay';
  if (raw.contains('ngày mai')) return 'Ngày mai';
  if (raw.contains('tuần trước')) return 'Tuần trước';
  if (raw.contains('tuần này')) return 'Tuần này';
  if (raw.contains('tuần sau')) return 'Tuần sau';
  if (raw.contains('tháng trước')) return 'Tháng trước';
  if (raw.contains('tháng này')) return 'Tháng này';
  if (raw.contains('tháng sau')) return 'Tháng sau';
  if (raw.contains('năm ngoái')) return 'Năm ngoái';
  if (raw.contains('năm nay')) return 'Năm nay';
  if (raw.contains('năm sau')) return 'Năm sau';

  switch (period) {
    case 'day':
      return _formatIsoDate(anchor);
    case 'week':
      return 'Tuần ${_formatIsoDate(anchor)}';
    case 'month':
      return '${anchor.month.toString().padLeft(2, '0')}/${anchor.year}';
    case 'year':
      return anchor.year.toString();
    default:
      return _formatIsoDate(anchor);
  }
}

String _formatIsoDate(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')}';
}

DateTime? _parseDateLike(String value, DateTime fallbackNow) {
  final cleaned = value.replaceAll('/', '-').trim();
  final parts = cleaned.split('-');
  if (parts.length < 2) return DateTime.tryParse(cleaned);

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (day == null || month == null) return DateTime.tryParse(cleaned);

  int year = fallbackNow.year;
  if (parts.length >= 3) {
    final rawYear = parts[2];
    year = rawYear.length == 2
        ? int.tryParse('20$rawYear') ?? fallbackNow.year
        : int.tryParse(rawYear) ?? fallbackNow.year;
  }

  return DateTime(year, month, day);
}

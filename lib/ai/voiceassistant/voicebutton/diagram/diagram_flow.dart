import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/ai/voice_ai_service.dart';

import '../voice_input_dialog.dart';
import 'voicediagram.dart';

Future<void> collectDiagramWithVoiceForm(
  BuildContext context, {
  String? initialTranscript,
  Map<String, dynamic>? initialParams,
}) async {
  final scaffold = ScaffoldMessenger.of(context);
  final ai = VoiceAiService.instance;

  try {
    await SystemSound.play(SystemSoundType.click);
    await ai.speakText(
      'Xin chào, bạn muốn xem biểu đồ trong khoảng thời gian nào?',
    );

    final spoken = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const VoiceInputDialog(prompt: _initialDiagramPrompt),
    );

    final primaryText = (spoken ?? '').trim().isNotEmpty
        ? spoken!.trim()
        : (initialTranscript ?? '').trim();

    if (primaryText.isEmpty) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Huỷ: chưa nhận được mốc thời gian cho biểu đồ')),
      );
      return;
    }

    final resolvedParams = <String, dynamic>{
      ...?initialParams,
      'diagram': true,
      'view': 'voice_diagram',
    };

    final intent = await ai.extractIntentFromText(primaryText);
    final intentParams = (intent?['params'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    resolvedParams.addAll(intentParams);
    resolvedParams.addAll(_heuristicDiagramParams(primaryText));

    if (!_hasRangeType(resolvedParams)) {
      final rangeReply = await _askByVoice(
        context,
        ai,
        'Bạn muốn xem theo ngày, tuần, tháng hay năm?',
      );
      if (rangeReply != null && rangeReply.trim().isNotEmpty) {
        resolvedParams.addAll(_heuristicDiagramParams(rangeReply));
      }
    }

    if (!_hasRangeType(resolvedParams)) {
      resolvedParams['rangeType'] = 'week';
    }

    if (!_hasAnchorDate(resolvedParams)) {
      final rangeType = (resolvedParams['rangeType'] as String?) ?? 'week';
      final detailPrompt = _anchorPromptByRange(rangeType);
      final dateReply = await _askByVoice(context, ai, detailPrompt);
      if (dateReply != null && dateReply.trim().isNotEmpty) {
        resolvedParams.addAll(_heuristicDiagramParams(dateReply));
      }
    }

    final combinedText = '$primaryText ${resolvedParams['rangeType'] ?? ''} ${resolvedParams['anchorDate'] ?? ''}';
    final request = VoiceDiagramRequest.fromVoiceIntent(
      combinedText,
      params: resolvedParams,
    );

    await ai.speakText(
      'Mình đã lưu mốc thời gian. Đang mở biểu đồ ${_periodLabel(request.period)} cho bạn.',
    );
    await openVoiceDiagram(context, request);
  } catch (e) {
    scaffold.showSnackBar(SnackBar(content: Text('Lỗi khi mở biểu đồ: $e')));
  }
}

Future<String?> _askByVoice(
  BuildContext context,
  VoiceAiService ai,
  String prompt,
) async {
  await SystemSound.play(SystemSoundType.click);
  await ai.speakText(prompt);
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => VoiceInputDialog(prompt: prompt),
  );
}

Map<String, dynamic> _heuristicDiagramParams(String input) {
  final text = input.toLowerCase();
  final params = <String, dynamic>{};

  if (text.contains('ngày') || text.contains('hôm nay') || text.contains('hôm qua')) {
    params['rangeType'] = 'day';
  } else if (text.contains('tuần')) {
    params['rangeType'] = 'week';
  } else if (text.contains('tháng')) {
    params['rangeType'] = 'month';
  } else if (text.contains('năm')) {
    params['rangeType'] = 'year';
  }

  final isoMatch = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(text);
  if (isoMatch != null) {
    final y = int.parse(isoMatch.group(1)!);
    final m = int.parse(isoMatch.group(2)!);
    final d = int.parse(isoMatch.group(3)!);
    params['anchorDate'] = _toIsoDate(DateTime(y, m, d));
    return params;
  }

  final dmyMatch = RegExp(r'(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{4}))?').firstMatch(text);
  if (dmyMatch != null) {
    final day = int.parse(dmyMatch.group(1)!);
    final month = int.parse(dmyMatch.group(2)!);
    final year = int.tryParse(dmyMatch.group(3) ?? '') ?? DateTime.now().year;
    params['anchorDate'] = _toIsoDate(DateTime(year, month, day));
    return params;
  }

  final monthYearMatch = RegExp(r'tháng\s*(\d{1,2})(?:\D+?(\d{4}))?').firstMatch(text);
  if (monthYearMatch != null) {
    final month = int.parse(monthYearMatch.group(1)!);
    final year = int.tryParse(monthYearMatch.group(2) ?? '') ?? DateTime.now().year;
    params['anchorDate'] = _toIsoDate(DateTime(year, month, 1));
    params['rangeType'] = params['rangeType'] ?? 'month';
    return params;
  }

  final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(text);
  if (yearMatch != null && (params['rangeType'] == 'year' || text.contains('năm'))) {
    final year = int.parse(yearMatch.group(1)!);
    params['anchorDate'] = _toIsoDate(DateTime(year, 1, 1));
    return params;
  }

  final now = DateTime.now();
  if (text.contains('hôm nay')) {
    params['anchorDate'] = _toIsoDate(now);
  } else if (text.contains('ngày mai')) {
    params['anchorDate'] = _toIsoDate(now.add(const Duration(days: 1)));
    params['rangeType'] = params['rangeType'] ?? 'day';
  } else if (text.contains('hôm qua')) {
    params['anchorDate'] = _toIsoDate(now.subtract(const Duration(days: 1)));
  } else if (text.contains('tuần trước')) {
    params['anchorDate'] = _toIsoDate(now.subtract(const Duration(days: 7)));
    params['rangeType'] = params['rangeType'] ?? 'week';
  } else if (text.contains('tuần này')) {
    params['anchorDate'] = _toIsoDate(now);
    params['rangeType'] = params['rangeType'] ?? 'week';
  } else if (text.contains('tuần sau')) {
    params['anchorDate'] = _toIsoDate(now.add(const Duration(days: 7)));
    params['rangeType'] = params['rangeType'] ?? 'week';
  } else if (text.contains('tháng trước')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year, now.month - 1, 1));
    params['rangeType'] = params['rangeType'] ?? 'month';
  } else if (text.contains('tháng này')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year, now.month, 1));
    params['rangeType'] = params['rangeType'] ?? 'month';
  } else if (text.contains('tháng sau')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year, now.month + 1, 1));
    params['rangeType'] = params['rangeType'] ?? 'month';
  } else if (text.contains('năm ngoái')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year - 1, 1, 1));
    params['rangeType'] = params['rangeType'] ?? 'year';
  } else if (text.contains('năm nay')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year, 1, 1));
    params['rangeType'] = params['rangeType'] ?? 'year';
  } else if (text.contains('năm sau')) {
    params['anchorDate'] = _toIsoDate(DateTime(now.year + 1, 1, 1));
    params['rangeType'] = params['rangeType'] ?? 'year';
  }

  return params;
}

bool _hasRangeType(Map<String, dynamic> params) {
  final value = params['rangeType'] as String?;
  return value != null && value.trim().isNotEmpty;
}

bool _hasAnchorDate(Map<String, dynamic> params) {
  final value = params['anchorDate'] as String?;
  return value != null && value.trim().isNotEmpty;
}

String _anchorPromptByRange(String rangeType) {
  switch (rangeType) {
    case 'day':
      return 'Bạn muốn xem theo ngày nào? Ví dụ: xem biểu đồ ngày hôm nay hoặc ngày 24/05/2026';
    case 'month':
      return 'Bạn muốn xem theo tháng nào? Ví dụ: xem biểu đồ tháng 5 năm 2026';
    case 'year':
      return 'Bạn muốn xem theo năm nào? Ví dụ: xem biểu đồ năm 2026';
    case 'week':
    default:
      return 'Bạn muốn xem theo tuần nào? Ví dụ: xem biểu đồ tuần này hoặc tuần trước';
  }
}

const String _initialDiagramPrompt =
  'Hãy nói 1 câu đầy đủ theo mẫu:\n'
  '- Ngày: xem biểu đồ ngày hôm nay\n'
  '- Tuần: xem biểu đồ tuần này\n'
  '- Tháng: xem biểu đồ tháng 5 năm 2026\n'
  '- Năm: xem biểu đồ năm 2026';

String _toIsoDate(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

String _periodLabel(VoiceDiagramPeriod period) {
  switch (period) {
    case VoiceDiagramPeriod.day:
      return 'theo ngày';
    case VoiceDiagramPeriod.week:
      return 'theo tuần';
    case VoiceDiagramPeriod.month:
      return 'theo tháng';
    case VoiceDiagramPeriod.year:
      return 'theo năm';
  }
}

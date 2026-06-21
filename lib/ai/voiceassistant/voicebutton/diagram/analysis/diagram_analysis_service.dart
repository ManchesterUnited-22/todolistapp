import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_app/ai/voice_ai_service.dart' as legacy_ai;
import 'package:smart_app/services/report_service.dart';
import 'package:smart_app/views/report_viewmodel.dart';
import 'package:smart_app/views/task_viewmodel.dart';

class DiagramAnalysisResult {
  final ReportViewModel report;
  final List<String> suggestions;
  final String rangeLabel;
  final DateTimeRange range;

  /// Lời khuyên hiển thị cho người dùng. Khi [adviceIsAi] = true, nội dung
  /// này do mô hình AI (Gemini) sinh ra dựa trên đúng số liệu hiệu suất của
  /// người dùng trong khung thời gian đang xem. Khi false, đây là lời khuyên
  /// dự phòng được suy ra từ dữ liệu (không cần API key) để màn hình luôn có
  /// nội dung hữu ích thay vì báo lỗi.
  final String adviceText;
  final bool adviceIsAi;

  const DiagramAnalysisResult({
    required this.report,
    required this.suggestions,
    required this.rangeLabel,
    required this.range,
    required this.adviceText,
    required this.adviceIsAi,
  });

  /// Toàn bộ nội dung phân tích ở dạng văn bản thuần, dùng để đọc to (TTS)
  /// khi người dùng bấm nút loa — gộp nhận định nhanh + lời khuyên thành một
  /// đoạn liền mạch, tự nhiên khi nghe.
  String get spokenSummary {
    final completionPct = report.totalTasks > 0
        ? ((report.completedTasks / report.totalTasks) * 100).round()
        : 0;
    final buffer = StringBuffer();
    buffer.writeln(
      'Đây là phân tích báo cáo cho $rangeLabel. '
      'Bạn đã hoàn thành ${report.completedTasks} trên tổng số ${report.totalTasks} nhiệm vụ, '
      'tương đương $completionPct phần trăm.',
    );
    for (final line in suggestions) {
      buffer.writeln(line);
    }
    buffer.writeln(
      adviceIsAi ? 'Lời khuyên từ AI dành cho bạn.' : 'Gợi ý cải thiện dành cho bạn.',
    );
    buffer.writeln(adviceText);
    return buffer.toString();
  }
}

class DiagramAnalysisService {
  DiagramAnalysisService._();
  static final DiagramAnalysisService instance = DiagramAnalysisService._();

  Future<DiagramAnalysisResult> buildAndStore({
    required String uid,
    required DateTimeRange range,
    required String rangeLabel,
    required List<TaskViewModel> tasks,
  }) async {
    final now = DateTime.now();
    final report = _buildReport(
      uid: uid,
      range: range,
      tasks: tasks,
      generatedAt: now,
    );
    final suggestions = _buildSuggestions(report);

    // Ưu tiên lời khuyên thật từ AI dựa trên hiệu suất của người dùng. Nếu
    // chưa cấu hình API key hoặc gọi mạng thất bại, tự động dùng lời khuyên
    // dự phòng được tính toán từ chính dữ liệu — người dùng luôn nhận được
    // gợi ý hữu ích, không bao giờ thấy lỗi trống trơn.
    final aiAdvice = await _generateAiAdvice(report);
    final adviceText = aiAdvice ?? _buildFallbackAdvice(report);
    final adviceIsAi = aiAdvice != null;

    final enrichedReport = _withNotes(
      report,
      '${suggestions.join('\n')}\n\n${adviceIsAi ? 'Lời khuyên AI:' : 'Gợi ý cải thiện:'}\n$adviceText',
    );

    await ReportService.instance.saveReport(
      enrichedReport,
      docId: _reportDocId(uid, range),
    );

    return DiagramAnalysisResult(
      report: enrichedReport,
      suggestions: suggestions,
      rangeLabel: rangeLabel,
      range: range,
      adviceText: adviceText,
      adviceIsAi: adviceIsAi,
    );
  }

  ReportViewModel _buildReport({
    required String uid,
    required DateTimeRange range,
    required List<TaskViewModel> tasks,
    required DateTime generatedAt,
  }) {
    int completedTasks = 0;
    int overdueTasks = 0;
    int onTimeCount = 0;
    int lateCount = 0;
    int totalDelayMinutes = 0;

    int highPriority = 0;
    int mediumPriority = 0;
    int lowPriority = 0;
    int highCompleted = 0;
    int mediumCompleted = 0;
    int lowCompleted = 0;

    final Map<String, int> categoryCounts = {};
    final Map<String, ReportCategoryStat> categoryStats = {};

    String topOverdueTitle = 'Không có';
    int topOverdueMinutes = 0;
    int incompleteOverdueCount = 0;
    int completedLateCount = 0;
    int completedLateTotalMinutes = 0;
    String earliestCompletionTitle = 'Không có';
    int earliestCompletionMinutes = 0;

    for (final task in tasks) {
      final priorityRaw = (task.priority ?? '').toLowerCase();
      final categoryRaw = task.category.trim().isEmpty ? 'Khác' : task.category.trim();
      final due = task.dueAt?.toDate();
      final completed = task.completedAt?.toDate();
      final isCompleted = task.stat.toLowerCase().contains('hoàn') ||
          task.stat.toLowerCase().contains('hoan') ||
          completed != null;

      final priorityKey = _priorityKey(priorityRaw);
      switch (priorityKey) {
        case 'high':
          highPriority++;
          break;
        case 'low':
          lowPriority++;
          break;
        default:
          mediumPriority++;
          break;
      }

      categoryCounts[categoryRaw] = (categoryCounts[categoryRaw] ?? 0) + 1;
      categoryStats.putIfAbsent(
        categoryRaw,
        () => ReportCategoryStat(
          name: categoryRaw,
          count: 0,
          overdueCount: 0,
          lateCount: 0,
          overdueMinutes: 0,
        ),
      );
      categoryStats[categoryRaw] = ReportCategoryStat(
        name: categoryRaw,
        count: categoryStats[categoryRaw]!.count + 1,
        overdueCount: categoryStats[categoryRaw]!.overdueCount,
        lateCount: categoryStats[categoryRaw]!.lateCount,
        overdueMinutes: categoryStats[categoryRaw]!.overdueMinutes,
      );

      if (isCompleted) {
        completedTasks++;
        switch (priorityKey) {
          case 'high':
            highCompleted++;
            break;
          case 'low':
            lowCompleted++;
            break;
          default:
            mediumCompleted++;
            break;
        }
      }

      if (isCompleted && completed != null && due != null) {
        final diff = completed.difference(due).inMinutes;
        if (diff <= 0) {
          onTimeCount++;
          final earlyMins = due.difference(completed).inMinutes;
          if (earlyMins > 0 && earlyMins > earliestCompletionMinutes) {
            earliestCompletionMinutes = earlyMins;
            earliestCompletionTitle = task.title;
          }
        } else {
          lateCount++;
          totalDelayMinutes += diff;
          completedLateCount++;
          completedLateTotalMinutes += diff;
          final cs = categoryStats[categoryRaw]!;
          categoryStats[categoryRaw] = ReportCategoryStat(
            name: cs.name,
            count: cs.count,
            overdueCount: cs.overdueCount,
            lateCount: cs.lateCount + 1,
            overdueMinutes: cs.overdueMinutes + diff,
          );
          if (diff > topOverdueMinutes) {
            topOverdueMinutes = diff;
            topOverdueTitle = task.title;
          }
        }
      } else if (!isCompleted && due != null && due.isBefore(DateTime.now())) {
        final overdueMins = DateTime.now().difference(due).inMinutes;
        overdueTasks++;
        incompleteOverdueCount++;
        final cs = categoryStats[categoryRaw]!;
        categoryStats[categoryRaw] = ReportCategoryStat(
          name: cs.name,
          count: cs.count,
          overdueCount: cs.overdueCount + 1,
          lateCount: cs.lateCount,
          overdueMinutes: cs.overdueMinutes + overdueMins,
        );
        if (overdueMins > topOverdueMinutes) {
          topOverdueMinutes = overdueMins;
          topOverdueTitle = task.title;
        }
      }
    }

    final avgDelay = lateCount > 0 ? (totalDelayMinutes / lateCount).round() : 0;
    final topCategory = categoryCounts.entries
            .fold<MapEntry<String, int>?>(
              null,
              (prev, entry) => prev == null || entry.value > prev.value ? entry : prev,
            )
            ?.key ??
        'Không rõ';

    return ReportViewModel(
      uid: uid,
      periodStart: Timestamp.fromDate(range.start),
      periodEnd: Timestamp.fromDate(range.end),
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      overdueTasks: overdueTasks,
      onTimeCount: onTimeCount,
      lateCount: lateCount,
      avgDelayMinutes: avgDelay,
      priorityCounts: {'high': highPriority, 'medium': mediumPriority, 'low': lowPriority},
      completedByPriority: {'high': highCompleted, 'medium': mediumCompleted, 'low': lowCompleted},
      categoryCounts: categoryCounts,
      topCategory: topCategory,
      topOverdueTitle: topOverdueTitle,
      topOverdueMinutes: topOverdueMinutes,
      incompleteOverdueCount: incompleteOverdueCount,
      completedLateCount: completedLateCount,
      completedLateTotalMinutes: completedLateTotalMinutes,
      earliestCompletionTitle: earliestCompletionTitle,
      earliestCompletionMinutes: earliestCompletionMinutes,
      categoryStats: categoryStats,
      notes: '',
      generatedAt: Timestamp.fromDate(generatedAt),
    );
  }

  ReportViewModel _withNotes(ReportViewModel report, String notes) {
    return ReportViewModel(
      id: report.id,
      uid: report.uid,
      periodStart: report.periodStart,
      periodEnd: report.periodEnd,
      totalTasks: report.totalTasks,
      completedTasks: report.completedTasks,
      overdueTasks: report.overdueTasks,
      onTimeCount: report.onTimeCount,
      lateCount: report.lateCount,
      avgDelayMinutes: report.avgDelayMinutes,
      priorityCounts: report.priorityCounts,
      completedByPriority: report.completedByPriority,
      categoryCounts: report.categoryCounts,
      topCategory: report.topCategory,
      topOverdueTitle: report.topOverdueTitle,
      topOverdueMinutes: report.topOverdueMinutes,
      incompleteOverdueCount: report.incompleteOverdueCount,
      completedLateCount: report.completedLateCount,
      completedLateTotalMinutes: report.completedLateTotalMinutes,
      earliestCompletionTitle: report.earliestCompletionTitle,
      earliestCompletionMinutes: report.earliestCompletionMinutes,
      categoryStats: report.categoryStats,
      notes: notes,
      generatedAt: report.generatedAt,
      updatedAt: report.updatedAt,
    );
  }

  /// Phân tích "Nhận định nhanh" — phiên bản chi tiết hơn, khai thác đầy đủ
  /// các chiều dữ liệu đã có sẵn trong [ReportViewModel] (đúng hạn/trễ hạn,
  /// độ ưu tiên, danh mục, độ trễ trung bình...) thay vì chỉ 3-4 câu tổng
  /// quát như trước.
  List<String> _buildSuggestions(ReportViewModel report) {
    if (report.totalTasks == 0) {
      return ['Chưa có nhiệm vụ nào trong khung thời gian này để phân tích.'];
    }

    final completionPct = ((report.completedTasks / report.totalTasks) * 100).round();
    final completedWithDueDate = report.onTimeCount + report.lateCount;
    final onTimePct = completedWithDueDate > 0
        ? ((report.onTimeCount / completedWithDueDate) * 100).round()
        : null;

    final suggestions = <String>[
      'Tỷ lệ hoàn thành đạt $completionPct% (${report.completedTasks}/${report.totalTasks} nhiệm vụ).',
    ];

    // Đúng hạn vs trễ hạn trong số các việc đã hoàn thành.
    if (onTimePct != null) {
      if (onTimePct >= 80) {
        suggestions.add('Trong số việc đã hoàn thành, $onTimePct% đúng hạn — kỷ luật thời gian rất tốt.');
      } else if (onTimePct >= 50) {
        suggestions.add('$onTimePct% việc hoàn thành đúng hạn, còn ${100 - onTimePct}% bị trễ — vẫn còn khoảng cải thiện.');
      } else {
        suggestions.add('Chỉ $onTimePct% việc hoàn thành đúng hạn — phần lớn bị trễ so với deadline ban đầu.');
      }
    }

    // Việc còn quá hạn (chưa hoàn thành).
    if (report.overdueTasks > 0) {
      suggestions.add(
        'Có ${report.overdueTasks} nhiệm vụ đang quá hạn chưa hoàn thành, tập trung nhiều ở nhóm "${report.topCategory}".',
      );
    } else {
      suggestions.add('Không có nhiệm vụ nào đang quá hạn — tình trạng hiện tại đang được kiểm soát tốt.');
    }

    // Nhiệm vụ trễ nổi bật + độ trễ trung bình.
    if (report.topOverdueTitle != 'Không có' && report.topOverdueMinutes > 0) {
      suggestions.add(
        'Nhiệm vụ trễ/quá hạn nhiều nhất: "${report.topOverdueTitle}" (trễ ${_formatMinutes(report.topOverdueMinutes)}).',
      );
    }
    if (report.avgDelayMinutes > 0) {
      suggestions.add('Độ trễ trung bình của các việc bị trễ là ${_formatMinutes(report.avgDelayMinutes)}.');
    }

    // Phân tích theo độ ưu tiên — phát hiện hành vi né việc quan trọng.
    final highTotal = report.priorityCounts['high'] ?? 0;
    final lowTotal = report.priorityCounts['low'] ?? 0;
    final highDone = report.completedByPriority['high'] ?? 0;
    final lowDone = report.completedByPriority['low'] ?? 0;
    if (highTotal > 0) {
      final highPct = ((highDone / highTotal) * 100).round();
      final lowPct = lowTotal > 0 ? ((lowDone / lowTotal) * 100).round() : null;
      suggestions.add('Nhiệm vụ độ ưu tiên cao: hoàn thành $highDone/$highTotal ($highPct%).');
      if (lowPct != null && lowPct > highPct + 15) {
        suggestions.add(
          'Tỷ lệ hoàn thành việc ưu tiên thấp ($lowPct%) cao hơn việc ưu tiên cao ($highPct%) — dấu hiệu đang né tránh việc quan trọng để làm việc dễ trước.',
        );
      }
    }

    // Danh mục nổi bật theo số lượng và theo mức độ trễ.
    if (report.categoryCounts.length > 1) {
      final topShare = report.totalTasks > 0
          ? (((report.categoryCounts[report.topCategory] ?? 0) / report.totalTasks) * 100).round()
          : 0;
      suggestions.add('Danh mục "${report.topCategory}" chiếm $topShare% tổng số nhiệm vụ trong kỳ.');
    }
    final worstCategory = _worstCategoryByDelay(report.categoryStats);
    if (worstCategory != null) {
      suggestions.add(
        'Danh mục "${worstCategory.name}" có tổng thời gian trễ nhiều nhất (${_formatMinutes(worstCategory.overdueMinutes)} qua ${worstCategory.lateCount + worstCategory.overdueCount} việc).',
      );
    }

    // Điểm sáng để cân bằng góc nhìn, không chỉ toàn điểm cần cải thiện.
    if (report.earliestCompletionTitle != 'Không có' && report.earliestCompletionMinutes > 0) {
      suggestions.add(
        'Điểm sáng: "${report.earliestCompletionTitle}" được hoàn thành sớm ${_formatMinutes(report.earliestCompletionMinutes)} trước hạn.',
      );
    }

    return suggestions;
  }

  ReportCategoryStat? _worstCategoryByDelay(Map<String, ReportCategoryStat> stats) {
    ReportCategoryStat? worst;
    for (final stat in stats.values) {
      if (stat.overdueMinutes <= 0) continue;
      if (worst == null || stat.overdueMinutes > worst.overdueMinutes) {
        worst = stat;
      }
    }
    return worst;
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes phút';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return rem == 0 ? '$hours giờ' : '$hours giờ $rem phút';
  }

  /// Gọi AI (Gemini) để sinh lời khuyên hữu ích, cá nhân hoá theo đúng dữ
  /// liệu hiệu suất của người dùng trong khung thời gian đang xem. Dùng lại
  /// API key đã được cấu hình sẵn cho [legacy_ai.VoiceAiService] (đọc từ
  /// biến môi trường GOOGLE_API_KEY) để không phải cấu hình lại.
  /// Trả về null nếu chưa có API key hoặc lời gọi thất bại — khi đó UI sẽ
  /// tự dùng lời khuyên dự phòng từ [_buildFallbackAdvice].
  Future<String?> _generateAiAdvice(ReportViewModel report) async {
    final apiKey = legacy_ai.VoiceAiService.instance.apiKey.trim();
    if (apiKey.isEmpty) return null;
    if (report.totalTasks == 0) return null;

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Bạn là một huấn luyện viên năng suất (productivity coach) thân thiện, nói tiếng Việt. '
          'Trả lời ngắn gọn dưới dạng văn xuôi tự nhiên, KHÔNG dùng markdown, KHÔNG dùng dấu *, '
          'KHÔNG dùng emoji, vì câu trả lời sẽ được đọc to bằng giọng nói cho người dùng nghe.',
        ),
      );

      final response = await model
          .generateContent([Content.text(_buildAiPrompt(report))])
          .timeout(const Duration(seconds: 14));

      final text = response.text?.trim();
      if (text == null || text.isEmpty) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String _buildAiPrompt(ReportViewModel report) {
    final completionPct = report.totalTasks > 0
        ? ((report.completedTasks / report.totalTasks) * 100).round()
        : 0;
    final categorySummary = report.categoryCounts.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    final buffer = StringBuffer();
    buffer.writeln('Dưới đây là số liệu hiệu suất làm việc thực tế của người dùng trong một khoảng thời gian:');
    buffer.writeln('- Tổng số nhiệm vụ: ${report.totalTasks}');
    buffer.writeln('- Đã hoàn thành: ${report.completedTasks} ($completionPct%)');
    buffer.writeln('- Đang quá hạn (chưa làm): ${report.overdueTasks}');
    buffer.writeln('- Hoàn thành đúng hạn: ${report.onTimeCount}, hoàn thành trễ: ${report.lateCount}');
    buffer.writeln('- Độ trễ trung bình của việc trễ: ${report.avgDelayMinutes} phút');
    buffer.writeln(
      '- Theo độ ưu tiên (tổng/đã xong) — cao: ${report.priorityCounts['high'] ?? 0}/${report.completedByPriority['high'] ?? 0}, '
      'trung bình: ${report.priorityCounts['medium'] ?? 0}/${report.completedByPriority['medium'] ?? 0}, '
      'thấp: ${report.priorityCounts['low'] ?? 0}/${report.completedByPriority['low'] ?? 0}',
    );
    buffer.writeln('- Phân bổ theo danh mục: $categorySummary');
    buffer.writeln('- Danh mục nhiều nhiệm vụ nhất: ${report.topCategory}');
    if (report.topOverdueTitle != 'Không có') {
      buffer.writeln('- Việc trễ/quá hạn nổi bật nhất: "${report.topOverdueTitle}" (${report.topOverdueMinutes} phút)');
    }
    buffer.writeln();
    buffer.writeln(
      'Dựa đúng vào số liệu trên, hãy viết một đoạn ngắn (khoảng 80-120 từ) gồm: '
      '(1) một câu nhận định thẳng về xu hướng làm việc của người này trong giai đoạn này, '
      '(2) hai đến ba lời khuyên CỤ THỂ, có thể làm ngay, ưu tiên theo mức độ quan trọng, '
      'liên hệ trực tiếp tới số liệu (ví dụ nhắc đúng tên danh mục hay loại ưu tiên đang có vấn đề), '
      '(3) một câu động viên ngắn ở cuối. '
      'Viết liền mạch như đang nói chuyện trực tiếp với người dùng, xuống dòng giữa các ý để dễ đọc.',
    );
    return buffer.toString();
  }

  /// Lời khuyên dự phòng, được tính trực tiếp từ dữ liệu khi chưa có API key
  /// hoặc khi gọi AI thất bại — đảm bảo người dùng luôn nhận được gợi ý có
  /// ích, không bao giờ thấy màn hình trống hoặc lỗi.
  String _buildFallbackAdvice(ReportViewModel report) {
    if (report.totalTasks == 0) {
      return 'Hãy thêm nhiệm vụ đầu tiên cho khung thời gian này để bắt đầu theo dõi hiệu suất của bạn.';
    }

    final tips = <String>[];
    final completionPct = ((report.completedTasks / report.totalTasks) * 100).round();
    final highTotal = report.priorityCounts['high'] ?? 0;
    final highDone = report.completedByPriority['high'] ?? 0;
    final lowTotal = report.priorityCounts['low'] ?? 0;
    final lowDone = report.completedByPriority['low'] ?? 0;
    final highPct = highTotal > 0 ? ((highDone / highTotal) * 100).round() : null;
    final lowPct = lowTotal > 0 ? ((lowDone / lowTotal) * 100).round() : null;

    if (report.overdueTasks > 0) {
      tips.add(
        'Bạn đang có ${report.overdueTasks} việc quá hạn, tập trung ở nhóm "${report.topCategory}". '
        'Hãy dành 15-20 phút đầu ngày để xử lý dứt điểm nhóm này trước khi nhận thêm việc mới.',
      );
    }

    if (highPct != null && lowPct != null && lowPct > highPct + 15) {
      tips.add(
        'Việc ưu tiên thấp đang được hoàn thành nhiều hơn việc ưu tiên cao ($lowPct% so với $highPct%). '
        'Thử áp dụng nguyên tắc "ăn con ếch" — làm việc quan trọng nhất ngay khi bắt đầu ngày làm việc.',
      );
    }

    if (report.avgDelayMinutes >= 60) {
      tips.add(
        'Độ trễ trung bình hiện khá cao (${_formatMinutes(report.avgDelayMinutes)}). '
        'Hãy chia nhỏ các nhiệm vụ lớn thành từng bước 25-30 phút để dễ hoàn thành đúng hạn hơn.',
      );
    }

    if (tips.isEmpty) {
      if (completionPct >= 80) {
        tips.add(
          'Phong độ giai đoạn này rất tốt với $completionPct% hoàn thành. '
          'Hãy duy trì nhịp độ này và thử đặt thêm một mục tiêu thử thách hơn cho kỳ tới.',
        );
      } else {
        tips.add(
          'Hãy bắt đầu bằng việc lên danh sách 3 nhiệm vụ quan trọng nhất mỗi ngày và hoàn thành chúng trước, '
          'điều này giúp tăng đáng kể tỷ lệ hoàn thành theo thời gian.',
        );
      }
    }

    tips.add('Mỗi cải thiện nhỏ đều có giá trị — cứ kiên trì từng ngày, kết quả sẽ rõ rệt trong thời gian tới.');

    return tips.join(' ');
  }

  String _priorityKey(String raw) {
    if (raw.contains('cao') || raw.contains('high')) return 'high';
    if (raw.contains('thấp') || raw.contains('thap') || raw.contains('low')) return 'low';
    return 'medium';
  }

  String _reportDocId(String uid, DateTimeRange range) {
    return '${uid}_${range.start.millisecondsSinceEpoch}_${range.end.millisecondsSinceEpoch}';
  }
}
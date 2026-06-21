import 'package:flutter/material.dart';
import 'package:smart_app/ai/voice_ai_service.dart';
import 'package:smart_app/views/task_viewmodel.dart';

import 'diagram_analysis_service.dart';

class DiagramAnalysisSectionLoader extends StatefulWidget {
  final String uid;
  final DateTimeRange range;
  final String rangeLabel;
  final List<TaskViewModel> tasks;

  const DiagramAnalysisSectionLoader({
    super.key,
    required this.uid,
    required this.range,
    required this.rangeLabel,
    required this.tasks,
  });

  @override
  State<DiagramAnalysisSectionLoader> createState() => _DiagramAnalysisSectionLoaderState();
}

class _DiagramAnalysisSectionLoaderState extends State<DiagramAnalysisSectionLoader> {
  String? _cacheKey;
  Future<DiagramAnalysisResult>? _future;

  @override
  void initState() {
    super.initState();
    _refreshFuture();
  }

  @override
  void didUpdateWidget(covariant DiagramAnalysisSectionLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextKey = _buildKey(widget);
    if (nextKey != _cacheKey) {
      _refreshFuture();
    }
  }

  void _refreshFuture() {
    _cacheKey = _buildKey(widget);
    _future = DiagramAnalysisService.instance.buildAndStore(
      uid: widget.uid,
      range: widget.range,
      rangeLabel: widget.rangeLabel,
      tasks: widget.tasks,
    );
  }

  String _buildKey(DiagramAnalysisSectionLoader widget) {
    final taskSignature = widget.tasks
        .map(
          (task) =>
              '${task.title}|${task.stat}|${task.priority}|${task.category}|${task.dueAt?.millisecondsSinceEpoch ?? 0}|${task.completedAt?.millisecondsSinceEpoch ?? 0}',
        )
        .join(';');
    return '${widget.uid}|${widget.range.start.millisecondsSinceEpoch}|${widget.range.end.millisecondsSinceEpoch}|$taskSignature';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DiagramAnalysisResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AnalysisCard(
            title: 'Phân tích báo cáo',
            subtitle: widget.rangeLabel,
            spokenText: null,
            child: Text(
              'Không thể tạo phân tích: ${snapshot.error}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF93000A)),
            ),
          );
        }

        if (!snapshot.hasData) {
          return _AnalysisCard(
            title: 'Phân tích báo cáo',
            subtitle: widget.rangeLabel,
            spokenText: null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đang tạo phân tích cùng mốc thời gian với biểu đồ...',
                      style: TextStyle(fontSize: 13, color: Color(0xFF464554)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _DiagramAnalysisCard(result: snapshot.data!);
      },
    );
  }
}

class _DiagramAnalysisCard extends StatelessWidget {
  final DiagramAnalysisResult result;

  const _DiagramAnalysisCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final report = result.report;
    final completionPct = report.totalTasks > 0
        ? ((report.completedTasks / report.totalTasks) * 100).round()
        : 0;

    return _AnalysisCard(
      title: 'Phân tích báo cáo',
      subtitle: result.rangeLabel,
      spokenText: result.spokenSummary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(label: 'Tổng số', value: '${report.totalTasks}'),
              _MetricPill(label: 'Hoàn thành', value: '${report.completedTasks}'),
              _MetricPill(label: 'Quá hạn', value: '${report.overdueTasks}'),
              _MetricPill(label: 'Tỷ lệ', value: '$completionPct%'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Nhận định nhanh',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          ...result.suggestions.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•', style: TextStyle(color: Color(0xFF4648D4), fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF464554), height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _AdviceBlock(text: result.adviceText, isAi: result.adviceIsAi),
        ],
      ),
    );
  }
}

/// Khối lời khuyên — nổi bật rõ với phần "Nhận định nhanh" ở trên, có nhãn
/// "AI" khi nội dung thực sự do mô hình sinh ra (không gắn nhãn AI giả khi
/// đang dùng gợi ý dự phòng, để không đánh lừa người dùng).
class _AdviceBlock extends StatelessWidget {
  final String text;
  final bool isAi;

  const _AdviceBlock({required this.text, required this.isAi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAi ? const Color(0xFFF4F3FF) : const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAi ? const Color(0xFFDAD6FF) : const Color(0x1A767586),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAi ? Icons.auto_awesome_rounded : Icons.tips_and_updates_rounded,
                size: 16,
                color: isAi ? const Color(0xFF4648D4) : Colors.grey.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                isAi ? 'Lời khuyên từ AI' : 'Gợi ý cải thiện',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isAi ? const Color(0xFF4648D4) : Colors.grey.shade800,
                ),
              ),
              if (isAi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4648D4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF464554), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget child;

  /// Toàn bộ nội dung sẽ được đọc to khi bấm nút loa. Null khi chưa có dữ
  /// liệu để đọc (ví dụ đang tải hoặc bị lỗi) — khi đó nút loa sẽ bị ẩn.
  final String? spokenText;

  const _AnalysisCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.spokenText,
  });

  @override
  State<_AnalysisCard> createState() => _AnalysisCardState();
}

class _AnalysisCardState extends State<_AnalysisCard> {
  bool _isSpeaking = false;

  @override
  void dispose() {
    if (_isSpeaking) {
      VoiceAiService.instance.stopSpeaking();
    }
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    final text = widget.spokenText;
    if (text == null || text.trim().isEmpty) return;

    if (_isSpeaking) {
      await VoiceAiService.instance.stopSpeaking();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    // Đọc chậm hơn mức mặc định của app vì đây là đoạn phân tích dài, cần
    // nghe rõ — các luồng hội thoại ngắn khác (tạo nhiệm vụ, pomodoro...)
    // vẫn giữ tốc độ mặc định, không bị ảnh hưởng.
    await VoiceAiService.instance.speakText(text, speechRate: 0.32);
    if (mounted) setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasSpokenText = widget.spokenText != null && widget.spokenText!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1A767586)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF4648D4), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ),
              // Nút loa: cho người dùng nghe toàn bộ phân tích + lời khuyên
              // thay vì phải đọc, hữu ích khi đang bận tay hoặc không muốn
              // nhìn màn hình.
              if (hasSpokenText)
                _SpeakerButton(isSpeaking: _isSpeaking, onTap: _toggleSpeak),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF767586)),
          ),
          const SizedBox(height: 14),
          widget.child,
        ],
      ),
    );
  }
}

class _SpeakerButton extends StatelessWidget {
  final bool isSpeaking;
  final VoidCallback onTap;

  const _SpeakerButton({required this.isSpeaking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isSpeaking ? 'Dừng đọc' : 'Nghe phân tích này',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSpeaking ? const Color(0xFF4648D4) : const Color(0xFFF4F3FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
            size: 19,
            color: isSpeaking ? Colors.white : const Color(0xFF4648D4),
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF767586), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF191C1E)),
          ),
        ],
      ),
    );
  }
}
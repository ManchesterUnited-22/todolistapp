import 'package:flutter/material.dart';
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
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AnalysisCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191C1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF767586)),
          ),
          const SizedBox(height: 14),
          child,
        ],
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

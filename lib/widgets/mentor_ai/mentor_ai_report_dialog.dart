part of mentor_ai;

void _showReportDialog(BuildContext context, _ReportData data) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x1AC7C4D7))),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6063EE),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4648D4).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Báo cáo phân tích',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF191C1E), letterSpacing: -0.3),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('Phân bổ công việc'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: 64, height: 64, child: _DonutChart(total: data.totalTasks, work: data.categoryCounts['Công việc'] ?? 0, personal: data.categoryCounts['Cá nhân'] ?? 0, health: data.categoryCounts['Sức khỏe'] ?? 0)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem(color: const Color(0xFF64A8FE), label: 'Công việc', count: data.categoryCounts['Công việc'] ?? 0),
                              const SizedBox(height: 6),
                              _LegendItem(color: const Color(0xFF00885D), label: 'Cá nhân', count: data.categoryCounts['Cá nhân'] ?? 0),
                              const SizedBox(height: 6),
                              _LegendItem(color: const Color(0xFF4EDEA3), label: 'Sức khỏe', count: data.categoryCounts['Sức khỏe'] ?? 0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatCard(label: 'TỔNG SỐ', value: '${data.totalTasks}', bg: const Color(0xFFECEEF0), fg: const Color(0xFF4648D4)),
                        const SizedBox(width: 10),
                        _StatCard(label: 'XONG', value: '${data.completedTasks}', bg: const Color(0xFF6FFBBE), fg: const Color(0xFF002113)),
                        const SizedBox(width: 10),
                        _StatCard(label: 'TRỄ', value: '${data.overdueTasks}', bg: const Color(0xFFFFDAD6), fg: const Color(0xFF93000A)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 12),
                    _SectionHeader('Chi tiết báo cáo'),
                    const SizedBox(height: 8),
                    ListTile(title: const Text('Nhiệm vụ quá hạn nhiều nhất'), subtitle: Text(data.topOverdueTitle ?? 'Không có'), trailing: Text('${data.topOverdueMinutes ?? 0} phút')),
                    ListTile(title: const Text('Số nhiệm vụ chưa hoàn bị quá hạn'), trailing: Text('${data.incompleteOverdueCount ?? 0}')),
                    ListTile(title: const Text('Số nhiệm vụ hoàn trễ (tổng phút)'), subtitle: const Text('Số / Tổng phút'), trailing: Text('${data.completedLateCount ?? 0} / ${data.completedLateTotalMinutes ?? 0}')),
                    ListTile(title: const Text('Nhiệm vụ hoàn sớm nhất (phút trước hạn)'), subtitle: Text(data.earliestCompletionTitle ?? 'Không có'), trailing: Text('${data.earliestCompletionMinutes ?? 0}')),
                    const SizedBox(height: 12),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4648D4).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4648D4).withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF4648D4), size: 18),
                              SizedBox(width: 8),
                              Text('Gợi ý từ Serene AI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4648D4), letterSpacing: 0.1)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._buildSuggestions(data).map(
                            (text) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•', style: TextStyle(color: Color(0xFF4648D4), fontSize: 14, fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF464554), height: 1.45))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF4648D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: const Color(0xFF4648D4).withValues(alpha: 0.4),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đã hiểu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF464554), letterSpacing: 0.8),
  );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  const _LegendItem({required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF464554)))),
      Text('$count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1E))),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color fg;
  const _StatCard({required this.label, required this.value, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: fg)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF464554), letterSpacing: 0.5), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _DonutChart extends StatelessWidget {
  final int total;
  final int work;
  final int personal;
  final int health;
  const _DonutChart({required this.total, required this.work, required this.personal, required this.health});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(64, 64),
          painter: _DonutPainter(
            segments: total > 0
                ? [
                    _DonutSegment(work / total, const Color(0xFF64A8FE)),
                    _DonutSegment(personal / total, const Color(0xFF00885D)),
                    _DonutSegment(health / total, const Color(0xFF4EDEA3)),
                  ]
                : [_DonutSegment(1.0, const Color(0xFFECEEF0))],
          ),
        ),
        Text('$total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1E))),
      ],
    );
  }
}

class _DonutSegment {
  final double fraction;
  final Color color;
  const _DonutSegment(this.fraction, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    var startAngle = -3.14159 / 2;
    const strokeW = 7.0;
    for (final seg in segments) {
      final sweepAngle = 2 * 3.14159 * seg.fraction;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - 0.04,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
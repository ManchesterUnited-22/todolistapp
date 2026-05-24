part of mentor_ai;

void _showReportDialog(BuildContext context, _ReportData data) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) {
      final isPhone = ResponsiveLayout.isPhone(ctx);
      final maxDialogHeight = ResponsiveLayout.dialogMaxHeight(ctx);

      return ResponsiveLayout.adaptiveDialog(
        ctx,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isPhone ? 20 : 28),
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
                padding: EdgeInsets.all(isPhone ? 16 : 24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x1AC7C4D7))),
                ),
                child: Column(
                  children: [
                    Container(
                      width: isPhone ? 52 : 64,
                      height: isPhone ? 52 : 64,
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
                      child: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: isPhone ? 26 : 32,
                      ),
                    ),
                    SizedBox(height: isPhone ? 12 : 16),
                    Text(
                      'Báo cáo phân tích',
                      style: TextStyle(
                        fontSize: ResponsiveLayout.adaptiveFont(ctx, 22, min: 18, max: 26),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191C1E),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxDialogHeight * 0.62),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isPhone ? 14 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Phân bổ công việc'),
                      const SizedBox(height: 12),
                      isPhone
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: _DonutChart(
                                      total: data.totalTasks,
                                      work: data.categoryCounts['Công việc'] ?? 0,
                                      personal: data.categoryCounts['Cá nhân'] ?? 0,
                                      health: data.categoryCounts['Sức khỏe'] ?? 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LegendItem(color: const Color(0xFF64A8FE), label: 'Công việc', count: data.categoryCounts['Công việc'] ?? 0),
                                const SizedBox(height: 6),
                                _LegendItem(color: const Color(0xFF00885D), label: 'Cá nhân', count: data.categoryCounts['Cá nhân'] ?? 0),
                                const SizedBox(height: 6),
                                _LegendItem(color: const Color(0xFF4EDEA3), label: 'Sức khỏe', count: data.categoryCounts['Sức khỏe'] ?? 0),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: _DonutChart(
                                    total: data.totalTasks,
                                    work: data.categoryCounts['Công việc'] ?? 0,
                                    personal: data.categoryCounts['Cá nhân'] ?? 0,
                                    health: data.categoryCounts['Sức khỏe'] ?? 0,
                                  ),
                                ),
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
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: isPhone ? (MediaQuery.sizeOf(ctx).width * 0.35) : 140,
                            child: _StatCard(label: 'TỔNG SỐ', value: '${data.totalTasks}', bg: const Color(0xFFECEEF0), fg: const Color(0xFF4648D4)),
                          ),
                          SizedBox(
                            width: isPhone ? (MediaQuery.sizeOf(ctx).width * 0.35) : 140,
                            child: _StatCard(label: 'XONG', value: '${data.completedTasks}', bg: const Color(0xFF6FFBBE), fg: const Color(0xFF002113)),
                          ),
                          SizedBox(
                            width: isPhone ? (MediaQuery.sizeOf(ctx).width * 0.35) : 140,
                            child: _StatCard(label: 'TRỄ', value: '${data.overdueTasks}', bg: const Color(0xFFFFDAD6), fg: const Color(0xFF93000A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 12),
                      _SectionHeader('Chi tiết báo cáo'),
                      const SizedBox(height: 8),
                      _ReportMetricTile(
                        title: 'Nhiệm vụ quá hạn nhiều nhất',
                        subtitle: data.topOverdueTitle ?? 'Không có',
                        value: '${data.topOverdueMinutes ?? 0} phút',
                      ),
                      _ReportMetricTile(
                        title: 'Số nhiệm vụ chưa hoàn bị quá hạn',
                        value: '${data.incompleteOverdueCount ?? 0}',
                      ),
                      _ReportMetricTile(
                        title: 'Số nhiệm vụ hoàn trễ (tổng phút)',
                        subtitle: 'Số / Tổng phút',
                        value: '${data.completedLateCount ?? 0} / ${data.completedLateTotalMinutes ?? 0}',
                      ),
                      _ReportMetricTile(
                        title: 'Nhiệm vụ hoàn sớm nhất (phút trước hạn)',
                        subtitle: data.earliestCompletionTitle ?? 'Không có',
                        value: '${data.earliestCompletionMinutes ?? 0}',
                      ),
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
                                Expanded(
                                  child: Text(
                                    'Gợi ý từ Serene AI',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4648D4), letterSpacing: 0.1),
                                  ),
                                ),
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
                padding: EdgeInsets.fromLTRB(isPhone ? 14 : 20, 8, isPhone ? 14 : 20, isPhone ? 14 : 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFF4648D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: const Color(0xFF4648D4).withValues(alpha: 0.4),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Đã hiểu',
                    style: TextStyle(
                      fontSize: ResponsiveLayout.adaptiveFont(ctx, 17, min: 14, max: 18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
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
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: fg)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF464554), letterSpacing: 0.5), textAlign: TextAlign.center),
        ],
      ),
    );
}

class _ReportMetricTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;

  const _ReportMetricTile({
    required this.title,
    this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = ResponsiveLayout.isPhone(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF767586))),
                ],
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1E))),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF767586))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1E))),
              ],
            ),
    );
  }
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
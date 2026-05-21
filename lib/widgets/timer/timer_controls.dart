part of timer_widget;

Widget buildTimerDurationRow(_TimerCardState state) {
  return Row(
    children: [
      Expanded(
        child: _InfoBox(
          label: 'Làm task',
          value: '${state._focusMinutes} phút',
          color: const Color(0xFF4648D4),
          onEdit: () => state._updateDuration(editFocus: true),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _InfoBox(
          label: 'Giải lao',
          value: '${state._breakMinutes} phút',
          color: const Color(0xFF0060AC),
          onEdit: () => state._updateDuration(editFocus: false),
        ),
      ),
    ],
  );
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onEdit;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_rounded, size: 16, color: color),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 24, height: 24),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
part of task_notification_bell;

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString().padLeft(4, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/$year • $hour:$minute';
}

Future<void> showTaskNotificationsSheet(
  BuildContext context, {
  required Color badgeColor,
  required List<_NotificationEntry> urgentEntries,
  required List<_NotificationEntry> completionEntries,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: badgeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông báo nhiệm vụ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                            (urgentEntries.isEmpty && completionEntries.isEmpty)
                              ? 'Không có thông báo mới.'
                              : '${urgentEntries.length + completionEntries.length} thông báo mới',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (urgentEntries.isEmpty && completionEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Hiện tại chưa có task quá hạn, sắp đến hạn, hoặc task nào vừa hoàn thành gần đây.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: (urgentEntries.isNotEmpty ? 1 : 0) +
                        (completionEntries.isNotEmpty ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (urgentEntries.isNotEmpty && index == 0) {
                        return _buildNotificationGroup(
                          title: 'Nhắc việc cần xử lý',
                          subtitle:
                              '${urgentEntries.length} nhiệm vụ đang cần bạn chú ý',
                          accentColor: AppColors.high,
                          entries: urgentEntries,
                          isCompletedGroup: false,
                        );
                      }

                      return _buildNotificationGroup(
                        title: 'Vừa hoàn thành',
                        subtitle:
                            '${completionEntries.length} nhiệm vụ đã được hoàn tất gần đây',
                        accentColor: AppColors.tertiary,
                        entries: completionEntries,
                        isCompletedGroup: true,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildNotificationGroup({
  required String title,
  required String subtitle,
  required Color accentColor,
  required List<_NotificationEntry> entries,
  required bool isCompletedGroup,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: accentColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accentColor.withValues(alpha: 0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompletedGroup ? Icons.celebration_rounded : Icons.notifications_active_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildNotificationRow(
              entry: entry,
              isCompletedGroup: isCompletedGroup,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildNotificationRow({
  required _NotificationEntry entry,
  required bool isCompletedGroup,
}) {
  final accentColor = isCompletedGroup
      ? AppColors.tertiary
      : (entry.overdue ? AppColors.high : AppColors.medium);
  final icon = isCompletedGroup
      ? Icons.verified_rounded
      : (entry.overdue ? Icons.warning_rounded : Icons.schedule_rounded);
  final headline = isCompletedGroup
      ? 'Bạn vừa hoàn thành một nhiệm vụ'
      : (entry.overdue ? 'Task quá hạn' : 'Task sắp đến hạn');
  final detail = isCompletedGroup
      ? 'Hoàn tất lúc ${_formatDateTime(entry.timestamp)}'
      : (entry.overdue
          ? 'Đã quá hạn từ ${_formatDateTime(entry.timestamp)}'
          : 'Cần xử lý trước ${_formatDateTime(entry.timestamp)}');

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accentColor.withValues(alpha: 0.14)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NotificationEntry {
  final String taskId;
  final String title;
  final DateTime timestamp;
  final bool overdue;
  final _NotificationKind kind;

  const _NotificationEntry({
    required this.taskId,
    required this.title,
    required this.timestamp,
    required this.overdue,
    required this.kind,
  });
}

enum _NotificationKind {
  urgentOverdue,
  dueSoon,
  completed,
}
part of sidebar;

Widget _buildNavListContent(
  DashboardSidebar sidebar,
  BuildContext context,
  Map<String, int> counts,
) {
  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    children: [
      const _SidebarSectionLabel('DANH MỤC CHÍNH'),
      _SidebarNavItem(
        icon: Icons.task_alt,
        label: 'Tất cả công việc',
        active: sidebar.currentPage == 'dashboard',
        onTap: sidebar.onDashboardTap ?? () => sidebar.onTagSelected?.call(null),
      ),
      _SidebarNavItem(
        icon: Icons.calendar_month_outlined,
        label: 'Lịch',
        active: sidebar.currentPage == 'calendar',
        onTap: sidebar.onCalendarTap ?? () => Navigator.of(context).pushNamed('/calendar'),
      ),
      _SidebarNavItem(
        icon: Icons.leaderboard_outlined,
        label: 'Thống kê',
        active: sidebar.currentPage == 'stats',
        onTap: sidebar.onChartsTap ?? () => Navigator.of(context).pushNamed('/stats'),
      ),
      const SizedBox(height: 8),
      const _SidebarSectionLabel('NHÃN DÁN'),
      _SidebarTagItem(
        color: _C.secondary,
        label: 'Công việc',
        count: '${counts['Công việc'] ?? 0}',
        selected: sidebar.selectedTag == 'Công việc',
        onTap: () => sidebar.onTagSelected?.call('Công việc'),
      ),
      _SidebarTagItem(
        color: _C.primaryContainer,
        label: 'Cá nhân',
        count: '${counts['Cá nhân'] ?? 0}',
        selected: sidebar.selectedTag == 'Cá nhân',
        onTap: () => sidebar.onTagSelected?.call('Cá nhân'),
      ),
      _SidebarTagItem(
        color: _C.error,
        label: 'Sức khỏe',
        count: '${counts['Sức khỏe'] ?? 0}',
        selected: sidebar.selectedTag == 'Sức khỏe',
        onTap: () => sidebar.onTagSelected?.call('Sức khỏe'),
      ),
      _SidebarTagItem(
        color: _C.outline,
        label: 'Tất cả',
        count: '${counts.values.fold<int>(0, (sum, value) => sum + value)}',
        selected: sidebar.selectedTag == null,
        onTap: () => sidebar.onTagSelected?.call(null),
      ),
      const SizedBox(height: 8),
      const _SidebarSectionLabel('TÍNH NĂNG'),
      const _TaskNotificationToggle(),
    ],
  );
}

Map<String, int> _groupTaskCounts(Iterable<QueryDocumentSnapshot> docs) {
  final counts = <String, int>{'Công việc': 0, 'Cá nhân': 0, 'Sức khỏe': 0};

  for (final doc in docs) {
    final data = doc.data() as Map<String, dynamic>?;
    final category = (data?['category'] as String?)?.trim();
    if (category == null || category.isEmpty) {
      continue;
    }

    if (counts.containsKey(category)) {
      counts[category] = counts[category]! + 1;
    }
  }

  return counts;
}

class _TaskNotificationToggle extends StatefulWidget {
  const _TaskNotificationToggle();

  @override
  State<_TaskNotificationToggle> createState() => _TaskNotificationToggleState();
}

class _TaskNotificationToggleState extends State<_TaskNotificationToggle> {
  bool _enabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _syncState();
  }

  Future<void> _syncState() async {
    await TaskNotificationService.instance.initialize();
    if (!mounted) return;
    setState(() {
      _enabled = TaskNotificationService.instance.notificationsEnabled;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool value) async {
    setState(() {
      _enabled = value;
      _loading = true;
    });

    await TaskNotificationService.instance.setNotificationsEnabled(value);
    if (!value) {
      await TaskNotificationService.instance.clearAllNotifications();
    }

    if (!mounted) return;
    setState(() {
      _enabled = value;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : () => _setEnabled(!_enabled),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _enabled
              ? _C.error.withValues(alpha: 0.05)
              : _C.surfaceContainerHigh.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _enabled
                ? _C.error.withValues(alpha: 0.12)
                : _C.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: _enabled ? _C.error : _C.outline,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Thông báo task',
                style: TextStyle(
                  color: _C.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _loading ? 0.5 : 1,
              child: Switch.adaptive(
                value: _enabled,
                activeColor: _C.error,
                onChanged: _loading ? null : _setEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  final String text;
  const _SidebarSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      text,
      style: const TextStyle(
        color: _C.outline,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? textColor;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? (active ? _C.primary : _C.onSurfaceVariant);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: active ? _C.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: onTap ?? () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: _C.primary.withValues(alpha: 0.05),
      ),
    );
  }
}

class _SidebarTagItem extends StatelessWidget {
  final Color color;
  final String label;
  final String count;
  final bool selected;
  final VoidCallback? onTap;
  const _SidebarTagItem({
    required this.color,
    required this.label,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 1),
    child: ListTile(
      dense: true,
      leading: _TagIcon(label: label, color: color, selected: selected),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? _C.primary : _C.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Text(
        count,
        style: TextStyle(
          color: selected ? _C.primary : _C.outline,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: _C.primary.withValues(alpha: 0.08),
      hoverColor: _C.surfaceContainerHigh,
    ),
  );
}

class _TagIcon extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;

  const _TagIcon({
    required this.label,
    required this.color,
    required this.selected,
  });

  IconData _iconForLabel() {
    switch (label) {
      case 'Công việc':
        return Icons.work_rounded;
      case 'Cá nhân':
        return Icons.person_rounded;
      case 'Sức khỏe':
        return Icons.favorite_rounded;
      case 'Tất cả':
        return Icons.list_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconForLabel(),
      size: 18,
      color: selected ? _C.primary : color,
    );
  }
}
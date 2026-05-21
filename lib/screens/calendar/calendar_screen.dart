import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/floating_bottom_navbar.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/task_notification_bell.dart';
import 'calendar_colors.dart';
import 'calendar_card.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_task_section.dart';

class CalendarScreen extends StatefulWidget {
  final bool showBottomNav;

  const CalendarScreen({super.key, this.showBottomNav = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = DateTime.now().day;
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  String get _currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: CalendarColors.surface.withValues(alpha: 0.80),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: CalendarColors.outlineVariant.withValues(alpha: 0.30)),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: CalendarColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'Serene Focus',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: CalendarColors.primary, letterSpacing: -0.5),
      ),
      actions: [
        TaskNotificationBellButton(userId: _currentUserUid, iconColor: CalendarColors.primary, badgeColor: CalendarColors.error),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CalendarColors.background,
      drawer: Drawer(
        width: 280,
        child: SafeArea(
          child: DashboardSidebar(
            currentPage: 'calendar',
            userName: 'User Name',
            onDashboardTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/dashboard');
            },
            onCalendarTap: () => Navigator.of(context).pop(),
            onChartsTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/stats');
            },
            onEditProfile: () => Navigator.of(context).pushNamed('/profile'),
            onLanguage: () => Navigator.of(context).pushNamed('/language'),
          ),
        ),
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                CalendarHeader(
                  displayedMonth: _displayedMonth,
                  onToday: () => setState(() {
                    final now = DateTime.now();
                    _displayedMonth = DateTime(now.year, now.month);
                    _selectedDay = now.day;
                  }),
                ),
                const SizedBox(height: 32),
                CalendarCard(
                  selectedDay: _selectedDay,
                  displayedMonth: _displayedMonth,
                  onDaySelected: (d) => setState(() => _selectedDay = d),
                  onPrevMonth: () => setState(() {
                    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                    final daysInPrev = DateTime(prev.year, prev.month + 1, 0).day;
                    _displayedMonth = prev;
                    if (_selectedDay > daysInPrev) _selectedDay = daysInPrev;
                  }),
                  onNextMonth: () => setState(() {
                    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                    final daysInNext = DateTime(next.year, next.month + 1, 0).day;
                    _displayedMonth = next;
                    if (_selectedDay > daysInNext) _selectedDay = daysInNext;
                  }),
                ),
                const SizedBox(height: 32),
                CalendarTaskSection(selectedDay: _selectedDay, displayedMonth: _displayedMonth),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav ? const FloatingBottomNavBar(currentIndex: 1, showFab: false) : null,
    );
  }
}

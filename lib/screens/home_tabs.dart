import 'package:flutter/material.dart';
import 'main_dashboard_screen.dart';
import 'calendar_screen.dart';
import 'charts_screen.dart';
import 'profile_screen.dart';
import '../widgets/floating_bottom_navbar.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  late final PageController _pc = PageController(initialPage: 0);
  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    try {
      // Do not dispose controller if other parts rely on it; but safe to dispose here
      _pc.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onTap(int idx) {
    setState(() => _current = idx);
    _pc.animateToPage(
      idx,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pc,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _current = i),
        children: const [
          MainDashboardScreen(showBottomNav: false),
          ChartsScreen(showBottomNav: false),
          CalendarScreen(showBottomNav: false),
          ProfileScreen(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _current,
        onTap: _onTap,
        showFab: _current == 0 ? false : false, // Luôn ẩn FAB ở mọi tab (nếu muốn chỉ hiện ở tab khác, đổi điều kiện)
      ),
    );
  }
}

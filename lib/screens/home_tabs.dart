// lib/screens/home_tabs.dart
import 'package:flutter/material.dart';
import 'package:smart_app/widgets/floating_bottom_navbar.dart';

import 'ai_home_screen.dart';
import 'calendar_screen.dart';
import 'achievements_screen.dart';
import '../screens/charts/insights_screen.dart'; // Insights
import 'profile_screen.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AiHomeScreen(),           // 0: AI Assistant - Trung tâm
    CalendarScreen(),         // 1: Timeline
    AchievementsScreen(),     // 2: Goals
    InsightsScreen(),         // 3: Insights
    ProfileScreen(),          // 4: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
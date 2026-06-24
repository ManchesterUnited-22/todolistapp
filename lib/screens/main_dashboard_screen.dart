import 'package:flutter/material.dart';
import 'ai_home_screen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chuyển hướng thẳng sang AI Home mới
    return const AiHomeScreen();
  }
}
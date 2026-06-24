// lib/screens/achievements_screen.dart
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Goals",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Mục tiêu dài hạn của bạn",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Big Goal Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF8B5CF6),
                      child: Text("🎯", style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hoàn thành 3 dự án lớn năm 2026",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF8B5CF6),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    const Text("45% hoàn thành", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                "Mục tiêu đang theo dõi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              _buildGoalItem("Học Flutter & Dart", "Hoàn thành 80%", 0.8, Colors.indigo),
              const SizedBox(height: 12),
              _buildGoalItem("Chạy bộ 500km/năm", "Hoàn thành 35%", 0.35, Colors.teal),
              const SizedBox(height: 12),
              _buildGoalItem("Đọc 30 cuốn sách", "Hoàn thành 60%", 0.6, Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(String title, String progressText, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 8),
                Text(progressText, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
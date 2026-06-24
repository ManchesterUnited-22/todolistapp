// lib/screens/charts/insights_screen.dart
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
                "Insights",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "AI Coach đang phân tích cho bạn",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // AI Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF22D3EE)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 32),
                    SizedBox(height: 16),
                    Text(
                      "Tuần này bạn làm rất tốt!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Bạn đã hoàn thành 87% nhiệm vụ. Tập trung cao nhất vào buổi sáng.",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats Row
              Row(
                children: [
                  _buildStatCard("Hoàn thành", "24", "nhiệm vụ", Colors.indigo),
                  const SizedBox(width: 16),
                  _buildStatCard("Tập trung", "92%", "trung bình", Colors.teal),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatCard("Streak", "7", "ngày", Colors.orange),
                  const SizedBox(width: 16),
                  _buildStatCard("Hiệu suất", "+12%", "so với tuần trước", Colors.purple),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Gợi ý từ AI Coach",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              _buildSuggestionCard(
                icon: Icons.lightbulb,
                title: "Nên bắt đầu ngày bằng Deep Work",
                subtitle: "Bạn làm việc hiệu quả nhất từ 7-9h sáng",
              ),
              const SizedBox(height: 12),
              _buildSuggestionCard(
                icon: Icons.restaurant,
                title: "Nghỉ ngơi sau 90 phút làm việc",
                subtitle: "Giúp não bộ phục hồi và tăng năng suất",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(unit, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({required IconData icon, required String title, required String subtitle}) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
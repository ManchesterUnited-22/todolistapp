// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF6366F1),
                      child: Icon(Icons.person, size: 70, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF14B8A6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Alex Nguyen",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Level 12 • AI Companion",
                style: TextStyle(fontSize: 16, color: Color(0xFF14B8A6)),
              ),
              const SizedBox(height: 40),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat("42", "Ngày streak"),
                  _buildStat("187", "Nhiệm vụ"),
                  _buildStat("94%", "Hiệu suất"),
                ],
              ),

              const SizedBox(height: 40),

              // Menu Items
              _buildMenuItem(Icons.settings, "Cài đặt AI Assistant"),
              _buildMenuItem(Icons.notifications, "Thông báo"),
              _buildMenuItem(Icons.history, "Lịch sử trò chuyện"),
              _buildMenuItem(Icons.bar_chart, "Báo cáo chi tiết"),
              _buildMenuItem(Icons.help_outline, "Hỗ trợ & Feedback"),

              const SizedBox(height: 40),

              // Logout Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Center(
                  child: Text(
                    "Đăng xuất",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Icon(icon, color: const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
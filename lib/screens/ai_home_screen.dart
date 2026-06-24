// lib/screens/ai_home_screen.dart
import 'package:flutter/material.dart';

class AiHomeScreen extends StatefulWidget {
  const AiHomeScreen({super.key});

  @override
  State<AiHomeScreen> createState() => _AiHomeScreenState();
}

class _AiHomeScreenState extends State<AiHomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Chào buổi sáng,", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text("Alex", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF6366F1),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // AI Orb with Pulse Animation
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_pulseController.value * 0.08),
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.5),
                            blurRadius: 60 + (_pulseController.value * 20),
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text("✦", style: TextStyle(fontSize: 120, color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Trợ lý AI cá nhân",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            const Text(
              "Tôi có thể giúp gì cho bạn hôm nay?",
              style: TextStyle(fontSize: 17, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Large Mic Button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🎤 Đang lắng nghe... (Voice AI)")),
                );
              },
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF22D3EE)]),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.6), blurRadius: 40, spreadRadius: 12),
                  ],
                ),
                child: const Icon(Icons.mic_rounded, size: 65, color: Colors.white),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Suggestions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text("Gợi ý nhanh", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildQuickChip("Hôm nay tôi nên làm gì?"),
                  _buildQuickChip("Thêm nhiệm vụ học tập"),
                  _buildQuickChip("Xem tiến độ tuần này"),
                  _buildQuickChip("Đánh giá năng suất"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chat Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn cho AI...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF6366F1)),
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("📨 ${_messageController.text}")),
                          );
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã gửi: $text")));
        },
        child: Chip(
          label: Text(text),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF6366F1), width: 1),
        ),
      ),
    );
  }
}
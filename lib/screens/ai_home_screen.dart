// lib/screens/ai_home_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_app/ai/services/chat_ai_service.dart';

class AiHomeScreen extends StatefulWidget {
  const AiHomeScreen({super.key});

  @override
  State<AiHomeScreen> createState() => _AiHomeScreenState();
}

class _AiHomeScreenState extends State<AiHomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatAiService _aiService = ChatAiService.instance;
  int _selectedTab = 0; // 0 = Chat, 1 = Tasks
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeGreeting();
  }

  Future<void> _initializeGreeting() async {
    final greeting = await _aiService.generateGreeting();
    setState(() {
      _messages.add({'sender': 'ai', 'text': greeting});
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final response = await _aiService.sendMessage(text);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'ai', 'text': response});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'text': 'Xin lỗi, có lỗi xảy ra. Vui lòng thử lại sau.',
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header with TaskAI and tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TaskAI Title
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5059E8), Color(0xFF49A8F8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'TaskAI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5059E8).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'X bị hỏng tuổi sáng',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0B5FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Row(
                    children: [
                      _buildTab('Chat', 0),
                      const SizedBox(width: 12),
                      _buildTab('Tasks', 1),
                    ],
                  ),
                ],
              ),
            ),

            // Chat messages area
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _messages.length; i++)
                      _buildMessage(_messages[i], i == _messages.length - 1),
                  ],
                ),
              ),
            ),

            // Quick action chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionChip(
                      'Kĩ hoạch tuổi sáng',
                      Icons.sunny,
                      const Color(0xFFFFA500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionChip(
                      'Công việc hôm nay',
                      Icons.task_alt,
                      const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2B42),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF3A3B52),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isLoading,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nhắn yêu cầu của bạn...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  color: Color(0xFF6366F1), size: 22),
                              onPressed: _sendMessage,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg, bool isLast) {
    final isAI = msg['sender'] == 'ai';
    return Column(
      crossAxisAlignment:
          isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: isLast ? 0 : 12,
            left: isAI ? 0 : 40,
            right: isAI ? 40 : 0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isAI
                ? const Color(0xFF2A2B42)
                : const Color(0xFF6366F1).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAI
                  ? const Color(0xFF3A3B52)
                  : const Color(0xFF6366F1).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            msg['text'],
            style: TextStyle(
              color: isAI ? Colors.white : Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📌 $label'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2B42),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF3A3B52),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
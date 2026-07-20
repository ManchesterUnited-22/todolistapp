import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../voice_ai_service.dart' as legacy_ai;

class ChatAiService {
  static final ChatAiService _instance = ChatAiService._();
  late String _apiKey;

  ChatAiService._() {
    // Try to get API key from .env, fallback to compile-time or legacy service
    _apiKey = dotenv.env['GOOGLE_API_KEY'] ?? 
              const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '') ??
              legacy_ai.VoiceAiService.instance.apiKey;
  }

  static ChatAiService get instance => _instance;

  /// Set API key at runtime
  void setApiKey(String key) {
    _apiKey = key.trim();
  }

  /// Send a user message and get AI response via Gemini
  /// 
  /// Follows the standard 4-part prompt structure:
  /// 1. Role: AI as personal productivity assistant
  /// 2. Data: User message + optional context
  /// 3. Task: Generate helpful, actionable response
  /// 4. Output: Natural Vietnamese text
  Future<String> sendMessage(
    String userMessage, {
    String? contextTasks,
    String? recentActivity,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return 'API chưa được cấu hình. Hãy thêm GOOGLE_API_KEY vào .env hoặc gọi setApiKey().';
      }

      final prompt = _buildChatPrompt(
        userMessage: userMessage,
        contextTasks: contextTasks,
        recentActivity: recentActivity,
      );

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'Bạn là trợ lý năng suất cá nhân, nói tiếng Việt.'
          'Hãy trả lời ngắn gọn, thân thiện, và đưa ra lời khuyên cụ thể có thể thực hiện ngay.'
          'Tránh hứa quá lớn hoặc tạo áp lực. Tập trung vào giải pháp khả thi.',
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      return text?.isNotEmpty == true
          ? text!
          : 'Tôi chưa có câu trả lời phù hợp. Hãy thử lại sau.';
    } catch (e) {
      return 'Có lỗi xảy ra: $e. Vui lòng thử lại.';
    }
  }

  /// Build chat prompt following 4-part structure
  String _buildChatPrompt({
    required String userMessage,
    String? contextTasks,
    String? recentActivity,
  }) {
    final buffer = StringBuffer();

    // Part 1: Role
    buffer.writeln('Bạn là trợ lý năng suất cá nhân.');
    buffer.writeln('');

    // Part 2: Data
    buffer.writeln('Thông tin người dùng:');
    buffer.writeln('- Tin nhắn vừa gửi: "$userMessage"');
    if (contextTasks != null && contextTasks.isNotEmpty) {
      buffer.writeln('- Công việc còn lại hôm nay: $contextTasks');
    }
    if (recentActivity != null && recentActivity.isNotEmpty) {
      buffer.writeln('- Hoạt động gần đây: $recentActivity');
    }
    buffer.writeln('');

    // Part 3: Task
    buffer.writeln('Hãy:');
    buffer.writeln('1) Hiểu rõ ý của họ');
    buffer.writeln('2) Đề xuất 1-2 bước cụ thể & khả thi (không hứa quá lớn)');
    buffer.writeln('3) Tạo sự tích cực & động viên nếu cần');
    buffer.writeln('');

    // Part 4: Output Format
    buffer.writeln('Định dạng đầu ra:');
    buffer.writeln('- Trả lời bằng tiếng Việt');
    buffer.writeln('- Ngắn gọn (dưới 150 từ)');
    buffer.writeln('- Thân thiện & thực tế');

    return buffer.toString();
  }

  /// Generate greeting message when user opens chat
  Future<String> generateGreeting({String? userName}) async {
    final message = userName != null && userName.isNotEmpty
        ? 'Xin chào $userName! Tôi là TaskAI, trợ lý năng suất cá nhân của bạn. Bạn cần tôi giúp gì hôm nay?'
        : 'Xin chào! Tôi là TaskAI – trợ lý thông minh giúp bạn quản lý công việc hiệu quả. Hãy nói với tôi những gì bạn cần làm hoặc hỏi tôi để được gợi ý!';
    return message;
  }
}

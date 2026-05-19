import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../ai/ai_services.dart' as legacy_ai;

class AiService {
  AiService._();

  static String? _apiKey;

  /// Set the API key for the LLM provider (OpenAI style key). Do NOT commit keys to source control.
  static void setApiKey(String key) {
    _apiKey = key.trim();
  }

  static bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Build a human-friendly prompt to send to an LLM for analysis.
  /// The prompt describes user's task statistics and requests insights.
  static String buildAnalysisPrompt({
    required int totalTasks,
    required int completedTasks,
    required int overdueTasks,
    required int onTimeCount,
    required int lateCount,
    required int highPriority,
    required int mediumPriority,
    required int lowPriority,
    required int highCompleted,
    required int mediumCompleted,
    required int lowCompleted,
    required Map<String, int> categoryCounts,
    required String topCategory,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Bạn là một chuyên gia huấn luyện năng suất (productivity coach) nói tiếng Việt.',
    );
    buffer.writeln('Dựa trên số liệu nhiệm vụ dưới đây, hãy cung cấp:');
    buffer.writeln(
      'A) Một nhận định ngắn (1-2 câu) theo phong cách "nhân cách" mô tả xu hướng hành vi của người dùng.',
    );
    buffer.writeln(
      'B) Nếu thấy loại nhiệm vụ nào đang bị bỏ ưu tiên (ví dụ: "Cá nhân" rất thấp so với "Công việc"), hãy nêu bạn nghĩ người dùng thuộc kiểu tính cách nào (ví dụ: "ưu tiên công việc quá mức", "thiếu cân bằng"), và mô tả tác động có thể tới lối sống của họ (sức khỏe, mối quan hệ, stress, v.v.).',
    );
    buffer.writeln(
      'C) Đưa ra 3 đề xuất cải thiện cụ thể, theo thứ tự ưu tiên — mỗi đề xuất kèm bước hành động dễ thực hiện (bullet points).',
    );
    buffer.writeln('D) Một đoạn kết động viên ngắn (1 đoạn).');
    buffer.writeln();
    buffer.writeln('Dữ liệu (Data):');
    buffer.writeln('- totalTasks: $totalTasks');
    buffer.writeln('- completedTasks: $completedTasks');
    buffer.writeln('- overdueTasks: $overdueTasks');
    buffer.writeln('- onTimeCount: $onTimeCount');
    buffer.writeln('- lateCount: $lateCount');
    buffer.writeln(
      '- priority totals (high/medium/low): $highPriority / $mediumPriority / $lowPriority',
    );
    buffer.writeln(
      '- completed by priority (high/medium/low): $highCompleted / $mediumCompleted / $lowCompleted',
    );
    buffer.writeln(
      '- category counts: ${categoryCounts.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
    );
    buffer.writeln('- topCategory: $topCategory');
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('Ghi chú:');
    buffer.writeln('- Viết bằng tiếng Việt, ngắn gọn, thân thiện.');
    buffer.writeln(
      '- Sử dụng bullet cho phần đề xuất, mỗi mục có 1-2 bước cụ thể.',
    );
    buffer.writeln('- Tránh thuật ngữ chuyên môn khó hiểu.');

    return buffer.toString();
  }

  /// Placeholder runner that returns the prompt for now.
  /// Replace this with a real LLM call when API keys and integration are available.
  static Future<String> runAnalysisPrompt(String prompt) async {
    // If not explicitly configured with an OpenAI key, try to reuse the legacy in-repo key
    if (!isConfigured) {
      try {
        final legacyKey = legacy_ai.AIService.instance.apiKey;
        if (legacyKey.isNotEmpty) {
          // If it's an OpenAI key, prefer that for the OpenAI HTTP path
          if (legacyKey.startsWith('sk-')) {
            _apiKey = legacyKey;
          } else {
            // Attempt Google GenerativeModel call and return its text (or a helpful error)
            try {
              final model = GenerativeModel(
                model: 'gemini-1.5-flash',
                apiKey: legacyKey,
                systemInstruction: Content.system(
                  'You are an expert productivity coach. Answer in Vietnamese.',
                ),
              );
              final resp = await model.generateContent([Content.text(prompt)]);
              final text = resp.text ?? '';
              if (text.trim().isNotEmpty) return text;
              return 'AI (Google) trả về nội dung rỗng.';
            } catch (e) {
              return 'Lỗi khi gọi Google Generative API: $e';
            }
          }
        }
      } catch (e) {
        return 'Lỗi đọc legacy AI key: $e';
      }
    }

    if (!isConfigured) {
      return 'AI chưa được cấu hình hoặc API key không phù hợp. Nếu bạn có OpenAI key (bắt đầu bằng "sk-"), gọi AiService.setApiKey(<your_sk_key>) trước khi phân tích, hoặc cấu hình app để dùng Google Generative API.';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final payload = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an expert productivity coach. Answer concisely in Vietnamese.',
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 800,
    };

    try {
      final resp = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return 'Lỗi khi gọi API AI: HTTP ${resp.statusCode} - ${resp.body}';
      }

      final Map<String, dynamic> body = jsonDecode(resp.body);
      final choices = body['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return 'AI không trả về kết quả.';
      final message = choices.first['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      return content ?? 'AI trả về nội dung rỗng.';
    } catch (e) {
      return 'Lỗi khi gọi AI: $e';
    }
  }
}

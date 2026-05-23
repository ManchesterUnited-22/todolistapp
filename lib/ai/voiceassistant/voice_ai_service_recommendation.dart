part of voice_ai_service;

Future<AiRecommendation> voiceAiRecommendFocusBreak(
  VoiceAiService service, {
  required int focusMinutes,
  required int breakMinutes,
}) async {
  // Simple rule-based recommendation as a fallback when no LLM is configured.
  // If an API key and a proper LLM are available, this function can be
  // extended to call the LLM for personalized suggestions.

  // Normalize inputs
  final int focus = max(5, focusMinutes);
  final int brk = max(1, breakMinutes);

  // Default Pomodoro-like suggestion
  int suggestedFocus = focus;
  int suggestedBreak = brk;

  if (focus < 25) suggestedFocus = 25;
  if (brk < 5) suggestedBreak = 5;

  // If the user already uses very long focus sessions, recommend shorter
  // work blocks and slightly longer breaks to avoid burnout.
  if (focus >= 90) {
    suggestedFocus = 60;
    suggestedBreak = max(10, brk + 5);
  }

  final message = StringBuffer();
  message.writeln('Gợi ý thời gian làm việc: ${suggestedFocus} phút, nghỉ ${suggestedBreak} phút.');
  if (suggestedFocus != focus || suggestedBreak != brk) {
    message.writeln('Lý do: cân bằng giữa hiệu suất và phục hồi tinh thần.');
  } else {
    message.writeln('Lý do: cấu hình hiện tại hợp lý; giữ nguyên hoặc điều chỉnh tuỳ cảm nhận.');
  }
  message.writeln('Thử: 2–3 chu kỳ như vậy rồi đánh giá lại.');

  return AiRecommendation(
    suggestedFocusMinutes: suggestedFocus,
    suggestedBreakMinutes: suggestedBreak,
    message: message.toString().trim(),
  );
}

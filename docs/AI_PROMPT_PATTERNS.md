# AI Prompt Patterns - Smart App

## Tổng quan
Tất cả prompts trong app tuân theo cấu trúc chuẩn **4 phần**, với nguyên tắc:
- **Dart xử lý logic**, AI chỉ diễn đạt
- **Không để AI suy đoán** dữ liệu (ngày giờ, số liệu, lịch)
- Output được định dạng rõ ràng cho từng use case

---

## Cấu trúc Prompt Chuẩn

### 4 Phần Bắt buộc

```markdown
[1. Vai trò (Role)]
Bạn là <chuyên môn> trong <tình huống>.
Tôi sẽ cung cấp dữ liệu đã tính sẵn.
Hãy <hành động cụ thể>.

[2. Dữ liệu (Data)]
<Dữ liệu đã được Dart tính toán, không phải AI suy đoán>
- Overdue tasks: <số lượng>
- Completion rate: <phần trăm>
- Top category: <tên>
...

[3. Yêu cầu (Task)]
- Phải làm gì cụ thể?
- Những constraint/guideline?

[4. Định dạng Đầu ra (Output Format)]
Văn xuôi / JSON / HTML / Custom structure
```

---

## Use Cases & Examples

### 1. Chat AI (General Conversation)
**Khi nào dùng**: User chat với AI trong màn hình TaskAI

**Vai trò**: Personal productivity assistant  
**Input**: User message + optional context (tasks due today, recent activity)  
**Output**: Natural Vietnamese text (short & actionable)

**Example Prompt**:
```
Bạn là một trợ lý năng suất cá nhân nói tiếng Việt.
Người dùng vừa nói: "Tôi bị áp lực công việc quá"
Dữ liệu hôm nay:
- Công việc còn lại: 5 (3 quá hạn)
- Thời gian có thể dành: 2 tiếng
- Hạn cuối: 18:00
Hãy:
1) Nhận thức được áp lực của họ
2) Đề xuất 1-2 bước cụ thể & khả thi ngay (không hứa quá lớn)
3) Tạo sự tích cực

Trả lời bằng tiếng Việt, ngắn gọn (< 150 từ).
```

---

### 2. Analytics AI (Performance Insights)
**Khi nào dùng**: Thống kê hiệu suất, phân tích hành vi

**Vai trò**: Productivity coach analyzing weekly/monthly trends  
**Input**: Pre-calculated stats (completion rate, priority distribution, category breakdown)  
**Output**: JSON structure (coach's text + suggestions as array)

**Example Prompt**:
```
Bạn là một huấn luyện viên năng suất chuyên nghiệp.
Dựa trên dữ liệu tuần này (đã tính sẵn):
- Tổng task: 25
- Hoàn thành: 18 (72%)
- Quá hạn: 3
- Phân bố: Công việc 60%, Học tập 25%, Cá nhân 10%, Sức khỏe 5%
- Xu hướng: Công việc tăng 20% so với tuần trước

Hãy trả lời bằng JSON với cấu trúc:
{
  "assessment": "1-2 câu đánh giá ngắn",
  "trend": "Mô tả xu hướng & tác động",
  "suggestions": [
    { "title": "...", "steps": ["...", "..."] },
    ...
  ],
  "motivation": "Đoạn động viên"
}
```

---

### 3. Task Recommendation AI
**Khi nào dùng**: Gợi ý task tiếp theo, đề xuất schedule

**Vai trò**: Smart scheduler & prioritizer  
**Input**: Available tasks, time window, priority, past completion patterns  
**Output**: JSON array of recommended tasks with reasoning

**Example Prompt**:
```
Bạn là trợ lý lên lịch thông minh.
Người dùng có 90 phút rảnh từ 14:00-15:30.
Danh sách task sắp tới (đã sắp xếp theo Dart):
[
  { "title": "Email client", "minutes": 30, "priority": "high", "deadline": "hôm nay 17:00" },
  { "title": "Review report", "minutes": 45, "priority": "medium", "deadline": "ngày mai" },
  ...
]

Hãy đề xuất chuỗi task tối ưu để person này có thể hoàn thành trong khung giờ.
Trả lời JSON:
{
  "plan": [
    { "task": "...", "duration": "...", "reason": "..." },
    ...
  ],
  "notes": "Các lưu ý quan trọng"
}
```

---

## Chú ý Khi Viết Prompt

### ✅ Nên Làm
- Tính toán **trước** bằng Dart (overdue count, completion %, category sums)
- Chèn số liệu **sẵn** vào prompt (không để AI tính)
- Yêu cầu output **có cấu trúc** (JSON, bullets, specific format)
- Viết role/context **rõ ràng** để AI hiểu ngữ cảnh
- Test prompt với **dữ liệu mẫu** trước deploy

### ❌ Không Nên Làm
- Để AI **tự suy đoán** ngày giờ, số liệu
- Viết prompt mơ hồ ("Hãy đánh giá người dùng" ← thiếu context)
- Yêu cầu AI output **hình ảnh/biểu đồ** (dùng fl_chart + JSON thay thế)
- Để dữ liệu nhạy cảm lớn trong prompt (chia thành chunks)

---

## File Implementation

### Hiện tại
- `lib/ai/voice_ai_service.dart` → **DEPRECATED** (voice task flow)
- `lib/ai/voiceassistant/ai_analysis_service.dart` → Đang dùng cho Mentor AI

### Sắp implement
- `lib/ai/services/chat_ai_service.dart` ← **Mới**: Chat prompts
- `lib/ai/services/analytics_ai_service.dart` ← **Mới**: Stats/insights prompts
- `lib/ai/services/ai_prompt_builder.dart` ← **Helper**: Build prompts with data

---

## API Key Management
- Google Generative AI (Gemini 1.5 Flash)
- Từ `.env` hoặc config
- See `VoiceAiService.instance.apiKey` (legacy, reuse for now)

---

## Testing Prompts
```bash
# Test prompt locally với cURL (khi API key ready)
curl -X POST https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"parts": [{"text": "YOUR_PROMPT_HERE"}]}]
  }' \
  -H "x-goog-api-key: YOUR_API_KEY"
```

---

## Roadmap
1. ✅ Define prompt structure & patterns (this doc)
2. ⏳ Implement chat_ai_service.dart
3. ⏳ Implement analytics_ai_service.dart
4. ⏳ Test with real Gemini API
5. ⏳ Fine-tune responses based on user feedback
6. ⏳ (Optional) Parallel LoRA experiment on Colab

---

*Last Updated: 2026-07-20*

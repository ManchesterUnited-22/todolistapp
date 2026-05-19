# smart_app

A new Flutter project.

## Tính Năng

- Màn hình biểu đồ thống kê có nút phân tích AI nổi bật để mở rộng phần gợi ý hiệu suất.
- Luồng tạo task bằng giọng nói được chia thành từng bước: chọn `long_term_task` hoặc `promodoro`, nhập tên, loại, thời lượng, thời điểm và ưu tiên.
- AI sẽ đọc câu hỏi bằng giọng nói trước mỗi bước, rồi chờ người dùng trả lời để đi tiếp bước sau.
- Khi phát hiện khung giờ dễ miss theo lịch sử local, app sẽ chặn mềm bằng cảnh báo nhỏ và gợi ý dời giờ.
- Task `promodoro` sẽ có nút `Promodoro` nhỏ sau khi lưu để mở lại dialog cùng logic tư vấn AI tập trung.

## Cấu hình AI (OpenAI)

Để kết nối với LLM (OpenAI), cung cấp API key trong mã trước khi gọi phân tích AI. Ví dụ (không lưu khoá trực tiếp trong VCS):

```dart
import 'package:smart_app/AI/ai_service.dart';

void main() {
	// Tốt nhất: đọc khoá từ biến môi trường hoặc storage an toàn.
	AiService.setApiKey('sk-...');
	runApp(const MyApp());
}
```

Hiện tại `AiService` dùng endpoint OpenAI Chat Completions (`gpt-3.5-turbo`). Bạn cần tự mua key và không commit nó vào repo.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

part of mentor_ai;

List<String> _buildSuggestions(_ReportData d) {
  if (d.aiNotes != null && d.aiNotes!.trim().isNotEmpty) {
    return d.aiNotes!.trim().split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  final pct = d.totalTasks > 0 ? ((d.completedTasks / d.totalTasks) * 100).round() : 0;
  final suggestions = <String>[];

  suggestions.add('Tỷ lệ hoàn thành đạt $pct%. ${pct >= 70 ? "Bạn đang duy trì tiến độ khá tốt!" : "Hãy cố gắng hoàn thành thêm nhiệm vụ."}');

  if (d.overdueTasks > 0) {
    suggestions.add('Xu hướng trễ hạn xuất hiện ở nhóm ${d.topCategory}. Cần ưu tiên xử lý ${d.overdueTasks} nhiệm vụ quá hạn.');
  }

  suggestions.add(_categoryComment(d.topCategory));
  suggestions.add('Hãy ưu tiên các nhiệm vụ quan trọng vào buổi sáng để tối ưu sự tập trung.');

  return suggestions;
}

String _categoryComment(String topCategory) {
  switch (topCategory) {
    case 'Cá nhân':
      return 'Nhận định: Phần lớn nhiệm vụ của bạn thuộc "Cá nhân" — bạn dành nhiều thời gian cho cuộc sống riêng và chăm sóc bản thân.\n\nĐánh giá: Đây là dấu hiệu tích cực cho sức khỏe và cân bằng cuộc sống nếu công việc không bị bỏ sót; nếu công việc nghề nghiệp đang tụt hậu thì cần điều chỉnh.\n\nĐề xuất (3 bước cụ thể):\n1) Thiết lập 1 khung thời gian cố định/tuần cho việc cá nhân (ví dụ: Chủ nhật sáng 60 phút).\n   - Bước: Ghi vào lịch và đánh dấu là bất khả xâm phạm.\n2) Chọn 2–3 nhiệm vụ cá nhân quan trọng mỗi tuần và hoàn thành trước cuối tuần.\n   - Bước: Dùng tag "Quan trọng" và sắp xếp vào đầu danh sách.\n3) Gom các việc nhỏ thành 1 khối làm cùng nhau để tiết kiệm thời gian.\n\nKết: Giữ thói quen này, nhưng kiểm tra xem nó có ảnh hưởng đến mục tiêu nghề nghiệp không và điều chỉnh khi cần.';
    case 'Sức khỏe':
      return 'Nhận định: Phần lớn nhiệm vụ thuộc "Sức khỏe" — bạn đang ưu tiên chăm sóc sức khỏe, một thói quen rất có lợi dài hạn.\n\nĐánh giá: Rất tốt cho sức khỏe thể chất và tinh thần; chỉ cần đảm bảo không ảnh hưởng quá nhiều tới các trách nhiệm quan trọng khác.\n\nĐề xuất (3 bước cụ thể):\n1) Duy trì một khung nhỏ (30–60 phút) mỗi ngày và đặt lịch cố định.\n   - Bước: Đặt nhắc và đánh dấu là không thể hủy trong lịch cá nhân.\n2) Ghi lại tiến trình hàng tuần (ví dụ 3 buổi/tuần) để theo dõi.\n   - Bước: Dùng một mục nhỏ trong app để ghi kết quả.\n3) Nếu lịch bận, điều chỉnh sang buổi sáng/nghỉ trưa để đảm bảo tính đều đặn.\n\nKết: Tiếp tục duy trì — đây là đầu tư dài hạn cho năng lượng và tinh thần của bạn.';
    case 'Công việc':
      return 'Nhận định: Phần lớn nhiệm vụ của bạn thuộc "Công việc" — bạn có xu hướng ưu tiên công việc và hoàn thành nhiều nhiệm vụ liên quan nghề nghiệp.\n\nĐánh giá: Giúp tiến tới mục tiêu nghề nghiệp nhưng có nguy cơ kiệt sức hoặc bỏ lỡ thời gian cá nhân nếu kéo dài.\n\nĐề xuất (3 bước cụ thể):\n1) Áp dụng "timeboxing": chia ngày làm việc thành khung giờ tập trung và khung nghỉ.\n   - Bước: Đặt 2–3 khung 45–90 phút cho công việc quan trọng mỗi ngày.\n2) Chọn 3 nhiệm vụ quan trọng nhất mỗi ngày và hoàn thành trước buổi trưa.\n   - Bước: Đánh dấu trong danh sách và khóa thời gian để thực hiện.\n3) Ủy thác hoặc gom các nhiệm vụ lặp lại để giảm tải.\n\nKết: Tốt cho năng suất nhưng cần chủ động nghỉ ngơi để tránh kiệt sức.';
    default:
      return 'Nhận định: Loại ưu tiên nhất: $topCategory.\n\nĐánh giá: Hãy xem xét liệu việc ưu tiên này phù hợp với mục tiêu dài hạn của bạn hay không; cân bằng có thể giúp cải thiện cuộc sống và hiệu suất.\n\nĐề xuất (3 bước cụ thể):\n1) Đặt mục tiêu rõ ràng cho mỗi loại và đánh dấu mức ưu tiên.\n   - Bước: Dùng tag và thời hạn để phân loại.\n2) Dành khối thời gian hàng tuần cho từng loại nhiệm vụ.\n   - Bước: Lên lịch 30–60 phút mỗi ngày cho loại ít được ưu tiên.\n3) Thử Pomodoro hoặc timeboxing để tăng hiệu suất.\n\nKết: Điều chỉnh dần theo tuần, đánh giá lại kết quả.';
  }
}

String _monthName(int month) {
  const names = ['', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
  return names[month];
}
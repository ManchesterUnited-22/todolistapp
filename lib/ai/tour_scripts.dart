/// Offline tour script used as fallback or default demonstration.
final List<Map<String, dynamic>> offlineTourScript = [
  {
    'type': 'speak',
    'text':
        'Chào mừng bạn đến với Serene Focus! Mình sẽ hướng dẫn nhanh qua 4 tab chính.',
  },
  {'type': 'delay', 'duration': 2000},

  // Highlight microphone FAB on Home
  {'type': 'focus_feature', 'key': 'neo_nut_mic', 'duration': 1600},
  {
    'type': 'speak',
    'text': 'Đây là nút micro — nhấn để tạo nhiệm vụ bằng giọng nói.',
  },
  {'type': 'delay', 'duration': 1600},

  // Navigate to Thống kê (Stats)
  {'type': 'navigate', 'page_index': 1},
  {'type': 'delay', 'duration': 700},
  {'type': 'focus_feature', 'key': 'neo_tab_stats', 'duration': 1400},
  {
    'type': 'speak',
    'text': 'Trang Thống kê giúp bạn theo dõi hiệu suất và tiến độ.',
  },
  {'type': 'delay', 'duration': 1800},

  // Navigate to Lịch (Calendar)
  {'type': 'navigate', 'page_index': 2},
  {'type': 'delay', 'duration': 700},
  {'type': 'focus_feature', 'key': 'neo_tab_calendar', 'duration': 1400},
  {
    'type': 'speak',
    'text': 'Trang Lịch cho phép bạn xem nhiệm vụ theo ngày và lịch biểu.',
  },
  {'type': 'delay', 'duration': 1800},

  // Navigate to Hồ sơ (Profile)
  {'type': 'navigate', 'page_index': 3},
  {'type': 'delay', 'duration': 700},
  {'type': 'focus_feature', 'key': 'neo_tab_profile', 'duration': 1400},
  {
    'type': 'speak',
    'text': 'Ở đây là Hồ sơ cá nhân, bạn có thể chỉnh thông tin và cài đặt.',
  },
  {'type': 'delay', 'duration': 1800},

  // Return to Home
  {'type': 'navigate', 'page_index': 0},
  {'type': 'delay', 'duration': 700},
  {
    'type': 'speak',
    'text':
        'Xong rồi — bạn đã sẵn sàng bắt đầu! Chúc bạn một ngày tập trung hiệu quả.',
  },
  {'type': 'delay', 'duration': 2000},
];

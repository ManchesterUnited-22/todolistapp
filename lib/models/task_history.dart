import 'dart:convert';

class TaskHistoryItem {
  final String id;
  final DateTime dueAt;
  final DateTime? completedAt;
  final String status;

  TaskHistoryItem({
    required this.id,
    required this.dueAt,
    this.completedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dueAt': dueAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status,
      };

  factory TaskHistoryItem.fromJson(Map<String, dynamic> m) => TaskHistoryItem(
        id: m['id'] as String,
        dueAt: DateTime.parse(m['dueAt'] as String),
        completedAt: m['completedAt'] != null
            ? DateTime.parse(m['completedAt'] as String)
            : null,
        status: m['status'] as String? ?? '',
      );

  static List<TaskHistoryItem> listFromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return [];
    final List<dynamic> arr = json.decode(jsonStr) as List<dynamic>;
    return arr.map((e) => TaskHistoryItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String listToJson(List<TaskHistoryItem> items) {
    final arr = items.map((e) => e.toJson()).toList();
    return json.encode(arr);
  }
}

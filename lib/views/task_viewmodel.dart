import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewmodel_base.dart';

/// ViewModel mapping for documents in the `tasks` collection.
class TaskViewModel extends ViewModel {
  final int? id;
  final String title;
  final String detail;
  final String category;
  final String priority;
  final String way;
  final String stat;
  final Timestamp? createdAt;
  final Timestamp? dueAt;
  final Timestamp? completedAt;
  final int? totalFocusTime;
  final int? totalBreakTime;
  final int? breakDuration;
  final int? focusDuration;
  final String? dateString;
  final Timestamp? timestamp;
  final String uid;

  TaskViewModel({
    this.id,
    required this.title,
    required this.detail,
    required this.category,
    required this.priority,
    required this.way,
    required this.stat,
    this.createdAt,
    this.dueAt,
    this.completedAt,
    this.totalFocusTime,
    this.totalBreakTime,
    this.breakDuration,
    this.focusDuration,
    this.dateString,
    this.timestamp,
    required this.uid,
  });

  factory TaskViewModel.fromMap(Map<String, dynamic> map) {
    return TaskViewModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      detail: map['detail'] as String? ?? '',
      category: map['category'] as String? ?? '',
      priority: map['priority'] as String? ?? 'Vừa',
      way: map['way'] as String? ?? 'long_term_task',
      stat: map['stat'] as String? ?? 'Đang làm',
      createdAt: map['createdAt'] as Timestamp?,
      dueAt: map['dueAt'] as Timestamp?,
      completedAt: map['completedAt'] as Timestamp?,
      totalFocusTime: (map['total_focus_time'] as num?)?.toInt() ?? (map['totalFocusTime'] as num?)?.toInt(),
      totalBreakTime: (map['total_break_time'] as num?)?.toInt() ?? (map['totalBreakTime'] as num?)?.toInt(),
      breakDuration: (map['break_duration'] as num?)?.toInt() ?? (map['breakDuration'] as num?)?.toInt(),
      focusDuration: (map['focus_duration'] as num?)?.toInt() ?? (map['focusDuration'] as num?)?.toInt(),
      dateString: map['date_string'] as String? ?? map['dateString'] as String?,
      timestamp: map['timestamp'] as Timestamp?,
      uid: map['uid'] as String? ?? '',
    );
  }

  factory TaskViewModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskViewModel.fromMap(data);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'detail': detail,
      'category': category,
      'priority': priority,
      'way': way,
      'stat': stat,
      if (createdAt != null) 'createdAt': createdAt,
      if (dueAt != null) 'dueAt': dueAt,
      if (completedAt != null) 'completedAt': completedAt,
      if (totalFocusTime != null) 'total_focus_time': totalFocusTime,
      if (totalBreakTime != null) 'total_break_time': totalBreakTime,
      if (breakDuration != null) 'break_duration': breakDuration,
      if (focusDuration != null) 'focus_duration': focusDuration,
      if (dateString != null) 'date_string': dateString,
      if (timestamp != null) 'timestamp': timestamp,
      'uid': uid,
    };
  }

  Map<String, dynamic> toFirestoreMap({bool useServerTimestampForCreatedAt = false}) {
    final Map<String, dynamic> m = {
      'title': title,
      'detail': detail,
      'category': category,
      'priority': priority,
      'way': way,
      'stat': stat,
      if (dueAt != null) 'dueAt': dueAt,
      if (completedAt != null) 'completedAt': completedAt,
      if (totalFocusTime != null) 'total_focus_time': totalFocusTime,
      if (totalBreakTime != null) 'total_break_time': totalBreakTime,
      if (breakDuration != null) 'break_duration': breakDuration,
      if (focusDuration != null) 'focus_duration': focusDuration,
      if (dateString != null) 'date_string': dateString,
      if (timestamp != null) 'timestamp': timestamp,
      'uid': uid,
    };

    if (createdAt != null) {
      m['createdAt'] = createdAt;
    } else if (useServerTimestampForCreatedAt) {
      m['createdAt'] = FieldValue.serverTimestamp();
    }

    if (id != null) {
      m['id'] = id;
    }

    return m;
  }

  TaskViewModel copyWith({
    int? id,
    String? title,
    String? detail,
    String? category,
    String? priority,
    String? way,
    String? stat,
    Timestamp? createdAt,
    Timestamp? dueAt,
    String? uid,
    Timestamp? completedAt,
    int? totalFocusTime,
    int? totalBreakTime,
    int? breakDuration,
    int? focusDuration,
    String? dateString,
    Timestamp? timestamp,
  }) {
    return TaskViewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      way: way ?? this.way,
      stat: stat ?? this.stat,
      createdAt: createdAt ?? this.createdAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      totalFocusTime: totalFocusTime ?? this.totalFocusTime,
      totalBreakTime: totalBreakTime ?? this.totalBreakTime,
      breakDuration: breakDuration ?? this.breakDuration,
      focusDuration: focusDuration ?? this.focusDuration,
      dateString: dateString ?? this.dateString,
      timestamp: timestamp ?? this.timestamp,
      uid: uid ?? this.uid,
    );
  }

  @override
  String toString() => 'TaskViewModel(id: $id, title: $title, priority: $priority, way: $way, category: $category, stat: $stat)';
}

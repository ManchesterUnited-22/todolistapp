import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskNotificationItem {
  final String id;
  final String title;
  final DateTime dueAt;

  const TaskNotificationItem({
    required this.id,
    required this.title,
    required this.dueAt,
  });
}

class TaskNotificationService {
  TaskNotificationService._();

  static final TaskNotificationService instance = TaskNotificationService._();

  static const Duration dueSoonWindow = Duration(minutes: 10);
  static const String _shownKeysPrefsKey = 'task_notification_shown_keys';
  static const String _enabledPrefsKey = 'task_notification_enabled';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _enabled = true;

  bool get notificationsEnabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledPrefsKey) ?? true;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Mở nhiệm vụ'),
    );

    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledPrefsKey, enabled);
  }

  Future<void> clearAllNotifications() async {
    if (!_initialized) {
      await initialize();
    }

    await _plugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownKeysPrefsKey);
  }

  Future<void> syncTaskReminders({
    required List<TaskNotificationItem> tasks,
    required DateTime now,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_enabled) return;

    final prefs = await SharedPreferences.getInstance();
    final shownKeys = prefs.getStringList(_shownKeysPrefsKey)?.toSet() ?? <String>{};
    bool changed = false;

    for (final task in tasks) {
      final remaining = task.dueAt.difference(now);
      if (remaining <= Duration.zero) {
        final notificationKey = 'overdue:${task.id}:${task.dueAt.millisecondsSinceEpoch}';
        if (shownKeys.add(notificationKey)) {
          changed = true;
          await _showNotification(
            id: notificationKey.hashCode & 0x7fffffff,
            title: 'Nhiệm vụ quá hạn',
            body: '${task.title} chưa được hoàn thành đúng hạn.',
            details: '1 nhiệm vụ chưa được hoàn thành',
          );
        }
        continue;
      }

      if (remaining <= dueSoonWindow) {
        final notificationKey = 'dueSoon:${task.id}:${task.dueAt.millisecondsSinceEpoch}';
        if (shownKeys.add(notificationKey)) {
          changed = true;
          await _showNotification(
            id: notificationKey.hashCode & 0x7fffffff,
            title: 'Nhiệm vụ sắp đến hạn',
            body: '${task.title} còn khoảng 10 phút nữa sẽ đến hạn.',
            details: 'Cảnh báo nhẹ',
          );
        }
      }
    }

    if (changed) {
      await prefs.setStringList(_shownKeysPrefsKey, shownKeys.toList());
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String details,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_deadline_alerts',
      'Task deadline alerts',
      channelDescription: 'Cảnh báo nhiệm vụ sắp đến hạn và quá hạn',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    try {
      await _plugin.show(
        id,
        title,
        '$body\n$details',
        notificationDetails,
      );
    } catch (error) {
      debugPrint('Task notification failed: $error');
    }
  }
}
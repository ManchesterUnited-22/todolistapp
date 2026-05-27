import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  static const String _scheduledKeysPrefsKey = 'task_notification_scheduled_keys';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timezoneInitialized = false;
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
    await _initializeTimezone();
    _initialized = true;
  }

  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized) return;

    tz.initializeTimeZones();

    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      debugPrint('Timezone init failed: $error');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    _timezoneInitialized = true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledPrefsKey, enabled);

    if (!enabled) {
      await clearAllNotifications();
    }
  }

  Future<void> clearAllNotifications() async {
    if (!_initialized) {
      await initialize();
    }

    await _plugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownKeysPrefsKey);
    await prefs.remove(_scheduledKeysPrefsKey);
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
    final scheduledKeys =
        prefs.getStringList(_scheduledKeysPrefsKey)?.toSet() ?? <String>{};
    bool changed = false;

    for (final task in tasks) {
      final remaining = task.dueAt.difference(now);

      if (remaining > Duration.zero) {
        final reminderTime = remaining > dueSoonWindow
            ? task.dueAt.subtract(dueSoonWindow)
            : now.add(const Duration(minutes: 1));
        final scheduleKey =
            'schedule:${task.id}:${task.dueAt.millisecondsSinceEpoch}';
        final notificationId = task.id.hashCode & 0x7fffffff;

        if (!scheduledKeys.contains(scheduleKey)) {
          _removeScheduledKeysForTask(task.id, scheduledKeys);
          scheduledKeys.add(scheduleKey);
          changed = true;

          await _plugin.cancel(notificationId);
          await _scheduleNotification(
            id: notificationId,
            title: 'Nhắc lịch nhiệm vụ',
            body: '${task.title} sẽ đến hạn lúc ${_formatTime(task.dueAt)}.',
            scheduledAt: reminderTime,
          );
        }
      } else {
        if (_removeScheduledKeysForTask(task.id, scheduledKeys)) {
          changed = true;
        }
        await _plugin.cancel(task.id.hashCode & 0x7fffffff);
      }
    }

    if (changed) {
      await prefs.setStringList(_scheduledKeysPrefsKey, scheduledKeys.toList());
    }
  }

  bool _removeScheduledKeysForTask(String taskId, Set<String> scheduledKeys) {
    final before = scheduledKeys.length;
    scheduledKeys.removeWhere((key) => key.startsWith('schedule:$taskId:'));
    return scheduledKeys.length != before;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
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
      final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledAt,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (error) {
      debugPrint('Task reminder schedule failed: $error');
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
      await _plugin.show(id, title, '$body\n$details', notificationDetails);
    } catch (error) {
      debugPrint('Task notification failed: $error');
    }
  }

  Future<void> showManualNotification({
    required String key,
    required String title,
    required String body,
    String details = '',
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_enabled) return;

    await _showNotification(
      id: key.hashCode & 0x7fffffff,
      title: title,
      body: body,
      details: details,
    );
  }
}
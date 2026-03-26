import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const int _taskReminderOffsetMinutes = 10;
  static const int _taskReminderBaseId = 100000;
  static bool _initialized = false;
  static bool _timezoneReady = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    await _configureLocalTimezone();
    _initialized = true;
  }

  static Future<void> _configureLocalTimezone() async {
    if (_timezoneReady) {
      return;
    }

    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint('Falling back to UTC timezone for notifications: $e');
      tz.setLocalLocation(tz.UTC);
    }

    _timezoneReady = true;
  }

  static Future<bool> requestPermissionIfNeeded() async {
    try {
      await initialize();

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final macImpl = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

      final androidGranted = await androidImpl?.requestNotificationsPermission();
      final iosGranted = await iosImpl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      final macGranted = await macImpl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      final all =
          <bool?>[androidGranted, iosGranted, macGranted].whereType<bool>().toList();
      if (all.isEmpty) {
        return true;
      }
      return all.every((granted) => granted);
    } catch (e, st) {
      logError(e, st);
      return false;
    }
  }

  static Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily study reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        _nextInstanceOfTime(hour: hour, minute: minute),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, st) {
      logError(e, st);
      rethrow;
    }
  }

  static tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future<void> cancelDailyReminder() async {
    try {
      await initialize();
      await _plugin.cancel(_dailyReminderId);
    } catch (e, st) {
      logError(e, st);
    }
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'instant_reminder',
      'Instant Reminder',
      channelDescription: 'Immediate reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required String reminderBody,
    required DateTime taskDate,
    required String taskTimeText,
    required String localeTag,
  }) async {
    await initialize();

    final time = _parseTaskTime(taskTimeText, localeTag: localeTag);
    if (time == null) {
      return;
    }

    final taskMoment = tz.TZDateTime(
      tz.local,
      taskDate.year,
      taskDate.month,
      taskDate.day,
      time.hour,
      time.minute,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (!taskMoment.isAfter(now)) {
      return;
    }

    var notifyAt = taskMoment.subtract(
      const Duration(minutes: _taskReminderOffsetMinutes),
    );
    if (!notifyAt.isAfter(now)) {
      notifyAt = now.add(const Duration(seconds: 5));
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminder',
      'Task Reminder',
      channelDescription: 'Per-task schedule reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    final id = _taskNotificationId(taskId);
    await _plugin.zonedSchedule(
      id,
      taskTitle,
      reminderBody,
      notifyAt,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await initialize();
    await _plugin.cancel(_taskNotificationId(taskId));
  }

  static ({int hour, int minute})? _parseTaskTime(
    String input, {
    required String localeTag,
  }) {
    final text = input.trim();
    if (text.isEmpty) {
      return null;
    }

    try {
      final parsed = DateFormat.jm(localeTag).parseLoose(text);
      return (hour: parsed.hour, minute: parsed.minute);
    } catch (_) {
      // Fallback below.
    }

    final military = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (military != null) {
      final hour = int.tryParse(military.group(1)!);
      final minute = int.tryParse(military.group(2)!);
      if (hour != null && minute != null && hour <= 23 && minute <= 59) {
        return (hour: hour, minute: minute);
      }
    }

    return null;
  }

  static int _taskNotificationId(String taskId) {
    var hash = 0;
    for (final code in taskId.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return _taskReminderBaseId + (hash % 900000);
  }

  static void logError(Object error, StackTrace stackTrace) {
    debugPrint('Notification error: $error');
    debugPrint('$stackTrace');
  }
}

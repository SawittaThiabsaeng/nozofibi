import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app_logger.dart';

@pragma('vm:entry-point')
void _onBackgroundNotification(NotificationResponse response) {}

class NotificationService {
  static bool _askedPermission = false;
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const int _taskReminderOffsetMinutes = 0;
  static const int _taskReminderBaseId = 100000;
  static bool _initialized = false;
  static bool _timezoneReady = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {},
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );

    await _configureLocalTimezone();
    await _requestExactAlarmPermission(); // ✅ เพิ่ม
    _initialized = true;
    print('✅ NotificationService initialized');
  }

  static Future<void> _configureLocalTimezone() async {
    if (_timezoneReady) return;

    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      print('🌍 Timezone set to: $timezoneName');
    } catch (e) {
      AppLogger.warn('Falling back to UTC timezone for notifications: $e');
      tz.setLocalLocation(tz.UTC);
      print('⚠️ Timezone fallback to UTC');
    }

    _timezoneReady = true;
  }

  static Future<bool> requestPermissionIfNeeded() async {
    if (_askedPermission) return true;
    _askedPermission = true;
    try {
      await initialize();

      final status = await Permission.notification.status;
      print('🔔 Notification permission status: $status');

      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        print('❌ Permission permanently denied');
        return false;
      }

      final result = await Permission.notification.request();
      print('🔔 Permission request result: $result');
      return result.isGranted;
    } catch (e, st) {
      logError(e, st);
      return false;
    }
  }

  static Future<bool> isPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return true;
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
      icon: '@mipmap/ic_launcher',
      autoCancel: false,
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ ไม่ใช้ alarmClock เพราะใช้ matchDateTimeComponents
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
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      autoCancel: false,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _plugin.show(1002, title, body, notificationDetails);
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

    print('─────────────────────────────────');
    print('🔔 scheduleTaskReminder called');
    print('   taskTitle    : $taskTitle');
    print('   reminderBody : $reminderBody');
    print('   taskTimeText : $taskTimeText');
    print('   taskDate     : $taskDate');
    print('   localeTag    : $localeTag');

    final time = _parseTaskTime(taskTimeText, localeTag: localeTag);
    print('   parsed time  : $time');

    if (time == null) {
      print('❌ time parse failed → abort');
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
    print('   taskMoment   : $taskMoment');
    print('   now          : $now');
    print('   isAfter      : ${taskMoment.isAfter(now)}');

    if (!taskMoment.isAfter(now)) {
      print('❌ time already passed → abort');
      return;
    }

    var notifyAt = taskMoment.subtract(
      const Duration(minutes: _taskReminderOffsetMinutes),
    );

    if (!notifyAt.isAfter(now)) {
      notifyAt = now.add(const Duration(seconds: 5));
      print('⚠️ notifyAt adjusted to +5s: $notifyAt');
    } else {
      print('   notifyAt     : $notifyAt');
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminder',
      'Task Reminder',
      channelDescription: 'Per-task schedule reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    try {
  await _plugin.zonedSchedule(
    _taskNotificationId(taskId),
    taskTitle,
    reminderBody,
    notifyAt,
    details,
    androidScheduleMode: AndroidScheduleMode.alarmClock,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
  print('✅ Notification scheduled! id: ${_taskNotificationId(taskId)}');
} catch (e, st) {
  print('❌ zonedSchedule error: $e');
  print('❌ stackTrace: $st'); // ✅ เพิ่มบรรทัดนี้
  logError(e, st);
}

    print('─────────────────────────────────');
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await initialize();
    await _plugin.cancel(_taskNotificationId(taskId));
    print('🗑️ Notification cancelled: ${_taskNotificationId(taskId)}');
  }

  static ({int hour, int minute})? _parseTaskTime(
    String input, {
    required String localeTag,
  }) {
    final text = input.trim();
    if (text.isEmpty) return null;

    // ✅ 24hr ก่อน เพราะเราบันทึกแบบ "HH:mm"
    final military = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (military != null) {
      final hour = int.tryParse(military.group(1)!);
      final minute = int.tryParse(military.group(2)!);
      if (hour != null && minute != null && hour <= 23 && minute <= 59) {
        print('   parse (24hr): $hour:$minute');
        return (hour: hour, minute: minute);
      }
    }

    // ✅ 12hr fallback
    try {
      final parsed = DateFormat.jm(localeTag).parseLoose(text);
      print('   parse (jm): ${parsed.hour}:${parsed.minute}');
      return (hour: parsed.hour, minute: parsed.minute);
    } catch (_) {}

    print('❌ parse failed for: "$text"');
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
    AppLogger.error('Notification error', error: error);
    AppLogger.warn('$stackTrace');
  }

  // ✅ เพิ่มตรงนี้
  static Future<void> _requestExactAlarmPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        await Permission.scheduleExactAlarm.request();
        print('🔔 Exact alarm permission requested');
      }
    } catch (e) {
      print('⚠️ Could not request exact alarm permission: $e');
    }
  }
}
import 'package:hive/hive.dart';

import '../services/app_logger.dart';
import 'app_local_db.dart';

class NotificationPreferenceStorage {
  static const String _enabledKey = 'notifications_enabled';
  static const String _hourKey = 'notifications_hour';
  static const String _minuteKey = 'notifications_minute';

  static bool _isMissingBoxError(Object error) =>
      error is HiveError && error.toString().contains('Box not found');

  static bool getEnabled({bool fallback = false}) {
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      final raw = box.get(_enabledKey);
      if (raw == null) {
        return fallback;
      }
      return raw.toLowerCase() == 'true';
    } catch (e) {
      if (!_isMissingBoxError(e)) {
        AppLogger.warn('Could not load notification preference: $e');
      }
      return fallback;
    }
  }

  static Future<void> setEnabled({required bool enabled}) async {
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      await box.put(_enabledKey, enabled.toString());
    } catch (e) {
      if (!_isMissingBoxError(e)) {
        AppLogger.warn('Could not save notification preference: $e');
      }
    }
  }

  static ({int hour, int minute}) getReminderTime() {
    const fallbackHour = 20;
    const fallbackMinute = 0;
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      final rawHour = int.tryParse(box.get(_hourKey) ?? '');
      final rawMinute = int.tryParse(box.get(_minuteKey) ?? '');

      final hour = (rawHour != null && rawHour >= 0 && rawHour <= 23)
          ? rawHour
          : fallbackHour;
      final minute = (rawMinute != null && rawMinute >= 0 && rawMinute <= 59)
          ? rawMinute
          : fallbackMinute;

      return (hour: hour, minute: minute);
    } catch (e) {
      if (!_isMissingBoxError(e)) {
        AppLogger.warn('Could not load reminder time: $e');
      }
      return (hour: fallbackHour, minute: fallbackMinute);
    }
  }

  static Future<void> setReminderTime({
    required int hour,
    required int minute,
  }) async {
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      await box.put(_hourKey, hour.toString());
      await box.put(_minuteKey, minute.toString());
    } catch (e) {
      if (!_isMissingBoxError(e)) {
        AppLogger.warn('Could not save reminder time: $e');
      }
    }
  }
}

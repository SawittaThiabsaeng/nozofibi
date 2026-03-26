import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'app_local_db.dart';

/// Storage for user language preference (en/th)
class LanguagePreferenceStorage {
  static const String _languageCodeKey = 'user_language_code';
  static const String _defaultLanguageCode = 'en';

  /// Save user's language preference
  static Future<void> setLanguage(String languageCode) async {
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      await box.put(_languageCodeKey, languageCode.toLowerCase());
      debugPrint('Language preference saved: $languageCode');
    } catch (e) {
      // Hive not initialized (e.g., in tests), silently fail
      debugPrint('Warning: Could not save language preference: $e');
    }
  }

  /// Get user's saved language preference (defaults to 'en')
  static String getLanguage() {
    try {
      final box = Hive.box<String>(AppLocalDb.privacyBox);
      final code = box.get(_languageCodeKey);
      return code ?? _defaultLanguageCode;
    } catch (e) {
      // Hive not initialized (e.g., in tests), return default
      debugPrint('Warning: Could not load language preference: $e');
      return _defaultLanguageCode;
    }
  }

  /// Clear language preference (revert to system locale)
  static Future<void> clearLanguagePreference() async {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    await box.delete(_languageCodeKey);
    debugPrint('Language preference cleared');
  }

  /// Check if user has set a language preference
  static bool hasLanguagePreference() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    return box.containsKey(_languageCodeKey);
  }
}

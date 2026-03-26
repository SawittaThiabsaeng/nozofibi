import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'account_service.dart';
import 'app_local_db.dart';

class PrivacyStorage {
  static const String _consentAcceptedAtKey = 'consent_accepted_at';
  static const String _consentVersionKey = 'consent_version';

  /// Save consent acceptance both locally and to backend
  /// 
  /// This ensures:
  /// 1. Local copy immediately available (offline support)
  /// 2. Backend records proof of consent (GDPR/PDPA compliance)
  static Future<void> saveConsentAcceptedNow() async {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    final timestamp = DateTime.now().toIso8601String();
    final version = AccountService.currentConsentVersion;

    // Save to local storage first (offline support)
    await box.put(_consentAcceptedAtKey, timestamp);
    await box.put(_consentVersionKey, version);

    // Submit to backend in background
    try {
      await AccountService.submitConsent(
        accepted: true,
        customVersion: version,
      );
      debugPrint('Consent submitted to backend successfully');
    } catch (e) {
      // Log error but don't fail - user can still use app
      debugPrint('Warning: Failed to submit consent to backend: $e');
      debugPrint(
        'Consent is saved locally. Will retry on next session.',
      );
    }
  }

  /// Check if user has given consent
  static bool hasConsent() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    final value = box.get(_consentAcceptedAtKey);
    return value != null && value.isNotEmpty;
  }

  /// Get the consent version accepted by user
  static String? getConsentVersion() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    return box.get(_consentVersionKey);
  }

  /// Get timestamp of consent acceptance
  static DateTime? getConsentTimestamp() {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    final timestamp = box.get(_consentAcceptedAtKey);
    if (timestamp != null) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        debugPrint('Error parsing consent timestamp: $e');
      }
    }
    return null;
  }

  /// Clear all privacy data
  static Future<void> clearPrivacyData() async {
    final box = Hive.box<String>(AppLocalDb.privacyBox);
    await box.clear();
  }
}
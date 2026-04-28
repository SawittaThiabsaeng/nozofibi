import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../services/app_logger.dart';
import 'account_service.dart';
import 'app_local_db.dart';

class PrivacyStorage {
  static const String _consentAcceptedAtKey = 'consent_accepted_at';
  static const String _consentVersionKey = 'consent_version';
  static const String _requiredConsentAcceptedKey = 'required_consent_accepted';
  static const String _marketingConsentKey = 'marketing_consent_opt_in';
  static const String _pendingSyncKey = 'consent_pending_sync';

  static String? _testUid;

static void setTestUid(String uid) {
  _testUid = uid;
}

static void clearTestUid() {
  _testUid = null;
}

static String? get _uid =>
    _testUid ?? FirebaseAuth.instance.currentUser?.uid;

  static String _key(String base, String uid) => '${base}_$uid';

  static Box<dynamic> get _box => Hive.box<dynamic>(AppLocalDb.privacyBox);

  /// Save consent locally first, then sync backend
  static Future<void> saveConsentAcceptedNow({
    bool marketingOptIn = false,
  }) async {
    final uid = _uid;

    if (uid == null) {
      AppLogger.warn('Cannot save consent: user uid is null');
      return;
    }

    final timestamp = DateTime.now().toUtc().toIso8601String();
    const version = AccountService.currentConsentVersion;

    await _box.put(_key(_consentAcceptedAtKey, uid), timestamp);
    await _box.put(_key(_consentVersionKey, uid), version);
    await _box.put(_key(_requiredConsentAcceptedKey, uid), true);
    await _box.put(_key(_marketingConsentKey, uid), marketingOptIn);
    await _box.put(_key(_pendingSyncKey, uid), false);

    try {
      await AccountService.submitConsent(
        uid: uid,
        accepted: true,
        customVersion: version,
        marketingOptIn: marketingOptIn,
      );

      await _box.put(_key(_pendingSyncKey, uid), false);

      AppLogger.info('Consent submitted successfully');
    } catch (e) {
      await _box.put(_key(_pendingSyncKey, uid), true);
      AppLogger.warn('Consent backend sync failed: $e');
    }
  }

  /// Retry failed backend sync
  static Future<void> retryPendingConsentSync() async {
    final uid = _uid;

    if (uid == null) return;

    final pending =
        _box.get(_key(_pendingSyncKey, uid)) == true;

    if (!pending) return;
    if (!hasConsent()) return;

    try {
      await AccountService.submitConsent(
        uid: uid,
        accepted: true,
        customVersion: getConsentVersion() ?? AccountService.currentConsentVersion,
        marketingOptIn: hasMarketingConsentOptIn(),
      );

      await _box.put(_key(_pendingSyncKey, uid), false);

      AppLogger.info('Pending consent sync completed');
    } catch (e) {
      AppLogger.warn('Retry consent sync failed: $e');
    }
  }

  /// Has any consent
  static bool hasConsent() {
    final uid = _uid;
    if (uid == null) return false;

    final value = _box.get(_key(_consentAcceptedAtKey, uid));
    return value is String && DateTime.tryParse(value) != null;
  }

  static bool hasRequiredConsent() {
    final uid = _uid;
    if (uid == null) return false;

    return _box.get(_key(_requiredConsentAcceptedKey, uid)) == true;
  }

  static bool hasMarketingConsentOptIn() {
    final uid = _uid;
    if (uid == null) return false;

    return _box.get(_key(_marketingConsentKey, uid)) == true;
  }

  static String? getConsentVersion() {
    final uid = _uid;
    if (uid == null) return null;

    final value = _box.get(_key(_consentVersionKey, uid));
    return value is String ? value : null;
  }

  static DateTime? getConsentTimestamp() {
    final uid = _uid;
    if (uid == null) return null;

    final value = _box.get(_key(_consentAcceptedAtKey, uid));

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        AppLogger.warn('Failed parsing consent timestamp: $e');
      }
    }

    return null;
  }

  /// Clear only current user's consent data
  static Future<void> clearConsentOnly() async {
    final uid = _uid;
    if (uid == null) return;

    await _box.delete(_key(_consentAcceptedAtKey, uid));
    await _box.delete(_key(_consentVersionKey, uid));
    await _box.delete(_key(_requiredConsentAcceptedKey, uid));
    await _box.delete(_key(_marketingConsentKey, uid));
    await _box.delete(_key(_pendingSyncKey, uid));
  }

  /// Wipe everything
  static Future<void> wipeAllPrivacyData() async {
    await _box.clear();
  }

  ///  FIX for your test (alias method)
  static Future<void> clearPrivacyData() async {
    await wipeAllPrivacyData();
  }
}
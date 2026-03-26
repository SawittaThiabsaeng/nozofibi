import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';
import 'app_local_db.dart';

class FocusStorage {
  static const String _baseKey = 'focus_sessions_v3';
  static const String _legacyKey = 'focus_sessions';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const int _maxStoredSessions = 1000;
  static const Duration _retentionDuration = Duration(days: 365);
  static Future<void> _writeChain = Future<void>.value();

  static String _currentUserKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return '${_baseKey}_guest';
    }
    return '${_baseKey}_$uid';
  }

  static Future<T> _withWriteLock<T>(Future<T> Function() action) {
    final task = _writeChain.then((_) => action());
    _writeChain = task.then<void>((_) {}, onError: (_) {});
    return task;
  }

  static DateTime _retentionCutoff() =>
      DateTime.now().subtract(_retentionDuration);

  static List<FocusSession> _sanitizeAndSort(List<FocusSession> sessions) {
    final cutoff = _retentionCutoff();
    final valid = sessions.where((s) => s.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (valid.length <= _maxStoredSessions) {
      return valid;
    }

    return valid.sublist(valid.length - _maxStoredSessions);
  }

  static String _encodeSessions(List<FocusSession> sessions) {
    final payload = sessions.map((s) => s.toJson()).toList();
    return jsonEncode(payload);
  }

  static String _migrationFlagKey(String key) => '__migrated_$key';

  static List<FocusSession> _decodeSessions(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! List) {
        return [];
      }

      return decoded.whereType<Map>().map((item) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));
        return FocusSession.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _migrateLegacyIfNeeded(String key) async {
    final box = Hive.box<String>(AppLocalDb.sessionsBox);
    final migrated = box.get(_migrationFlagKey(key)) == '1';
    if (migrated) {
      return;
    }

    final currentPayload = box.get(key);
    if (currentPayload != null && currentPayload.isNotEmpty) {
      await box.put(_migrationFlagKey(key), '1');
      return;
    }

    String? legacyPayload;

    final secureCandidates = <String>{
      _legacyKey,
      'focus_sessions_v2',
      'focus_sessions_v2_guest',
      key,
      key.replaceFirst(_baseKey, 'focus_sessions_v2'),
    };

    for (final secureKey in secureCandidates) {
      final value = await _secureStorage.read(key: secureKey);
      if (value != null && value.isNotEmpty) {
        legacyPayload = value;
        break;
      }
    }

    if (legacyPayload != null && legacyPayload.isNotEmpty) {
      final migratedSessions = _sanitizeAndSort(_decodeSessions(legacyPayload));
      await box.put(key, _encodeSessions(migratedSessions));
      await box.put(_migrationFlagKey(key), '1');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyList = prefs.getStringList(_legacyKey) ?? const [];
    if (legacyList.isNotEmpty) {
      final mapped = legacyList.map((e) {
        final decoded = jsonDecode(e);
        if (decoded is! Map) {
          throw const FormatException('Invalid legacy payload');
        }
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }).toList();

      final sessions = mapped.map(FocusSession.fromJson).toList();
      final migratedSessions = _sanitizeAndSort(sessions);
      await box.put(key, _encodeSessions(migratedSessions));
      await prefs.remove(_legacyKey);
    }

    await box.put(_migrationFlagKey(key), '1');
  }

  /// โหลด session ทั้งหมด
  static Future<List<FocusSession>> loadSessions() async {
    final key = _currentUserKey();
    await _migrateLegacyIfNeeded(key);
    final box = Hive.box<String>(AppLocalDb.sessionsBox);

    final payload = box.get(key);
    if (payload == null || payload.isEmpty) {
      return [];
    }

    final sessions = _decodeSessions(payload);
    final sanitized = _sanitizeAndSort(sessions);

    if (sanitized.length != sessions.length) {
      await box.put(key, _encodeSessions(sanitized));
    }

    return sanitized;
  }

  /// เพิ่ม session ใหม่
  static Future<void> addSession(FocusSession session) async {
    await _withWriteLock(() async {
      final key = _currentUserKey();
      final box = Hive.box<String>(AppLocalDb.sessionsBox);
      final payload = box.get(key);
      final sessions = payload == null || payload.isEmpty
          ? <FocusSession>[]
          : _decodeSessions(payload);

      sessions.add(session);
      final sanitized = _sanitizeAndSort(sessions);
      await box.put(key, _encodeSessions(sanitized));
    });
  }

  /// ลบทั้งหมด (เผื่อใช้)
  static Future<void> clear() async {
    await _withWriteLock(() async {
      final key = _currentUserKey();
      final box = Hive.box<String>(AppLocalDb.sessionsBox);
      await box.delete(key);
    });
  }
}

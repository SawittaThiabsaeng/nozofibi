import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import 'app_local_db.dart';

class EmotionCheckin {
  EmotionCheckin({
    required this.mood,
    required this.date,
  });

  final String mood;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'date': date.toIso8601String(),
      };

  factory EmotionCheckin.fromJson(Map<String, dynamic> json) {
    return EmotionCheckin(
      mood: (json['mood'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class EmotionCheckinStorage {
  static const String _baseKey = 'emotion_checkins_v1';
  static const int _maxStoredCheckins = 1000;
  static const Duration _retentionDuration = Duration(days: 365);
  static Future<void> _writeChain = Future<void>.value();

  static Future<T> _withWriteLock<T>(Future<T> Function() action) {
    final task = _writeChain.then((_) => action());
    _writeChain = task.then<void>((_) {}, onError: (_) {});
    return task;
  }

  static String _currentUserKey() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return '${_baseKey}_guest';
    }
    return '${_baseKey}_$uid';
  }

  static DateTime _retentionCutoff() => DateTime.now().subtract(_retentionDuration);

  static List<EmotionCheckin> _sanitizeAndSort(List<EmotionCheckin> checkins) {
    final cutoff = _retentionCutoff();
    final valid = checkins.where((entry) => entry.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (valid.length <= _maxStoredCheckins) {
      return valid;
    }

    return valid.sublist(valid.length - _maxStoredCheckins);
  }

  static String _encodeCheckins(List<EmotionCheckin> checkins) {
    final payload = checkins.map((entry) => entry.toJson()).toList();
    return jsonEncode(payload);
  }

  static List<EmotionCheckin> _decodeCheckins(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! List) {
        return [];
      }

      return decoded.whereType<Map>().map((item) {
        final map = item.map((key, value) => MapEntry(key.toString(), value));
        return EmotionCheckin.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<EmotionCheckin>> loadCheckins() async {
    final key = _currentUserKey();
    final box = Hive.box<String>(AppLocalDb.sessionsBox);
    final payload = box.get(key);

    if (payload == null || payload.isEmpty) {
      return [];
    }

    final checkins = _decodeCheckins(payload);
    final sanitized = _sanitizeAndSort(checkins);

    if (sanitized.length != checkins.length) {
      await box.put(key, _encodeCheckins(sanitized));
    }

    return sanitized;
  }

  static Future<void> addCheckin({
    required String mood,
    DateTime? date,
  }) async {
    await _withWriteLock(() async {
      final key = _currentUserKey();
      final box = Hive.box<String>(AppLocalDb.sessionsBox);
      final payload = box.get(key);
      final checkins = payload == null || payload.isEmpty
          ? <EmotionCheckin>[]
          : _decodeCheckins(payload);

      checkins.add(
        EmotionCheckin(
          mood: mood,
          date: date ?? DateTime.now(),
        ),
      );

      final sanitized = _sanitizeAndSort(checkins);
      await box.put(key, _encodeCheckins(sanitized));
    });
  }

  static Future<void> clear() async {
    await _withWriteLock(() async {
      final key = _currentUserKey();
      final box = Hive.box<String>(AppLocalDb.sessionsBox);
      await box.delete(key);
    });
  }
}
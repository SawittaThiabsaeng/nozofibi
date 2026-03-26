import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppLocalDb {
  static const String sessionsBox = 'focus_sessions_secure_v1';
  static const String tasksBox = 'tasks_secure_v1';
  static const String privacyBox = 'privacy_secure_v1';

  @visibleForTesting
  static const String legacySessionsBox = 'focus_sessions';
  @visibleForTesting
  static const String legacyTasksBox = 'tasks';
  @visibleForTesting
  static const String legacyPrivacyBox = 'privacy';

  static const String _encryptionKeyName = 'hive_aes_key_v1';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    await Hive.initFlutter();
    await _initializeBoxes();

    _initialized = true;
  }

  @visibleForTesting
  static Future<void> initForTesting({required String hivePath}) async {
    if (_initialized) {
      return;
    }

    Hive.init(hivePath);
    await _initializeBoxes();

    _initialized = true;
  }

  static Future<void> _initializeBoxes() async {
    final encryptionKey = await _getOrCreateEncryptionKey();
    final cipher = HiveAesCipher(encryptionKey);

    await _migrateLegacyBox(
      legacyName: legacySessionsBox,
      secureName: sessionsBox,
      cipher: cipher,
    );
    await _migrateLegacyBox(
      legacyName: legacyTasksBox,
      secureName: tasksBox,
      cipher: cipher,
    );
    await _migrateLegacyBox(
      legacyName: legacyPrivacyBox,
      secureName: privacyBox,
      cipher: cipher,
    );

    await Hive.openBox<String>(sessionsBox, encryptionCipher: cipher);
    await Hive.openBox<String>(tasksBox, encryptionCipher: cipher);
    await Hive.openBox<String>(privacyBox, encryptionCipher: cipher);
  }

  @visibleForTesting
  static Future<void> resetForTesting() async {
    try {
      await Hive.close();
    } catch (_) {
      // Hive may not be initialized in some test paths.
    }
    _initialized = false;
  }

  static Future<Uint8List> _getOrCreateEncryptionKey() async {
    final existing = await _secureStorage.read(key: _encryptionKeyName);
    if (existing != null && existing.isNotEmpty) {
      return base64Url.decode(existing);
    }

    final generated = _generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64UrlEncode(generated),
    );
    return generated;
  }

  static Uint8List _generateSecureKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  static Future<void> _migrateLegacyBox({
    required String legacyName,
    required String secureName,
    required HiveAesCipher cipher,
  }) async {
    final exists = await Hive.boxExists(legacyName);
    if (!exists) {
      return;
    }

    final legacyBox = await Hive.openBox<String>(legacyName);
    final secureBox = await Hive.openBox<String>(
      secureName,
      encryptionCipher: cipher,
    );

    if (secureBox.isEmpty) {
      for (final key in legacyBox.keys) {
        final keyString = key.toString();
        final value = legacyBox.get(keyString);
        if (value != null) {
          await secureBox.put(keyString, value);
        }
      }
    }

    await legacyBox.deleteFromDisk();
  }
}
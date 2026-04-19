import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;

import '../services/app_logger.dart';
import 'app_local_db.dart';

Uint8List _compressProfileImageBytes(Uint8List imageBytes) {
  try {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return imageBytes;
    }

    const maxDimension = 900;
    const jpegQuality = 76;

    final longestSide =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    final resized = longestSide <= maxDimension
        ? decoded
        : img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? maxDimension : null,
            height: decoded.height > decoded.width ? maxDimension : null,
            interpolation: img.Interpolation.average,
          );

    final encoded = img.encodeJpg(
      resized,
      quality: jpegQuality,
    );
    return Uint8List.fromList(encoded);
  } catch (_) {
    return imageBytes;
  }
}

/// Service for persisting profile data including avatar image.
///
/// Images are stored as encrypted bytes in Hive so large profile pictures do not
/// get inflated by Base64 encoding.
class ProfileStorage {
  static const String _keyProfileImage = 'profile_avatar_bytes';
  static const String _keyDisplayName = 'profile_display_name';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Box<dynamic> get _box => Hive.box(AppLocalDb.profileBox);

  static Future<String?> _readSecure(String key) =>
      _secureStorage.read(key: key);

  /// Save profile image bytes and display name
  static Future<void> saveProfileImage(
    Uint8List imageBytes, {
    String? displayName,
  }) async {
    try {
      final compressedBytes = kIsWeb
          ? _compressProfileImageBytes(imageBytes)
          : await compute(_compressProfileImageBytes, imageBytes);
      await _box.put(_keyProfileImage, compressedBytes);

      if (displayName != null && displayName.isNotEmpty) {
        await _box.put(_keyDisplayName, displayName);
      }

      await _secureStorage.delete(key: _keyProfileImage);
      await _secureStorage.delete(key: _keyDisplayName);
    } catch (e) {
      AppLogger.error('Error saving profile image', error: e);
      rethrow;
    }
  }

  /// Save display name only without changing the image.
  static Future<void> saveDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return;
    }

    try {
      await _box.put(_keyDisplayName, trimmed);
      await _secureStorage.delete(key: _keyDisplayName);
    } catch (e) {
      AppLogger.error('Error saving profile display name', error: e);
      rethrow;
    }
  }

  /// Load saved profile image as bytes
  /// Returns null if no image was saved
  static Future<Uint8List?> loadProfileImage() async {
    try {
      final storedImage = _box.get(_keyProfileImage);
      if (storedImage is Uint8List && storedImage.isNotEmpty) {
        return storedImage;
      }

      final legacyBase64Image = await _readSecure(_keyProfileImage);
      if (legacyBase64Image == null || legacyBase64Image.isEmpty) {
        return null;
      }

      final decoded = base64Decode(legacyBase64Image);
      await _box.put(_keyProfileImage, decoded);
      await _secureStorage.delete(key: _keyProfileImage);
      return decoded;
    } catch (e) {
      AppLogger.error('Error loading profile image', error: e);
      return null;
    }
  }

  /// Load saved display name
  static Future<String?> loadDisplayName() async {
    try {
      final storedName = _box.get(_keyDisplayName);
      if (storedName is String && storedName.isNotEmpty) {
        return storedName;
      }

      final legacyDisplayName = await _readSecure(_keyDisplayName);
      if (legacyDisplayName == null || legacyDisplayName.isEmpty) {
        return null;
      }

      await _box.put(_keyDisplayName, legacyDisplayName);
      await _secureStorage.delete(key: _keyDisplayName);
      return legacyDisplayName;
    } catch (e) {
      AppLogger.error('Error loading display name', error: e);
      return null;
    }
  }

  /// Clear all profile data
  static Future<void> clearProfile() async {
    try {
      await _box.delete(_keyProfileImage);
      await _box.delete(_keyDisplayName);
      await _secureStorage.delete(key: _keyProfileImage);
      await _secureStorage.delete(key: _keyDisplayName);
    } catch (e) {
      AppLogger.error('Error clearing profile', error: e);
    }
  }
}

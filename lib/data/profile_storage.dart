import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for persisting profile data including avatar image.
/// 
/// Images are stored as Base64 strings in secure storage to survive app restarts.
/// This prevents loss of profile customization when the app is backgrounded/killed.
class ProfileStorage {
  static const String _keyProfileImage = 'profile_avatar_base64';
  static const String _keyDisplayName = 'profile_display_name';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> _writeSecure(String key, String value) {
    return _secureStorage.write(key: key, value: value);
  }

  static Future<String?> _readSecure(String key) {
    return _secureStorage.read(key: key);
  }

  /// Save profile image (as base64) and display name
  static Future<void> saveProfileImage(
    Uint8List imageBytes, {
    String? displayName,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      await _writeSecure(_keyProfileImage, base64Image);
      
      if (displayName != null && displayName.isNotEmpty) {
        await _writeSecure(_keyDisplayName, displayName);
      }
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      rethrow;
    }
  }

  /// Load saved profile image as bytes
  /// Returns null if no image was saved
  static Future<Uint8List?> loadProfileImage() async {
    try {
      final base64Image = await _readSecure(_keyProfileImage);
      
      if (base64Image == null || base64Image.isEmpty) {
        return null;
      }
      
      return base64Decode(base64Image);
    } catch (e) {
      debugPrint('Error loading profile image: $e');
      return null;
    }
  }

  /// Load saved display name
  static Future<String?> loadDisplayName() async {
    try {
      return await _readSecure(_keyDisplayName);
    } catch (e) {
      debugPrint('Error loading display name: $e');
      return null;
    }
  }

  /// Clear all profile data
  static Future<void> clearProfile() async {
    try {
      await _secureStorage.delete(key: _keyProfileImage);
      await _secureStorage.delete(key: _keyDisplayName);
    } catch (e) {
      debugPrint('Error clearing profile: $e');
    }
  }
}

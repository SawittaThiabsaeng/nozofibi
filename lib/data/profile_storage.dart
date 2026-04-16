import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/app_logger.dart';

/// Service for persisting profile data including avatar image.
///
/// Images are stored as Base64 strings in secure storage to survive app restarts.
/// This prevents loss of profile customization when the app is backgrounded/killed.
class ProfileStorage {
  static const String _keyProfileImage = 'profile_avatar_base64';
  static const String _keyDisplayName = 'profile_display_name';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> _writeSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  static Future<String?> _readSecure(String key) =>
      _secureStorage.read(key: key);

  /// Save profile image (as base64) and display name
  static Future<void> saveProfileImage(
    Uint8List imageBytes, {
    String? displayName,
  }) async {
    try {
      final compressedBytes = await _compressImageBytes(imageBytes);
      final base64Image = base64Encode(compressedBytes);
      await _writeSecure(_keyProfileImage, base64Image);

      if (displayName != null && displayName.isNotEmpty) {
        await _writeSecure(_keyDisplayName, displayName);
      }
    } catch (e) {
      AppLogger.error('Error saving profile image', error: e);
      rethrow;
    }
  }

  static Future<Uint8List> _compressImageBytes(Uint8List imageBytes) async {
    const maxDimension = 1400;

    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final longestSide =
          image.width > image.height ? image.width : image.height;
      if (longestSide <= maxDimension) {
        image.dispose();
        return imageBytes;
      }

      final scale = maxDimension / longestSide;
      final targetWidth = (image.width * scale).round();
      final targetHeight = (image.height * scale).round();

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;

      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        ui.Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint,
      );

      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(targetWidth, targetHeight);
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();
      resizedImage.dispose();

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      AppLogger.error('Error compressing profile image', error: e);
    }

    return imageBytes;
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
      AppLogger.error('Error loading profile image', error: e);
      return null;
    }
  }

  /// Load saved display name
  static Future<String?> loadDisplayName() async {
    try {
      return await _readSecure(_keyDisplayName);
    } catch (e) {
      AppLogger.error('Error loading display name', error: e);
      return null;
    }
  }

  /// Clear all profile data
  static Future<void> clearProfile() async {
    try {
      await _secureStorage.delete(key: _keyProfileImage);
      await _secureStorage.delete(key: _keyDisplayName);
    } catch (e) {
      AppLogger.error('Error clearing profile', error: e);
    }
  }
}

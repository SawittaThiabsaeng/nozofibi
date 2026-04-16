import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(message);
  }

  static void warn(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(message);
  }

  static void error(String message, {Object? error}) {
    if (!kDebugMode) {
      return;
    }
    if (error == null) {
      debugPrint(message);
      return;
    }
    debugPrint('$message: $error');
  }
}

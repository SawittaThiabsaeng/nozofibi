import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';

class FocusStorage {
  static const String key = 'focus_sessions';

  /// โหลด session ทั้งหมด
  static Future<List<FocusSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((e) => FocusSession.fromJson(jsonDecode(e)))
        .toList();
  }

  /// เพิ่ม session ใหม่
  static Future<void> addSession(FocusSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    data.add(jsonEncode(session.toJson()));

    await prefs.setStringList(key, data);
  }

  /// ลบทั้งหมด (เผื่อใช้)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
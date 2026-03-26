import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/task.dart';
import 'app_local_db.dart';

class TaskStorage {
  static const String _key = 'schedule_tasks_v1';

  static Future<List<ScheduleTask>> loadTasks() async {
    final box = Hive.box<String>(AppLocalDb.tasksBox);
    final raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .map(ScheduleTask.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(List<ScheduleTask> tasks) async {
    final box = Hive.box<String>(AppLocalDb.tasksBox);
    final payload = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await box.put(_key, payload);
  }

  static Future<void> clear() async {
    final box = Hive.box<String>(AppLocalDb.tasksBox);
    await box.delete(_key);
  }
}
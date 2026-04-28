import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/task_storage.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final List<ScheduleTask> _tasks = [];
  bool _loaded = false;

  List<ScheduleTask> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final stored = await TaskStorage.loadTasks();
    _tasks
      ..clear()
      ..addAll(stored);
    _loaded = true;
    notifyListeners();
  }

  Future<void> addTask(
    ScheduleTask task, {
    required String alertTitle,
    required String localeTag,
  }) async {
    _tasks.add(task);
    await TaskStorage.saveTasks(_tasks);
    await NotificationService.scheduleTaskReminder(
      taskId: task.id,
      taskTitle: alertTitle,
      reminderBody: task.title,
      taskDate: task.date,
      taskTimeText: task.time,
      localeTag: localeTag,
    );
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index].completed = !_tasks[index].completed;
    await TaskStorage.saveTasks(_tasks);
    if (_tasks[index].completed) {
      await NotificationService.cancelTaskReminder(id);
    }
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await TaskStorage.saveTasks(_tasks);
    await NotificationService.cancelTaskReminder(id);
    notifyListeners();
  }

  Future<void> updateTask(
    ScheduleTask updated, {
    required String alertTitle,
    required String localeTag,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;

    // ยกเลิก notification เดิมก่อน
    await NotificationService.cancelTaskReminder(updated.id);

    _tasks[index] = updated;
    await TaskStorage.saveTasks(_tasks);

    // schedule notification ใหม่
    await NotificationService.scheduleTaskReminder(
      taskId: updated.id,
      taskTitle: alertTitle,
      reminderBody: updated.title,
      taskDate: updated.date,
      taskTimeText: updated.time,
      localeTag: localeTag,
    );

    notifyListeners();
  }

  Future<void> clearAll() async {
    _tasks.clear();
    await TaskStorage.clear();
    await FlutterLocalNotificationsPlugin().cancelAll();
    notifyListeners();
  }

  static Future<void> initNotifications() =>
      NotificationService.initialize();
}
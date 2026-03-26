import 'package:flutter/foundation.dart';

import '../data/task_storage.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<ScheduleTask> _tasks = [];
  bool _loaded = false;

  List<ScheduleTask> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }

    final stored = await TaskStorage.loadTasks();
    _tasks
      ..clear()
      ..addAll(stored);
    _loaded = true;
    notifyListeners();
  }

  Future<void> addTask(ScheduleTask task) async {
    _tasks.add(task);
    await TaskStorage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return;
    }

    _tasks[index].completed = !_tasks[index].completed;
    await TaskStorage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await TaskStorage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _tasks.clear();
    await TaskStorage.clear();
    notifyListeners();
  }
}

enum TaskType { study, breakTime, exercise, rest }

class ScheduleTask {

  ScheduleTask({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.type,
    this.completed = false,
  });
  final String id;
  final DateTime date;
  final String time;
  final String title;
  final TaskType type;
  bool completed;

  ScheduleTask copyWith({
    String? id,
    DateTime? date,
    String? time,
    String? title,
    TaskType? type,
    bool? completed,
  }) => ScheduleTask(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
}

enum TaskType { study, breakTime, exercise, rest }

TaskType _taskTypeFromName(String? name) {
  if (name == null) {
    return TaskType.study;
  }

  for (final value in TaskType.values) {
    if (value.name == name) {
      return value;
    }
  }
  return TaskType.study;
}

class ScheduleTask {
  ScheduleTask({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.type,
    this.completed = false,
    this.focusMinutes = 0, // ✅ เพิ่มตัวนี้
  });

  final String id;
  final DateTime date;
  final String time;
  final String title;
  final TaskType type;

  bool completed;

  /// ✅ เก็บเวลาที่โฟกัสจริง (หน่วย: นาที)
  int focusMinutes;

  ScheduleTask copyWith({
    String? id,
    DateTime? date,
    String? time,
    String? title,
    TaskType? type,
    bool? completed,
    int? focusMinutes, // ✅ เพิ่มใน copyWith ด้วย
  }) =>
      ScheduleTask(
        id: id ?? this.id,
        date: date ?? this.date,
        time: time ?? this.time,
        title: title ?? this.title,
        type: type ?? this.type,
        completed: completed ?? this.completed,
        focusMinutes: focusMinutes ?? this.focusMinutes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'time': time,
        'title': title,
        'type': type.name,
        'completed': completed,
        'focusMinutes': focusMinutes,
      };

  factory ScheduleTask.fromJson(Map<String, dynamic> json) => ScheduleTask(
        id: (json['id'] ?? '').toString(),
        date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
        time: (json['time'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        type: _taskTypeFromName(json['type']?.toString()),
        completed: json['completed'] == true,
        focusMinutes: (json['focusMinutes'] as num?)?.toInt() ?? 0,
      );
}
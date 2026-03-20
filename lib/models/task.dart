enum TaskType { study, breakTime, exercise, rest }

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
}
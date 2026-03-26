import 'task.dart';

TaskType? _focusSessionTaskTypeFromName(String? name) {
  if (name == null || name.isEmpty) {
    return null;
  }

  for (final value in TaskType.values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

class FocusSession {
  FocusSession({
    required this.title,
    required this.totalSeconds,
    required this.date,
    this.type,
  });

  final String title;
  final int totalSeconds;
  final DateTime date;
  final TaskType? type;

  int get hours => totalSeconds ~/ 3600;
  int get minutes => (totalSeconds % 3600) ~/ 60;
  int get seconds => totalSeconds % 60;

  Map<String, dynamic> toJson() => {
        'title': title,
        'totalSeconds': totalSeconds,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'date': date.toIso8601String(),
        'type': type?.name,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    final int parsedTotalSeconds;

    if (json['totalSeconds'] != null) {
      parsedTotalSeconds = (json['totalSeconds'] as num).toInt();
    } else if (json['hours'] != null || json['minutes'] != null || json['seconds'] != null) {
      final h = ((json['hours'] ?? 0) as num).toInt();
      final m = ((json['minutes'] ?? 0) as num).toInt();
      final s = ((json['seconds'] ?? 0) as num).toInt();
      parsedTotalSeconds = (h * 3600) + (m * 60) + s;
    } else {
      // Backward compatibility for old records that only saved minutes.
      final legacyMinutes = ((json['minutes'] ?? 0) as num).toInt();
      parsedTotalSeconds = legacyMinutes * 60;
    }

    return FocusSession(
      title: json['title'],
      totalSeconds: parsedTotalSeconds,
      date: DateTime.parse(json['date']),
      type: _focusSessionTaskTypeFromName(json['type']?.toString()),
    );
  }
}
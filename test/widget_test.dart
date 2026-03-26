import 'package:flutter_test/flutter_test.dart';

import 'package:nozofibi/models/focus_session.dart';
import 'package:nozofibi/models/task.dart';

void main() {
  group('FocusSession', () {
    test('serializes and deserializes totalSeconds', () {
      final now = DateTime.now();
      final session = FocusSession(
        title: 'Deep Work',
        totalSeconds: 3661,
        date: now,
      );

      final json = session.toJson();
      final parsed = FocusSession.fromJson(json);

      expect(parsed.title, 'Deep Work');
      expect(parsed.totalSeconds, 3661);
      expect(parsed.hours, 1);
      expect(parsed.minutes, 1);
      expect(parsed.seconds, 1);
      expect(parsed.date.toIso8601String(), now.toIso8601String());
    });

    test('supports legacy minute-only payload', () {
      final now = DateTime.now();
      final parsed = FocusSession.fromJson({
        'title': 'Legacy Session',
        'minutes': 25,
        'date': now.toIso8601String(),
      });

      expect(parsed.totalSeconds, 1500);
    });
  });

  group('ScheduleTask', () {
    test('serializes and deserializes task values', () {
      final now = DateTime.now();
      final task = ScheduleTask(
        id: 'task-1',
        date: now,
        time: '09:00',
        title: 'Read chapter 7',
        type: TaskType.study,
        completed: true,
        focusMinutes: 45,
      );

      final json = task.toJson();
      final parsed = ScheduleTask.fromJson(json);

      expect(parsed.id, 'task-1');
      expect(parsed.title, 'Read chapter 7');
      expect(parsed.type, TaskType.study);
      expect(parsed.completed, true);
      expect(parsed.focusMinutes, 45);
    });
  });
}

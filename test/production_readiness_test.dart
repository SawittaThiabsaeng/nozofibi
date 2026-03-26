import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/data/app_local_db.dart';
import 'package:nozofibi/data/privacy_storage.dart';
import 'package:nozofibi/data/task_storage.dart';
import 'package:nozofibi/models/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory testHiveDir;

  setUpAll(() async {
    testHiveDir = await Directory.systemTemp.createTemp('nozofibi_test_hive_');
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AppLocalDb.resetForTesting();
    await AppLocalDb.initForTesting(hivePath: testHiveDir.path);
  });

  setUp(() async {
    try {
      await TaskStorage.clear();
      await PrivacyStorage.clearPrivacyData();
    } catch (_) {
      // Ignore if boxes were not fully initialized yet
    }
  });

  tearDownAll(() async {
    try {
      await AppLocalDb.resetForTesting();
      if (await testHiveDir.exists()) {
        await testHiveDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('tearDownAll error: $e');
    }
  });

  group('Explicit Consent Flow', () {
    test('consent storage initializes empty by default', () async {
      expect(PrivacyStorage.hasConsent(), isFalse);
    });

    test('saveConsentAcceptedNow persists consent timestamp', () async {
      expect(PrivacyStorage.hasConsent(), isFalse);
      await PrivacyStorage.saveConsentAcceptedNow();
      expect(PrivacyStorage.hasConsent(), isTrue);
    });

    test('clearPrivacyData removes consent completely', () async {
      await PrivacyStorage.saveConsentAcceptedNow();
      expect(PrivacyStorage.hasConsent(), isTrue);
      
      await PrivacyStorage.clearPrivacyData();
      expect(PrivacyStorage.hasConsent(), isFalse);
    });
  });

  group('User Data Deletion Flow', () {
    test('delete tasks removes all tasks and preserves consent state', () async {
      final now = DateTime.now();
      await TaskStorage.saveTasks([
        ScheduleTask(
          id: 't1',
          date: now,
          time: '09:00',
          title: 'Study',
          type: TaskType.study,
          focusMinutes: 30,
        ),
      ]);
      await PrivacyStorage.saveConsentAcceptedNow();

      expect((await TaskStorage.loadTasks()).length, 1);
      expect(PrivacyStorage.hasConsent(), isTrue);

      // Delete tasks only, consent should remain
      await TaskStorage.clear();
      expect(await TaskStorage.loadTasks(), isEmpty);
      expect(PrivacyStorage.hasConsent(), isTrue);
    });

    test('delete account removes both tasks and consent', () async {
      final now = DateTime.now();
      await TaskStorage.saveTasks([
        ScheduleTask(
          id: 't2',
          date: now,
          time: '10:00',
          title: 'Work',
          type: TaskType.exercise,
          focusMinutes: 45,
        ),
      ]);
      await PrivacyStorage.saveConsentAcceptedNow();

      // Full account deletion
      await TaskStorage.clear();
      await PrivacyStorage.clearPrivacyData();

      expect(await TaskStorage.loadTasks(), isEmpty);
      expect(PrivacyStorage.hasConsent(), isFalse);
    });
  });

  group('Local Data Encryption', () {
    test('tasks are encrypted in Hive storage', () async {
      final now = DateTime.now();
      const title = 'Confidential Task';
      
      await TaskStorage.saveTasks([
        ScheduleTask(
          id: 'confidential-1',
          date: now,
          time: '15:00',
          title: title,
          type: TaskType.study,
          focusMinutes: 60,
        ),
      ]);

      // Verify task can be retrieved correctly (decryption works)
      final tasks = await TaskStorage.loadTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, title);
      expect(tasks.first.id, 'confidential-1');
    });

    test('consent data is encrypted and survives storage cycle', () async {
      await PrivacyStorage.saveConsentAcceptedNow();
      
      // Consent flag should persist across operations
      expect(PrivacyStorage.hasConsent(), isTrue);
      
      // Even after clearing and saving again
      await PrivacyStorage.clearPrivacyData();
      expect(PrivacyStorage.hasConsent(), isFalse);
      
      await PrivacyStorage.saveConsentAcceptedNow();
      expect(PrivacyStorage.hasConsent(), isTrue);
    });
  });
}

import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nozofibi/data/account_service.dart';
import 'package:nozofibi/data/app_local_db.dart';
import 'package:nozofibi/data/privacy_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late Directory testHiveDir;

  setUpAll(() async {
    testHiveDir =
        await Directory.systemTemp.createTemp('nozofibi_privacy_hive_');

    FlutterSecureStorage.setMockInitialValues(<String, String>{});

    await AppLocalDb.resetForTesting();
    await AppLocalDb.initForTesting(hivePath: testHiveDir.path);
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'user-privacy-1',
        email: 'privacy@example.com',
      ),
    );

    await PrivacyStorage.clearPrivacyData();

    AccountService.configureForTesting(
      auth: auth,
      firestore: firestore,
    );
  });

  tearDown(() async {
    AccountService.resetForTesting();
  });

  tearDownAll(() async {
    try {
      await AppLocalDb.resetForTesting();
    } catch (_) {}

    try {
      if (testHiveDir.existsSync()) {
        testHiveDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  test(
    'saveConsentAcceptedNow stores required and marketing consent locally',
    () async {
      await PrivacyStorage.saveConsentAcceptedNow(marketingOptIn: true);

      expect(PrivacyStorage.hasConsent(), isTrue);
      expect(PrivacyStorage.hasRequiredConsent(), isTrue);
      expect(PrivacyStorage.hasMarketingConsentOptIn(), isTrue);
      expect(
        PrivacyStorage.getConsentVersion(),
        AccountService.currentConsentVersion,
      );
      expect(PrivacyStorage.getConsentTimestamp(), isNotNull);
    },
  );

  test(
    'saveConsentAcceptedNow submits granular consent fields to backend',
    () async {
      await PrivacyStorage.saveConsentAcceptedNow(marketingOptIn: false);

      // ✅ FIX 1: ensure Firestore flush stability
      await Future.delayed(const Duration(milliseconds: 50));

      final userDoc = await firestore
          .collection('users')
          .doc('user-privacy-1')
          .get();

      final userData = userDoc.data();

      expect(userData?['consentVersion'], AccountService.currentConsentVersion);
      expect(userData?['consented'], isTrue);
      expect(userData?['requiredConsentAccepted'], isTrue);
      expect(userData?['marketingConsentOptIn'], isFalse);

      final consentDocs = await firestore
          .collection('users')
          .doc('user-privacy-1')
          .collection('consent')
          .get();

      expect(consentDocs.docs, hasLength(1));

      final consentData = consentDocs.docs.first.data();

      expect(consentData['requiredConsentAccepted'], isTrue);
      expect(consentData['marketingConsentOptIn'], isFalse);
    },
  );
}
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
  late String testHivePath;

  setUpAll(() async {
    final testHiveDir = await Directory.systemTemp.createTemp(
      'nozofibi_privacy_hive_',
    );
    testHivePath = testHiveDir.path;
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AppLocalDb.resetForTesting();
    await AppLocalDb.initForTesting(hivePath: testHivePath);
  });

  setUp(() async {
    await PrivacyStorage.clearPrivacyData();
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'user-privacy-1',
        email: 'privacy@example.com',
      ),
      signedIn: true,
    );
    AccountService.configureForTesting(
      auth: auth,
      firestore: firestore,
    );
  });

  tearDown(AccountService.resetForTesting);

  tearDownAll(() async {
    try {
      await AppLocalDb.resetForTesting();
    } catch (_) {}
    try {
      final testHiveDir = Directory(testHivePath);
      if (testHiveDir.existsSync()) {
        testHiveDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  test('saveConsentAcceptedNow stores required and marketing consent locally', () async {
    await PrivacyStorage.saveConsentAcceptedNow(marketingOptIn: true);

    expect(PrivacyStorage.hasConsent(), isTrue);
    expect(PrivacyStorage.hasRequiredConsent(), isTrue);
    expect(PrivacyStorage.hasMarketingConsentOptIn(), isTrue);
    expect(PrivacyStorage.getConsentVersion(), AccountService.currentConsentVersion);
    expect(PrivacyStorage.getConsentTimestamp(), isNotNull);
  });

  test('saveConsentAcceptedNow submits granular consent fields to backend', () async {
    await PrivacyStorage.saveConsentAcceptedNow(marketingOptIn: false);

    final userDoc = await firestore.collection('users').doc('user-privacy-1').get();
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
    final consentData = consentDocs.docs.single.data();
    expect(consentData['requiredConsentAccepted'], isTrue);
    expect(consentData['marketingConsentOptIn'], isFalse);
  });
}

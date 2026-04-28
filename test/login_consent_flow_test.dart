import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nozofibi/data/app_local_db.dart';
import 'package:nozofibi/data/privacy_storage.dart';
import 'package:nozofibi/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testHiveDir;

  setUpAll(() async {
    testHiveDir =
        await Directory.systemTemp.createTemp('nozofibi_login_hive_');

    FlutterSecureStorage.setMockInitialValues(<String, String>{});

    await AppLocalDb.resetForTesting();
    await Future.delayed(const Duration(milliseconds: 50));

    await AppLocalDb.initForTesting(
      hivePath: testHiveDir.path,
    );
  });

  setUp(() async {
    await PrivacyStorage.clearPrivacyData();
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

  testWidgets('BLOCK login when consent is declined', (tester) async {
    // ✅ FIX 1: store binding (prevents unstable access)
    final binding = tester.binding;

    binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => binding.setSurfaceSize(null));

    final auth = MockFirebaseAuth(signedIn: false);

    var loginTriggered = false;
    var consentCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onLogin: (_) => loginTriggered = true,
          auth: auth,
          consentPrompt: (_) async => false,

          // ❗ must not proceed
          emailLoginOverride: (_, __) async {
            throw Exception('Login must NOT be triggered');
          },

          onConsentAccepted: () async {
            consentCalled = true;
          },
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email Address'),
      'decline@example.com',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'StrongPass1',
    );

    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));

    // ✅ FIX 2: CI-safe wait (no timeout risk)
    await tester.pumpAndSettle();

    expect(loginTriggered, isFalse);
    expect(consentCalled, isFalse);
    expect(PrivacyStorage.hasConsent(), isFalse);
  });

  testWidgets('ALLOW login when consent is accepted', (tester) async {
    final binding = tester.binding;

    binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => binding.setSurfaceSize(null));

    final auth = MockFirebaseAuth(signedIn: false);

    var loginTriggered = false;
    var consentCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onLogin: (_) => loginTriggered = true,
          auth: auth,
          consentPrompt: (_) async => true,

          emailLoginOverride: (_, __) async {
          return await auth.signInAnonymously();
          },

          onConsentAccepted: () async {
            consentCalled = true;
          },
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email Address'),
      'accept@example.com',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'StrongPass1',
    );

    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));

    await tester.pumpAndSettle();

    expect(consentCalled, isTrue);
    expect(loginTriggered, isTrue);
  });
}
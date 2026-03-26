import 'dart:io';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/data/app_local_db.dart';
import 'package:nozofibi/data/privacy_storage.dart';
import 'package:nozofibi/screens/login_screen.dart';

Future<MockFirebaseAuth> _buildAuth() async {
  final auth = MockFirebaseAuth(signedIn: false);
  return auth;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory testHiveDir;

  setUpAll(() async {
    testHiveDir = await Directory.systemTemp.createTemp('nozofibi_login_hive_');
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AppLocalDb.resetForTesting();
    await AppLocalDb.initForTesting(hivePath: testHiveDir.path);
  });

  setUp(() async {
    await PrivacyStorage.clearPrivacyData();
  });

  tearDownAll(() async {
    try {
      await AppLocalDb.resetForTesting();
    } catch (_) {}
    try {
      if (await testHiveDir.exists()) {
        await testHiveDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('email login is blocked when consent is declined', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = await _buildAuth();
    var consentAcceptedCalled = false;
    var loginCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onLogin: (_) => loginCalled = true,
          auth: auth,
          consentPrompt: (_) async => false,
          emailLoginOverride: (_, __) => auth.signInAnonymously(),
          onConsentAccepted: () async {
            consentAcceptedCalled = true;
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

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(loginCalled, isFalse);
    expect(consentAcceptedCalled, isFalse);
    expect(PrivacyStorage.hasConsent(), isFalse);
    expect(auth.currentUser, isNull);
  });

  testWidgets('email login continues when consent is accepted', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = await _buildAuth();
    var consentAcceptedCalled = false;
    var loginCalled = false;
    var consentSavedBy = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onLogin: (_) => loginCalled = true,
          auth: auth,
          consentPrompt: (_) async => true,
          emailLoginOverride: (_, __) => auth.signInAnonymously(),
          onConsentAccepted: () async {
            consentAcceptedCalled = true;
            // Track that our DI callback was used instead of default PrivacyStorage
            consentSavedBy.add('injected_callback');
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

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Verify the DI pattern: callback was invoked instead of default behavior
    expect(consentAcceptedCalled, isTrue, reason: 'Consent DI callback should have been invoked');
    expect(consentSavedBy, contains('injected_callback'), reason: 'Consent should be saved via injected callback');
    expect(loginCalled, isTrue, reason: 'Login should complete after consent accepted');
    expect(auth.currentUser, isNotNull, reason: 'User should be authenticated');
  });
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nozofibi/data/account_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'user-1',
        email: 'user1@example.com',
      ),
      signedIn: true,
    );

    AccountService.configureForTesting(
      auth: auth,
      firestore: firestore,
    );
  });

  tearDown(() {
    AccountService.resetForTesting();
  });

  group('AccountService.submitConsent', () {
    test('throws when user is not authenticated', () async {
      final signedOutAuth = MockFirebaseAuth(signedIn: false);
      AccountService.configureForTesting(auth: signedOutAuth);

      expect(
        () => AccountService.submitConsent(accepted: true),
        throwsA(isA<Exception>()),
      );
    });

    test('stores consent entry and profile summary', () async {
      final ok = await AccountService.submitConsent(
        accepted: true,
        customVersion: '1.2.3',
      );

      expect(ok, isTrue);

      final consentDocs = await firestore
          .collection('users')
          .doc('user-1')
          .collection('consent')
          .get();

      expect(consentDocs.docs.length, 1);
      expect(consentDocs.docs.first.data()['accepted'], true);
      expect(consentDocs.docs.first.data()['version'], '1.2.3');
      expect(consentDocs.docs.first.data()['source'], 'client');

      final userDoc =
          await firestore.collection('users').doc('user-1').get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['consented'], true);
      expect(userDoc.data()?['consentVersion'], '1.2.3');
    });
  });

  group('AccountService.getConsentHistory', () {
    test('returns consent history ordered by timestamp desc', () async {
      final consentRef =
          firestore.collection('users').doc('user-1').collection('consent');

      await consentRef.add({
        'version': '1.0.0',
        'accepted': true,
        'timestamp': 1000,
      });
      await consentRef.add({
        'version': '1.1.0',
        'accepted': false,
        'timestamp': 2000,
      });

      final history = await AccountService.getConsentHistory();

      expect(history.length, 2);
      expect(history.first.version, '1.1.0');
      expect(history.first.accepted, false);
      expect(history.last.version, '1.0.0');
    });
  });

  group('AccountService.deleteAccount', () {
    test('removes user document and user-owned subcollections', () async {
      final userDoc = firestore.collection('users').doc('user-1');

      await userDoc.set({'name': 'User One'});
      await userDoc.collection('focus_sessions_v2').doc('s1').set({
        'totalSeconds': 1500,
      });
      await userDoc.collection('consent').doc('c1').set({
        'version': '1.0.0',
        'accepted': true,
        'timestamp': 1234,
      });

      final ok = await AccountService.deleteAccount(
        reason: 'Test deletion',
      );

      expect(ok, isTrue);

      final deletedUser = await userDoc.get();
      expect(deletedUser.exists, isFalse);

      final sessionsAfter =
          await userDoc.collection('focus_sessions_v2').get();
      final consentsAfter = await userDoc.collection('consent').get();
      expect(sessionsAfter.docs, isEmpty);
      expect(consentsAfter.docs, isEmpty);
      expect(auth.currentUser, isNull);
    });

    test('prompts sign-in again when recent login is required', () async {
      AccountService.configureForTesting(
        deleteAuthUserOverride: (_) async {
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'Recent login required',
          );
        },
        reauthOverride: () async => false,
      );

      expect(
        () => AccountService.deleteAccount(reason: 'Reauth check'),
        throwsA(
          predicate(
            (e) => e.toString().contains('Please sign in again'),
          ),
        ),
      );
    });

    test('retries deletion once after successful re-auth', () async {
      var attempts = 0;
      AccountService.configureForTesting(
        deleteAuthUserOverride: (_) async {
          attempts += 1;
          if (attempts == 1) {
            throw FirebaseAuthException(
              code: 'requires-recent-login',
              message: 'Recent login required',
            );
          }
        },
        reauthOverride: () async => true,
      );

      final ok = await AccountService.deleteAccount(
        reason: 'Retry after reauth',
      );

      expect(ok, isTrue);
      expect(attempts, 2);
    });

    test('maps firestore data-deletion failure to user-friendly error', () async {
      AccountService.configureForTesting(
        deleteUserDataOverride: (_, __) async {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Service temporarily unavailable',
          );
        },
      );

      expect(
        () => AccountService.deleteAccount(reason: 'Firestore failure test'),
        throwsA(
          predicate(
            (e) => e.toString().contains('Failed to delete account data'),
          ),
        ),
      );
    });
  });
}

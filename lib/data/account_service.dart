import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for user accounts and compliance operations
/// 
/// Handles:
/// - Account deletion (GDPR/PDPA)
/// - Consent submission and history
/// - Direct Firebase Auth/Firestore operations (Spark-friendly)
class AccountService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Future<bool> Function()? _reauthOverride;
  static Future<void> Function(User user)? _deleteAuthUserOverride;
  static Future<void> Function(String userId, String reason)?
      _deleteUserDataOverride;

  @visibleForTesting
  static void configureForTesting({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Future<bool> Function()? reauthOverride,
    Future<void> Function(User user)? deleteAuthUserOverride,
    Future<void> Function(String userId, String reason)? deleteUserDataOverride,
  }) {
    if (auth != null) {
      _auth = auth;
    }
    if (firestore != null) {
      _firestore = firestore;
    }
    if (reauthOverride != null) {
      _reauthOverride = reauthOverride;
    }
    if (deleteAuthUserOverride != null) {
      _deleteAuthUserOverride = deleteAuthUserOverride;
    }
    if (deleteUserDataOverride != null) {
      _deleteUserDataOverride = deleteUserDataOverride;
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _reauthOverride = null;
    _deleteAuthUserOverride = null;
    _deleteUserDataOverride = null;
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
    } catch (_) {
      // In isolated unit tests, Firebase default app may not be initialized.
    }
  }

  /// Current consent version for tracking
  static const String currentConsentVersion = '1.0.0';

  /// Submit user consent to Firestore for compliance.
  static Future<bool> submitConsent({
    required bool accepted,
    String? customVersion,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final version = customVersion ?? currentConsentVersion;
      final timestamp = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('consent')
          .add({
        'version': version,
        'accepted': accepted,
        'timestamp': timestamp,
        'source': 'client',
      });

      await _firestore.collection('users').doc(user.uid).set({
        'consentVersion': version,
        'consented': accepted,
        'lastConsentAccepted': timestamp,
      }, SetOptions(merge: true));

      debugPrint(
        'Consent submitted successfully: $accepted (version $version)',
      );
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      throw Exception('Failed to submit consent: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Error submitting consent: $e');
      rethrow;
    }
  }

  /// Get user's consent history for transparency.
  static Future<List<ConsentRecord>> getConsentHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('consent')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConsentRecord.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      throw Exception('Failed to fetch consent history: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Error fetching consent history: $e');
      rethrow;
    }
  }

  /// Delete user account and associated Firestore data.
  static Future<bool> deleteAccount({
    String reason = 'User requested deletion',
    bool allowReauthRetry = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userId = user.uid;
      debugPrint('Initiating account deletion for user: $userId');

      await _deleteUserData(userId: userId, reason: reason);
      await _deleteAuthUser(user);
      await _auth.signOut();

      debugPrint('Account deleted successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth error: ${e.code} - ${e.message}');
      if (e.code == 'requires-recent-login') {
        if (allowReauthRetry && await _tryReauthenticateCurrentUser()) {
          return deleteAccount(
            reason: reason,
            allowReauthRetry: false,
          );
        }
        throw Exception('Please sign in again before deleting your account.');
      }
      throw Exception('Failed to delete account: ${e.message ?? e.code}');
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      throw Exception('Failed to delete account data: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  static Future<bool> _tryReauthenticateCurrentUser() async {
    if (_reauthOverride != null) {
      return _reauthOverride!();
    }

    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final providers = user.providerData.map((p) => p.providerId).toSet();
    if (!providers.contains('google.com')) {
      return false;
    }

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      debugPrint('Re-authentication successful for user: ${user.uid}');
      return true;
    } catch (e) {
      debugPrint('Re-authentication failed: $e');
      return false;
    }
  }

  static Future<void> _deleteAuthUser(User user) async {
    if (_deleteAuthUserOverride != null) {
      await _deleteAuthUserOverride!(user);
      return;
    }
    await user.delete();
  }

  static Future<void> _deleteUserData({
    required String userId,
    required String reason,
  }) async {
    if (_deleteUserDataOverride != null) {
      await _deleteUserDataOverride!(userId, reason);
      return;
    }

    final userDoc = _firestore.collection('users').doc(userId);

    final sessions = await userDoc.collection('focus_sessions_v2').get();
    for (final doc in sessions.docs) {
      await doc.reference.delete();
    }

    final consents = await userDoc.collection('consent').get();
    for (final doc in consents.docs) {
      await doc.reference.delete();
    }

    await userDoc.set({
      'deletedAt': FieldValue.serverTimestamp(),
      'deleteReason': reason,
    }, SetOptions(merge: true));

    await userDoc.delete();
  }
}

/// Model for consent records
class ConsentRecord {
  final String id;
  final String version;
  final bool accepted;
  final DateTime timestamp;

  ConsentRecord({
    required this.id,
    required this.version,
    required this.accepted,
    required this.timestamp,
  });

  factory ConsentRecord.fromMap(Map<String, dynamic> map) {
    return ConsentRecord(
      id: map['id'] ?? '',
      version: map['version'] ?? '',
      accepted: map['accepted'] ?? false,
      timestamp: _parseTimestamp(map['timestamp']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  @override
  String toString() =>
      'ConsentRecord(version=$version, accepted=$accepted, timestamp=$timestamp)';
}

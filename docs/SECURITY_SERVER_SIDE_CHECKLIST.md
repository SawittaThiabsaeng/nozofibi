Security Server-Side Checklist

Use this as a runbook in Firebase Console and Google Cloud Console.
Scope is based on current repo files: [firestore.rules](../firestore.rules), [firebase.json](../firebase.json), and app startup in [lib/main.dart](../lib/main.dart).

Quick Status Legend
- PASS: Config is enabled exactly as required.
- FAIL: Missing, off, or misconfigured.
- N/A: Service not used by this app.

1) Firebase Authentication Hardening
- Console path: Firebase Console -> Authentication -> Settings
- Check: Email Enumeration Protection is enabled
- Expected: Enabled (PASS)
- Check: Authorized domains only include real domains you use
- Expected: No unused/testing domains in production
- Check: Sign-in methods only include required providers (Email/Google for this app)
- Expected: Unused providers disabled

2) Firebase App Check Hardening
- Console path: Firebase Console -> App Check -> Apps
- Check: Android app uses Play Integrity
- Expected: Provider = Play Integrity
- Check: Web app uses reCAPTCHA v3
- Expected: Provider = reCAPTCHA v3
- Check: App Check enforcement is ON for Firestore/Auth/Functions/Storage that are used
- Expected: Enforced on all used services
- Local code dependency: [lib/main.dart](../lib/main.dart) activates App Check and expects web key via `--dart-define=FIREBASE_APP_CHECK_SITE_KEY=...`

3) Firestore Rules Verification
- Source file: [firestore.rules](../firestore.rules)
- Check: Default deny exists (`match /{document=**}` -> deny)
- Expected: PASS (present)
- Check: User documents restricted to owner (`request.auth.uid == userId`)
- Expected: PASS (present)
- Check: Sensitive collection `deletedUsers` has no client access
- Expected: PASS (present)
- Console path: Firebase Console -> Firestore Database -> Rules
- Action: Publish latest rules from repository before release

4) API Key Restrictions (Google Cloud)
- Console path: Google Cloud Console -> APIs & Services -> Credentials
- Check: Android key restricted by package name + SHA-1
- Expected: Restricted (no unrestricted Android key)
- Check: Web key restricted by HTTP referrers (your domains only)
- Expected: Restricted (no wildcard allow-all)
- Check: API restrictions enabled to required Firebase APIs only
- Expected: Restrict key usage list applied

5) Abuse Prevention and Monitoring
- Console path: Firebase Console -> Authentication -> Usage
- Check: Abnormal spikes in failed sign-in/reset flow
- Expected: Alerting configured in Cloud Monitoring
- Console path: Google Cloud Console -> Monitoring -> Alerting
- Check: Alerts for auth failures and quota anomalies
- Expected: At least one active policy for auth abuse indicators

6) Secrets and Release Controls
- Check: Signing key and `key.properties` are not in repository
- Expected: Keystore external/private, only template tracked
- Check: CI/CD secrets stored in secure secret manager
- Expected: No hardcoded secrets in workflows/scripts

7) Pre-Release Security Gate
- Run: `flutter analyze`
- Run: `flutter test`
- Verify: Account deletion + re-auth flow works end-to-end
- Verify: Consent write/read paths still pass Firestore rules
- Decision: Block release if any FAIL above remains

Optional (If enabled later)
- Firebase Storage: add and publish `storage.rules` with owner-only access.
- Cloud Functions: require App Check token verification and rate limiting for public HTTPS triggers.

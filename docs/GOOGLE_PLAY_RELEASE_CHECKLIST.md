Google Play Release Checklist

Status: Prepared in project, verify items below before uploading AAB.

1) App identity and metadata
- Set unique applicationId in android/app/build.gradle.kts.
- Update app name, descriptions, screenshots, icon, and feature graphic in Play Console.
- Verify version in pubspec.yaml (versionName/versionCode increments).

2) Release signing
- Copy android/key.properties.example to android/key.properties and keep only alias/storeFile there.
- Run once: .\scripts\signing\set_release_signing_secrets.ps1
- For each release shell: . .\scripts\signing\load_release_signing_secrets.ps1
- Verify env vars are present: NOZOFIBI_STORE_PASSWORD / NOZOFIBI_KEY_PASSWORD.
- Place release keystore under android/keystore/ (ignored by git).
- Run: flutter build appbundle --release

3) Security baseline
- Firebase App Check: enabled in app code and enforced in Firebase Console.
- API key restrictions: package name + SHA-1 for Android, domain for Web.
- Confirm release build uses minify/shrinkResources and non-debug signing.

4) Privacy and compliance
- Privacy Policy URL added in Play Console.
	- Recommended stable URL format:
		- `https://<your-hosting-domain>/privacy`
		- `https://<your-hosting-domain>/terms`
	- These map to `/privacy-policy.html` and `/terms-of-service.html` via `firebase.json` redirects.
- Data safety form completed in Play Console.
- In-app consent and delete-data/account flows verified.
- Verify account deletion works with recent-login requirement handling.

5) Legal pages deployment check (Firebase Hosting)
- Build web assets: `flutter build web`
- Deploy hosting: `firebase deploy --only hosting`
- Open and verify both URLs render correctly:
	- `/privacy`
	- `/terms`

6) Quality gates
- flutter pub get
- flutter analyze
- flutter test
- Run smoke tests on at least 1 physical Android device.

7) Upload flow
- Build .aab: flutter build appbundle --release
- Upload AAB to internal testing track first.
- Validate pre-launch report and crash-free metrics.
- Promote to production after test sign-off.

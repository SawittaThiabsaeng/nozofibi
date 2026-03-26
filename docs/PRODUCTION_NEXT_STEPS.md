Production Next Steps

This app is now close to production-ready. Complete these actions before pushing to Google Play production.

1) Android app identity
- Replace applicationId and namespace from com.example.nozofibi to your final package ID.
- Update Firebase Android app configuration in Firebase Console to match final package.
- Download updated google-services.json and replace android/app/google-services.json.

2) Signing and release
- Create android/key.properties from android/key.properties.example.
- Put your keystore in android/keystore/.
- Run scripts/release_preflight.ps1.

3) Firebase hardening
- Enforce App Check for Firebase services used by the app.
- Restrict API keys by package/SHA-1 and web domain where applicable.
- Verify Auth anti-abuse settings and monitoring alerts.

4) Compliance checks
- Verify in-app consent flows for Email and Google sign-in.
- Verify Delete Local Data and Delete Account actions end-to-end.
- Fill Play Console Data Safety accurately.

5) Play Console rollout
- Upload AAB to internal testing first.
- Verify pre-launch report and crash-free behavior.
- Promote to closed testing, then production.

6) Password reset email deliverability (anti-spam)
- Firebase Console > Authentication > Templates: set recognizable sender name and clear reset subject.
- If using custom email sender/domain, configure SPF, DKIM, and DMARC for that domain.
- Keep links on trusted domains only (Firebase Hosting/custom domain already verified).
- Monitor bounce/complaint metrics from your email provider and rotate sender if reputation drops.
- Validate both Thai/English templates and run inbox placement checks on Gmail, Outlook, and iCloud.

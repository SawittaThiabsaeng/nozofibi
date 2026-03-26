Security Server-Side Checklist

This project has client-side hardening updates, but the following controls must be configured server-side to complete production security.

1) Firebase Authentication protection
- Enable Email Enumeration Protection.
- Configure abuse and IP throttling rules in Firebase/Google Cloud.
- Require recent login for sensitive actions.

2) Firebase App Check enforcement
- Turn on App Check enforcement for all used Firebase services.
- Android: Play Integrity provider.
- Web: reCAPTCHA v3 and set RECAPTCHA_SITE_KEY.

3) Backend rate limiting and anomaly detection
- Implement Cloud Functions or API gateway throttling for auth-adjacent endpoints.
- Add monitoring and alerting for unusual login/reset patterns.

4) Secret and key management
- Restrict API keys by package name/SHA-1 and web domain.
- Keep production signing keys and CI secrets outside repository.

5) Security rules
- If Firestore/Storage/Realtime DB are used, enforce least-privilege rules.
- Validate user ownership and deny default broad read/write.

6) Incident readiness
- Add audit logs, failed login dashboards, and rotation procedures.
- Document account recovery and breach response steps.

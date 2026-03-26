1305216 Mobile Application Development Week 7-8-9
Lab Sheet: Refactor-Security-PDPA

Student Name: _______________________
Student ID: _______________________
Project Name: Nozofibi

Objective
Analyze the current app and propose practical improvements in:
1. Code Review (Maintainability & Quality)
2. Security (Protection Against Attacks)
3. Privacy (PDPA Compliance & Ethical Data Use)

---

Part 1: Code Review Analysis
Task: Identify Code Smells & Maintainability Issues

| # | Description | Why It is a Problem | Proposed Solution |
|---|---|---|---|
| 1 | Main file has mixed responsibilities in one place (app theme, auth stream, global state, navigation, profile edit/logout, task mutations) in lib/main.dart (e.g., lines 33, 87, 146, 171, 153). | Hard to test, hard to maintain, and changes can cause side effects across unrelated features. | Split into layers: AppShell (theme + auth gate), NavigationController, TaskController/Repository, ProfileController. Use Provider/Riverpod/BLoC for state and dependency injection. |
| 2 | Login screen is too large and combines validation, auth flows, lockout logic, reset password, social login, and full UI in one file (lib/screens/login_screen.dart, about 722 lines). | Large files increase bug risk and onboarding time. Reuse and testing are difficult. | Extract into modules: auth_service.dart, auth_validators.dart, login_form.dart, social_login_buttons.dart, auth_error_mapper.dart. Keep screen focused on composition only. |
| 3 | Hardcoded UI content and static date values in home/profile screens: "Tuesday, Oct 13" and "NOZOFIBI MASTER • LEVEL 24" in lib/screens/home_view.dart line 75 and lib/screens/profile_view.dart line 83. | Creates misleading UI behavior, not localized, and requires code edits for text changes. | Replace with dynamic values (DateFormat + user stats), and move strings to localization files (ARB). |
| 4 | Resource lifecycle issue: TextEditingController is created in edit profile page but not disposed (lib/screens/edit_profile_page.dart lines 24, 31). | Can cause memory leaks and stale listeners over long sessions/navigation cycles. | Add dispose() and call nameController.dispose(). Follow controller lifecycle pattern across all stateful forms. |
| 5 | Task state is only in-memory list in main navigation: final List<ScheduleTask> _tasks = [] (lib/main.dart line 153). | All tasks are lost on app restart; user trust and data reliability are impacted. | Persist tasks using local DB (Hive/Isar/SQLite) and implement repository pattern + migration strategy. |

Reflection
Which part of your code was hardest to understand and why?
- The hardest part is lib/screens/login_screen.dart because multiple concerns are tightly coupled: UI rendering, validation rules, lockout behavior, Firebase auth mapping, reset password flow, and Google login. A single bug fix requires understanding many branches and states.

---

Part 2: Security Analysis
Task: Identify Security Vulnerabilities

| # | Issue Description | Risk Level | Proposed Solution |
|---|---|---|---|
| 1 | Firebase configuration values (API keys, project IDs, client IDs) are embedded in client app (lib/firebase_options.dart lines 53, 59, 63 and android/app/google-services.json). | Medium | Treat client keys as public identifiers and harden backend: strict Firebase Auth settings, Firestore/Storage security rules, App Check, key restrictions by package/SHA-1/domain, monitoring and quota alerts. |
| 2 | Android release build is signed with debug key (android/app/build.gradle.kts lines 37-40). | High | Configure proper release signing (keystore + secure CI secrets), enable Play App Signing, and separate debug vs release configs. |
| 3 | Brute-force login lock is client-side only (_maxFailedLoginAttempts/_loginLockDuration in lib/screens/login_screen.dart lines 22-23, 125-129). Attackers can bypass by modifying/decompiling app. | High | Enforce server-side/risk-based controls: Firebase blocking functions/Cloud Functions, IP/device throttling, reCAPTCHA/App Check, anomaly detection, and centralized auth rate limiting. |
| 4 | No explicit runtime integrity hardening (certificate pinning / anti-tampering / root-jailbreak response) is visible in app flow. | Medium | Add layered controls: TLS best practices, optional certificate pinning for critical endpoints, root/jailbreak checks with risk response, obfuscation/minification, and security logging. |

Scenario Question
If a hacker decompiles your app, what sensitive data can they access?
- They can read embedded app configuration such as Firebase project metadata, API keys used by client SDK, OAuth client IDs, package names, and app logic (including lockout rules). They should not directly get user passwords from Firebase Auth, but weak backend rules or misconfigured keys can still be abused.

---

Part 3: Privacy & PDPA Analysis
Task: Identify Privacy Risks

| Data Collected | Necessary? | Risk Level | Proposed Action |
|---|---|---|---|
| Email (login/signup in lib/screens/login_screen.dart line 177) | Yes | Medium | Add clear purpose notice before submit: "Used for authentication and account recovery". |
| Password (lib/screens/login_screen.dart line 177) | Yes | High | Explain handling policy (processed by Firebase Auth), do not log/store locally, and show security notice in privacy policy. |
| Full name (validated in lib/screens/login_screen.dart line 72 and UI at line 486; edit profile in lib/screens/edit_profile_page.dart line 140) | Partly | Medium | Make optional where possible; collect display name only if user wants personalization. |
| Profile image (gallery picker in edit profile page) | No/Optional | Medium | Default to avatar and request image only with explicit opt-in and purpose statement. |
| Focus behavior data (session title/duration/date in lib/models/focus_session.dart and lib/data/focus_storage.dart) | Yes | Medium | Define retention period and auto-delete policy; allow user export and delete. |
| Third-party avatar request includes username in URL seed (lib/screens/home_view.dart line 267) | No/Optional | Medium | Avoid sending identifiable seed to third-party or hash/pseudonymize; disclose in policy. |

Guideline Findings (Privacy Auditor View)
- Over-collection risk: Full name and profile picture are not strictly necessary for core timer function.
- Missing consent: Terms/Privacy are only shown in Settings (lib/screens/settings_view.dart lines 23, 28, 70, 77), not explicit acceptance at signup.
- Third-party disclosure gap: External avatar service is not explicitly disclosed in privacy text.

PDPA Compliance Questions
1. What is the purpose of each data collected?
- Email/password: account authentication and recovery.
- Name/profile image: optional personalization.
- Session/task data: productivity analytics and history.

2. Can your system support Right to Erasure (Delete User Data)?
- Partially. Current logout clears local focus storage only (lib/main.dart line 220; lib/data/focus_storage.dart line 153). There is no complete account deletion flow for Firebase Auth/profile data from UI.

3. Are you collecting any Sensitive Data (e.g., health, biometrics)?
- No direct sensitive categories are visible. However, behavioral productivity data can still be personal data and must be governed by purpose, retention, and consent.

Design Improvement
Describe how you will redesign your app to follow Data Minimization, Explicit Consent, Privacy by Design:
- Data Minimization:
  - Make full name/profile image optional.
  - Remove hard dependency on third-party avatar with personal seed.
  - Keep only required task/session fields.
- Explicit Consent:
  - Add consent screen at signup with unchecked checkbox for Terms + Privacy.
  - Add granular toggle for analytics/tracking.
  - Version and timestamp consent records.
- Privacy by Design:
  - Build "Delete My Data" and "Delete Account" in Settings.
  - Add retention controls (e.g., 90/180/365 days).
  - Add in-app data export, audit logs, and transparent third-party disclosures.

---

Part 4: Integrated Solution Plan
Task: Propose Improvements

1. Code Improvement Plan
- Refactor monolithic screens (main/login/analytics) into feature modules + service layer.
- Introduce repository pattern for tasks/sessions with persistent local DB.
- Add unit tests for validators, auth error mapper, and session aggregation logic.
- Add lint rules for max file length and widget/function complexity.

2. Security Hardening Plan
- Replace debug signing in release with secure keystore/CI secret management.
- Apply Firebase App Check + strict backend security rules + API key restrictions.
- Move brute-force protections to server-side controls and anomaly monitoring.
- Add mobile hardening baseline: obfuscation, tamper checks, and secure build pipeline.

3. Privacy Compliance Plan
- Implement explicit consent during signup with PDPA-compliant notices.
- Publish complete privacy policy (purpose, retention, sharing, rights, contact).
- Add user self-service rights: export data, delete local data, delete account.
- Maintain data inventory and periodic privacy impact review.

---

Final Reflection
1. What is the most dangerous mistake AI made in your code?
- Shipping release configuration with debug signing is the most dangerous because it directly weakens production trust and distribution security.

2. Which issue has the highest real-world impact?
- Lack of explicit deletion workflow (Right to Erasure) plus incomplete consent flow has the highest legal and reputational impact under PDPA.

3. If this app goes to production, what could go wrong?
- Account and behavioral data governance could fail compliance checks, users may lose trust due to unclear consent/deletion rights, and security posture may be weak if release signing and backend controls are not hardened.

---

Submission Checklist
- Completed Lab Sheet: Yes
- Minimum 3 Code issues: Covered
- Minimum 3 Security issues: Covered
- Minimum 3 Privacy issues: Covered
- Optional evidence snippets/screenshots: Recommended from referenced files/lines above

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/nozofibi_splash_screen.dart';
import 'screens/main_navigation.dart';
import 'theme/app_theme.dart';
import 'data/language_preference_storage.dart';
import 'data/account_service.dart';
import 'services/notification_service.dart';

// ✅ Consent popup overlay — แสดงทับ MainNavigation
class _ConsentOverlay extends StatefulWidget {
  final User user;
  final Widget child;
  final VoidCallback onDone;

  const _ConsentOverlay({
    required this.user,
    required this.child,
    required this.onDone,
  });

  @override
  State<_ConsentOverlay> createState() => _ConsentOverlayState();
}

class _ConsentOverlayState extends State<_ConsentOverlay> {
  bool _accepted = false;
  bool _marketingOptIn = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConsentDialog();
    });
  }

  // ✅ แสดงเนื้อหา Privacy Policy หรือ Terms of Service
  void _showPolicyDialog(BuildContext ctx, {required bool isPrivacy}) {
    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPrivacy ? 'นโยบายความเป็นส่วนตัว' : 'ข้อกำหนดการใช้งาน',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Last updated: April 9, 2026',
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Text(
                    isPrivacy ? _privacyPolicyText : _termsOfServiceText,
                    style:
                        const TextStyle(height: 1.6, fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ปิด',
                      style: TextStyle(color: Color(0xFF8B5CF6))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConsentDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  color: Color(0xFFA78BFA), size: 28),
              SizedBox(width: 10),
              Text('ความยินยอม',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'แอปเก็บข้อมูลที่จำเป็นเพื่อให้บริการ authentication, reminders และ analytics เท่านั้น',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 16),

              // Terms (Required)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (v) =>
                        setDialogState(() => _accepted = v ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text('ยอมรับ '),
                        GestureDetector(
                          onTap: () =>
                              _showPolicyDialog(ctx, isPrivacy: true), // ✅
                          child: const Text(
                            'นโยบายความเป็นส่วนตัว',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(' และ '),
                        GestureDetector(
                          onTap: () =>
                              _showPolicyDialog(ctx, isPrivacy: false), // ✅
                          child: const Text(
                            'ข้อกำหนดการใช้งาน',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('จำเป็น',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Marketing (Optional)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _marketingOptIn,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (v) =>
                        setDialogState(() => _marketingOptIn = v ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text('รับข้อเสนอและข่าวสาร '),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ไม่บังคับ',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('ปฏิเสธ',
                  style: TextStyle(color: Colors.black45)),
            ),
            ElevatedButton(
              onPressed: _accepted && !_loading
                  ? () async {
                      setDialogState(() => _loading = true);
                      try {
                        await AccountService.submitConsent(
                          uid: widget.user.uid,
                          accepted: true,
                          marketingOptIn: _marketingOptIn,
                        );
                        await NotificationService
                            .requestPermissionIfNeeded();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        widget.onDone();
                      } catch (_) {
                        setDialogState(() => _loading = false);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('ยืนยัน',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: widget.child,
      );
}

// ===========================
// MyAppBootstrap
// ===========================

class MyAppBootstrap extends StatefulWidget {
  const MyAppBootstrap({super.key});

  @override
  State<MyAppBootstrap> createState() => _MyAppBootstrapState();
}

class _MyAppBootstrapState extends State<MyAppBootstrap> {
  bool _showSplash = true;
  bool _hasConsent = false;
  ThemeMode _themeMode = ThemeMode.light;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(LanguagePreferenceStorage.getLanguage());
    _hideSplash();
  }

  Future<void> _hideSplash() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _showSplash = false);
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void updateLanguage(String code) {
    final normalized = code.toLowerCase();
    setState(() => _locale = Locale(normalized));
    unawaited(LanguagePreferenceStorage.setLanguage(normalized));
  }

  String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(isDarkMode: false),
      darkTheme: AppTheme.getTheme(isDarkMode: true),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('th')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (innerContext) {
          if (_showSplash) return const NozofibiSplashScreen();

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (innerContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final user = snapshot.data;
              if (user == null) return LoginScreen();

              if (_hasConsent) {
                return MainNavigation(
                  userName: _displayName(user),
                  onToggleDarkMode: toggleTheme,
                  onLanguageChanged: updateLanguage,
                );
              }

              return FutureBuilder<bool>(
                future: AccountService.hasConsent(user.uid),
                builder: (context, consentSnapshot) {
                  if (consentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final hasConsent = consentSnapshot.data ?? false;

                  if (hasConsent) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _hasConsent = true);
                    });
                    return MainNavigation(
                      userName: _displayName(user),
                      onToggleDarkMode: toggleTheme,
                      onLanguageChanged: updateLanguage,
                    );
                  }

                  return _ConsentOverlay(
                    user: user,
                    onDone: () {
                      if (mounted) setState(() => _hasConsent = true);
                    },
                    child: MainNavigation(
                      userName: _displayName(user),
                      onToggleDarkMode: toggleTheme,
                      onLanguageChanged: updateLanguage,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ===========================
// Policy Text
// ===========================

const String _privacyPolicyText = """
1. Information We Collect
We may collect account details (name, email, login identifiers) and app data (tasks, reminders, schedule, settings).

2. How We Process Information
We process data to provide app features, authentication, sync, security, troubleshooting, and service improvement.

3. Legal Bases
Where required, we rely on consent, contract performance, legitimate interests, and legal obligations.

4. Sharing of Personal Information
We may share data with service providers necessary for operation (for example Firebase services).

5. Social Logins
If you use Google sign-in, we receive limited profile/account data for authentication.

6. International Transfers
Your data may be processed in countries outside your own depending on provider infrastructure.

7. Data Retention
We retain data only as long as needed for service operation, legal compliance, and security.

8. Data Security
We apply appropriate technical and organizational safeguards, but no system is 100% secure.

9. Your Privacy Rights
You may request access, correction, deletion, or restriction as permitted by applicable law.

10. Do-Not-Track
Because no unified DNT standard exists, we currently do not respond to DNT browser signals.

11. US State Privacy Rights
Residents of certain US states may have additional rights under applicable laws.

12. Policy Updates
We may update this notice from time to time and show the latest updated date in the policy.

13. Contact
Email: nozofibi@gmail.com

14. Review, Update, or Delete Data
You can request data review/update/deletion via in-app controls or email.
Website: https://nozofibi.web.app/privacy
""";

const String _termsOfServiceText = """
1. Our Services
Nozofibi provides focus, scheduling, reminders, and mood-support features for personal use.

2. Intellectual Property Rights
All app content, code, design, and trademarks are owned by or licensed to Nozofibi.

3. User Representations
You confirm you can legally agree to these terms and will provide accurate account information.

4. Prohibited Activities
Do not misuse the app, access systems without authorization, upload harmful content, or violate laws.

5. User Generated Contributions
You are responsible for data/content you submit and must have rights to submit it.

6. Contribution License
You allow us to process submitted data as needed to operate and improve the Services.

7. Services Management
We may monitor misuse, remove violating content, and take actions to protect security.

8. Term and Termination
These terms apply while you use the app. Access may be suspended or terminated for violations.

9. Modifications and Interruptions
Features may change, pause, or be discontinued. Availability is not guaranteed at all times.

10. Governing Law
These terms are governed by Thai law unless mandatory local law applies.

11. Dispute Resolution
Please contact us first for good-faith resolution before formal legal action.

12. Corrections
We may correct errors, omissions, or outdated information without prior notice.

13. Disclaimer
Services are provided "as is" and "as available" without warranties.

14. Limitation of Liability
To the maximum extent allowed by law, we are not liable for indirect or consequential damages.

15. Indemnification
You agree to indemnify us for claims arising from your misuse or violation of these terms.

16. User Data
You are responsible for data you transmit; we use reasonable safeguards and backups.

17. Electronic Communications
You consent to receiving notices and communications electronically.

18. Miscellaneous
If part of these terms is invalid, remaining sections stay in effect.

19. Contact Us
Email: nozofibi@gmail.com
Website: https://nozofibi.web.app/terms
""";
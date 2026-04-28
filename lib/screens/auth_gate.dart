import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/login_screen.dart';
import '../screens/main_navigation.dart';
import '../data/account_service.dart';
import '../screens/consent_screen.dart';

import '../data/language_preference_storage.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Locale _appLocale;
  Future<bool>? _consentFuture;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _appLocale = Locale(LanguagePreferenceStorage.getLanguage());
  }

  void _updateLanguage(String languageCode) {
    final normalized = languageCode.toLowerCase();
    setState(() {
      _appLocale = Locale(normalized);
    });
    LanguagePreferenceStorage.setLanguage(normalized);
  }

  String _displayName(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return user.uid.substring(0, 6);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: _appLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.getTheme(isDarkMode: false),
      darkTheme: AppTheme.getTheme(isDarkMode: true),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          // 🔵 Firebase ยังโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 🔴 ยังไม่ login
          if (user == null) {
            _lastUid = null;
            _consentFuture = null;
            return LoginScreen(
              onLogin: (user) async {
                await NotificationService.requestPermissionIfNeeded();
              },
            );
          }

          // ✅ โหลด consent future เมื่อ uid เปลี่ยน
          if (_lastUid != user.uid) {
            _lastUid = user.uid;
            _consentFuture = AccountService.hasConsent(user.uid);
          }

          return FutureBuilder<bool>(
            future: _consentFuture,
            builder: (context, consentSnapshot) {
              if (!consentSnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final hasConsent = consentSnapshot.data!;

              if (!hasConsent) {
                // ✅ key: ValueKey บังคับให้สร้าง ConsentScreen ใหม่ทุกครั้ง
                return ConsentScreen(
                  key: ValueKey(user.uid),
                  user: user,
                  onDone: () {
                    setState(() {
                      _consentFuture = AccountService.hasConsent(user.uid);
                    });
                  },
                );
              }

              return MainNavigation(
                userName: _displayName(user),
                onToggleDarkMode: (isDark) {},
                onLanguageChanged: _updateLanguage,
              );
            },
          );
        },
      ),
    );
  }
}

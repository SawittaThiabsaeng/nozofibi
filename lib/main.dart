import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'data/app_local_db.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/account_service.dart';
import 'data/focus_storage.dart';
import 'data/language_preference_storage.dart';
import 'firebase_options.dart';
import 'l10n/app_strings.dart';
import 'providers/study_session_provider.dart';
import 'providers/task_provider.dart';
import 'screens/analytics_emotions_view.dart';
import 'screens/analytics_view.dart';
import 'screens/edit_profile_page.dart';
import 'screens/home_view.dart';
import 'screens/login_screen.dart';
import 'screens/nozofibi_splash_screen.dart';
import 'screens/profile_view.dart';
import 'screens/schedule_view.dart';
import 'screens/settings_view.dart';
import 'screens/timer_view.dart';
import 'services/app_logger.dart';
import 'theme/app_theme.dart';
import 'data/emotion_checkin_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalDb.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _configureAppCheck();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StudySessionProvider(),
        ),
      ],
      child: const ProductivityApp(),
    ),
  );
}

Future<void> _configureAppCheck() async {
  if (kIsWeb) {
    const webSiteKey = String.fromEnvironment('FIREBASE_APP_CHECK_SITE_KEY');
    if (webSiteKey.isEmpty) {
      AppLogger.warn(
          'Firebase App Check web site key missing; skipping web activation');
      return;
    }

    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(webSiteKey),
    );
    return;
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
}

class ProductivityApp extends StatefulWidget {
  const ProductivityApp({super.key});

  @override
  State<ProductivityApp> createState() => _ProductivityAppState();
}

class _ProductivityAppState extends State<ProductivityApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late Locale _appLocale;
  bool _showSplash = true;

  String _displayNameFromUser(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  @override
  void initState() {
    super.initState();
    _appLocale = Locale(LanguagePreferenceStorage.getLanguage());
    unawaited(_dismissSplashAfterDelay());
  }

  Future<void> _dismissSplashAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) {
      return;
    }
    setState(() {
      _showSplash = false;
    });
  }

  void toggleTheme({required bool isDark}) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void updateLanguage(String languageCode) {
    final normalizedCode = languageCode.toLowerCase();
    setState(() {
      _appLocale = Locale(normalizedCode);
    });
    unawaited(LanguagePreferenceStorage.setLanguage(normalizedCode));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        themeAnimationDuration: const Duration(milliseconds: 350),
        themeAnimationCurve: Curves.easeInOutCubic,
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
        home: _showSplash
            ? const NozofibiSplashScreen()
            : StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = snapshot.data;
                  if (user == null) {
                    return LoginScreen();
                  }

                  return MainNavigation(
                    userName: _displayNameFromUser(user),
                    onToggleDarkMode: (isDark) => toggleTheme(isDark: isDark),
                    onLanguageChanged: updateLanguage,
                  );
                },
              ),
      );
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    required this.userName,
    required this.onToggleDarkMode,
    required this.onLanguageChanged,
    super.key,
    this.onSignOut,
  });
  final String userName;
  final ValueChanged<bool> onToggleDarkMode;
  final Function(String) onLanguageChanged;
  final Future<void> Function()? onSignOut;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _analyticsRefreshToken = 0;

  late String _profileName;
  XFile? _profileImage;
  late final List<Widget?> _screenCache;

  Future<void> _signOutAndReturnToAuthGate() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      AppLogger.warn('Sign out failed');
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await _confirmSignOut();
    if (!confirmed) {
      return;
    }

    final customSignOut = widget.onSignOut;
    if (customSignOut != null) {
      await customSignOut();
      return;
    }
    await _signOutAndReturnToAuthGate();
  }

  Future<bool> _confirmSignOut() async {
    final s = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.signOut),
        content: Text(s.pick('Are you sure you want to sign out?',
            'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.signOut),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  @override
  void initState() {
    super.initState();
    _profileName = widget.userName;
    _screenCache = List<Widget?>.filled(5, null);
    unawaited(context.read<TaskProvider>().load());
    unawaited(context.read<StudySessionProvider>().loadSessions());
  }

  @override
  void didUpdateWidget(covariant MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userName != oldWidget.userName &&
        widget.userName != _profileName) {
      setState(() {
        _profileName = widget.userName;
        _screenCache[0] = null;
        _screenCache[4] = null;
      });
    }
  }

  Future<void> _updateFirebaseDisplayName(String rawName) async {
    try {
      final nextName = rawName.trim();
      if (nextName.isEmpty) {
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final current = user.displayName?.trim() ?? '';
      if (current == nextName) {
        return;
      }

      await user.updateDisplayName(nextName);
      await user.reload();
    } catch (e) {
      AppLogger.warn('Unable to update Firebase display name');
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeView(
          userName: _profileName,
          profileImage: _profileImage,
          onOpenEmotionAnalytics: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalyticsEmotionsView(),
              ),
            ).then((_) {
              if (!mounted) {
                return;
              }
              setState(() {
                // Rebuild Home so Current Mood fetches the latest check-in immediately.
                _screenCache[0] = null;
              });
            });
          },
        );
      case 1:
        return TimerView(
          onSaved: () {
            setState(() {
              _analyticsRefreshToken++;
              _screenCache[3] = null;
              _currentIndex = 3;
            });
          },
        );
      case 2:
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, _) => ScheduleView(
            tasks: taskProvider.tasks,
            onSessionSaved: () {
              setState(() {
                _analyticsRefreshToken++;
                _screenCache[3] = null;
              });
            },
            onAddTask: (task) {
              taskProvider.addTask(task);
            },
            onToggle: (id) {
              taskProvider.toggleTask(id);
            },
            onDelete: (id) {
              taskProvider.deleteTask(id);
            },
          ),
        );
      case 3:
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, _) => AnalyticsView(
            tasks: taskProvider.tasks,
            refreshToken: _analyticsRefreshToken,
          ),
        );
      case 4:
      default:
        return ProfileView(
          userName: _profileName,
          profileImage: _profileImage,
          onLogout: () {
            unawaited(_handleSignOut());
          },
          onGoSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsView(
                  onBack: () => Navigator.pop(context),
                  onThemeChanged: widget.onToggleDarkMode,
                  onDeleteMyData: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final taskProvider = context.read<TaskProvider>();
                      await Future.wait([
                        Hive.box<String>(AppLocalDb.sessionsBox).clear(),
                        Hive.box<String>(AppLocalDb.tasksBox).clear(),
                        Hive.box<String>(AppLocalDb.privacyBox).clear(),
                        Hive.box(AppLocalDb.profileBox).clear(),
                        FocusStorage.clear(),
                        taskProvider.clearAll(),
                        EmotionCheckinStorage.clear(),
                      ]);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('ลบข้อมูลในเครื่องแล้ว')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('ลบข้อมูลไม่สำเร็จ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onDeleteAccount: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final taskProvider = context.read<TaskProvider>();
                      await FocusStorage.clear();
                      await taskProvider.clearAll();
                      await AccountService.deleteAccount();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('ลบบัญชีไม่สำเร็จ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onLanguageChanged: widget.onLanguageChanged,
                ),
              ),
            );
          },
          onEditProfile: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(
                  currentName: _profileName,
                  currentImage: _profileImage, // ❗ ตรงนี้ถ้าเป็น Web จะพัง
                ),
              ),
            );

            if (result != null) {
              final updatedName = (result['name'] as String? ?? '').trim();
              unawaited(_updateFirebaseDisplayName(updatedName));
              HomeView.invalidateProfileImageCache();
              setState(() {
                _profileName =
                    updatedName.isNotEmpty ? updatedName : _profileName;
                _profileImage = result['image'];
                _screenCache[0] = null;
                _screenCache[4] = null;
              });
            }
          },
          onToggleDarkMode: widget.onToggleDarkMode,
        );
    }
  }

  List<Widget> _buildIndexedChildren() => List<Widget>.generate(5, (index) {
        final cached = _screenCache[index];
        if (cached != null) {
          return cached;
        }

        if (index != _currentIndex) {
          return const SizedBox.shrink();
        }

        final screen = _buildScreen(index);
        _screenCache[index] = screen;
        return screen;
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _buildIndexedChildren(),
            ),
            Positioned(
              bottom: 30 + MediaQuery.of(context).padding.bottom,
              left: 20,
              right: 20,
              child: CustomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ],
        ),
      );
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <IconData>[
      Icons.home_rounded,
      Icons.timer_outlined,
      Icons.calendar_today_rounded,
      Icons.bar_chart_rounded,
      Icons.person_rounded,
    ];
    final labels = <String>[
      AppStrings.of(context).navHome,
      AppStrings.of(context).navTimer,
      AppStrings.of(context).navSchedule,
      AppStrings.of(context).navInsights,
      AppStrings.of(context).navProfile,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          const activeColor = Color(0xFF8B5CF6);
          final inactiveColor =
              isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selected ? activeColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        items[index],
                        size: 20,
                        color: selected ? Colors.white : inactiveColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? activeColor : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

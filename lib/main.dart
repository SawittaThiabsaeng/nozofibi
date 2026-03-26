import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'data/focus_storage.dart';
import 'data/language_preference_storage.dart';
import 'data/app_local_db.dart';
import 'firebase_options.dart';
import 'screens/home_view.dart';
import 'screens/login_screen.dart';
import 'screens/timer_view.dart';
import 'screens/schedule_view.dart';
import 'screens/analytics_view.dart';
import 'screens/analytics_emotions_view.dart';
import 'screens/profile_view.dart';
import 'screens/edit_profile_page.dart';
import 'screens/settings_view.dart';
import 'providers/task_provider.dart';
import 'providers/study_session_provider.dart';
import 'l10n/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalDb.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

class ProductivityApp extends StatefulWidget {
  const ProductivityApp({super.key});

  @override
  State<ProductivityApp> createState() => _ProductivityAppState();
}

class _ProductivityAppState extends State<ProductivityApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late Locale _appLocale;

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
  }

  void toggleTheme(bool isDark) {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
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

      /// 🌞 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: const Color(0xFFF6F4FA),
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.light,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),

      /// 🌙 DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),

      home: StreamBuilder<User?>(
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
            onToggleDarkMode: toggleTheme,
            onLanguageChanged: updateLanguage,
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String userName;
  final Function(bool) onToggleDarkMode;
  final Function(String) onLanguageChanged;

  const MainNavigation({
    super.key,
    required this.userName,
    required this.onToggleDarkMode,
    required this.onLanguageChanged,
  });

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
      debugPrint('Sign out failed: $e');
    }
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
    if (widget.userName != oldWidget.userName && widget.userName != _profileName) {
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
      debugPrint('Unable to update Firebase display name: $e');
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
            unawaited(_signOutAndReturnToAuthGate());
          },
          onGoSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsView(
                  onBack: () => Navigator.pop(context),
                  onThemeChanged: widget.onToggleDarkMode,
                  onDeleteMyData: () async {
                    final taskProvider = context.read<TaskProvider>();
                    await FocusStorage.clear();
                    await taskProvider.clearAll();
                  },
                  onDeleteAccount: () async {
                    final taskProvider = context.read<TaskProvider>();
                    await FocusStorage.clear();
                    await taskProvider.clearAll();
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
              setState(() {
                _profileName = updatedName.isNotEmpty ? updatedName : _profileName;
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

  List<Widget> _buildIndexedChildren() {
    return List<Widget>.generate(5, (index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _buildIndexedChildren(),
          ),
          Positioned(
            bottom: 30,
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
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
          final activeColor = const Color(0xFF8B5CF6);
          final inactiveColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

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
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
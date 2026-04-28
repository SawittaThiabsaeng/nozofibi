import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/app_local_db.dart';
import '../data/account_service.dart';
import '../data/focus_storage.dart';
import '../data/emotion_checkin_storage.dart';
import '../providers/task_provider.dart';
import '../providers/study_session_provider.dart';
import '../screens/analytics_emotions_view.dart';
import '../screens/analytics_view.dart';
import '../screens/edit_profile_page.dart';
import '../screens/home_view.dart';
import '../screens/profile_view.dart';
import '../screens/schedule_view.dart';
import '../screens/settings_view.dart';
import '../screens/timer_view.dart';
import '../services/app_logger.dart';
import '../services/notification_service.dart';
import '../l10n/app_strings.dart';

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
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _profileName = widget.userName;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      context.read<TaskProvider>().load();
      context.read<StudySessionProvider>().loadSessions();

      await TaskProvider.initNotifications();

      NotificationService.requestPermissionIfNeeded();
    });
  }

  Future<void> _signOutAndReturnToAuthGate() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (e) {
      AppLogger.warn('Sign out failed');
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await _confirmSignOut();
    if (!confirmed) return;

    final custom = widget.onSignOut;
    if (custom != null) {
      await custom();
      return;
    }

    await _signOutAndReturnToAuthGate();
  }

  Future<bool> _confirmSignOut() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            key: const Key('cancelSignOutButton'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirmSignOutButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _updateFirebaseDisplayName(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final next = name.trim();
    if (next.isEmpty) return;

    if ((user.displayName ?? '') == next) return;

    await user.updateDisplayName(next);
    await user.reload();
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
            );
          },
        );

      case 1:
        return TimerView(
          onSaved: () {
            setState(() {
              _analyticsRefreshToken++;
              _currentIndex = 3;
            });
          },
        );

      case 2:
        return Consumer<TaskProvider>(
          builder: (_, taskProvider, __) => ScheduleView(
            tasks: taskProvider.tasks,
            onSessionSaved: () => setState(() => _analyticsRefreshToken++),
            onAddTask: (
              task, {
              required String alertTitle,
              required String localeTag,
            }) async {
              await taskProvider.addTask(
                task,
                alertTitle: alertTitle,
                localeTag: localeTag,
              );
            },
            onToggle: taskProvider.toggleTask,
            onDelete: taskProvider.deleteTask,
            onUpdateTask: (updated,
                {required String alertTitle,
                required String localeTag}) async {
              await taskProvider.updateTask(
                updated,
                alertTitle: alertTitle,
                localeTag: localeTag,
              );
            },
          ),
        );

      case 3:
        return Consumer<TaskProvider>(
          builder: (_, taskProvider, __) => AnalyticsView(
            tasks: taskProvider.tasks,
            refreshToken: _analyticsRefreshToken,
          ),
        );

      case 4:
      default:
        return ProfileView(
          userName: _profileName,
          profileImage: _profileImage,
          onLogout: _handleSignOut,
          onGoSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsView(
                  onBack: () => Navigator.pop(context),
                  onThemeChanged: widget.onToggleDarkMode,
                  onDeleteMyData: () async {
                    await FocusStorage.clear();
                    await EmotionCheckinStorage.clear();
                    await Hive.box<String>(AppLocalDb.sessionsBox).clear();
                    await Hive.box<String>(AppLocalDb.tasksBox).clear();
                    await Hive.box<String>(AppLocalDb.privacyBox).clear();
                    await Hive.box(AppLocalDb.profileBox).clear();
                  },
                  onDeleteAccount: () async {
                    await FocusStorage.clear();
                    await EmotionCheckinStorage.clear();
                    await AccountService.deleteAccount();

                    if (context.mounted) {
                      Navigator.of(context).popUntil((r) => r.isFirst);
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
                  currentImage: kIsWeb ? null : _profileImage,
                ),
              ),
            );

            if (result != null) {
              final name = (result['name'] ?? '').toString().trim();

              await _updateFirebaseDisplayName(name);

              setState(() {
                _profileName = name.isNotEmpty ? name : _profileName;
                _profileImage = result['image'];
                _profileImageBytes = result['imageBytes'];
              });
            }
          },
          onToggleDarkMode: widget.onToggleDarkMode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);

    return Scaffold(
      extendBody: false, // ปิด extendBody เพราะไม่ต้องการให้ body ลอดใต้ nav bar
      body: IndexedStack(
        index: _currentIndex,
        clipBehavior: Clip.hardEdge,
        children: List.generate(5, (i) => _buildScreen(i)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.3,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.home_outlined, s.navHome, isDark),
                _navItem(1, Icons.timer_outlined, s.navTimer, isDark),
                _navItem(2, Icons.calendar_today_outlined, s.navSchedule, isDark),
                _navItem(3, Icons.bar_chart_outlined, s.navInsights, isDark),
                _navItem(4, Icons.person_outline, s.navProfile, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, bool isDark) {
    final isActive = _currentIndex == index;
    const activeColor = Color(0xFF8B5CF6);
    final inactiveColor = isDark ? Colors.white54 : Colors.black45;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

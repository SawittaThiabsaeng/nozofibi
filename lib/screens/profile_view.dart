import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import '../data/profile_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../l10n/app_strings.dart';
import '../models/focus_session.dart';
import '../providers/study_session_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.userName,
    required this.profileImage,
    required this.onLogout,
    required this.onGoSettings,
    required this.onEditProfile,
    required this.onToggleDarkMode,
  });

  final String userName;
  final XFile? profileImage;

  final VoidCallback onLogout;
  final VoidCallback onGoSettings;
  final VoidCallback onEditProfile;
  final Function(bool) onToggleDarkMode;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Uint8List? _savedProfileImage;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    try {
      final savedImage = await ProfileStorage.loadProfileImage();
      if (!mounted) return;
      setState(() {
        _savedProfileImage = savedImage;
        _loadingImage = false;
      });
    } catch (e) {
      debugPrint('Error loading saved profile image: $e');
      if (!mounted) return;
      setState(() {
        _loadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final sessions = context.select<StudySessionProvider, List<FocusSession>>(
      (provider) => provider.sessions,
    );
    final streakDays = _calculateStreakDays(sessions);

    final textColor =
        isDark ? Colors.white : AppTheme.textDark;



    return SoftBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
        children: [
        /// PROFILE HEADER
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        isDark ? Colors.grey[900] : Colors.white,
                    child: ClipOval(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _buildProfileImage(),
                      ),
                    ),
                  ),
                  if (streakDays > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streakDays',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.userName,
                style: AppTheme.h1.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                s.currentStreak(streakDays),
                style: AppTheme.caption.copyWith(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Text(
          s.systemSettings,
          style: AppTheme.h1.copyWith(
              fontSize: 18, color: textColor),
        ),
        const SizedBox(height: 16),

        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _tile(
                Icons.edit_outlined,
                s.editProfile,
                textColor,
                tap: widget.onEditProfile,
              ),
              _tile(
                Icons.settings_outlined,
                s.accountSettings,
                textColor,
                tap: widget.onGoSettings,
              ),
              _darkModeTile(context, textColor),
              _tile(
                Icons.logout,
                s.signOut,
                Colors.redAccent,
                isLast: true,
                tap: widget.onLogout,
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  /// ✅ Profile Image Fix (Full Circle + Web + Mobile)
  /// Build profile image from saved storage or current profileImage
  /// Priority: Saved image > Current profileImage > Default avatar
  Widget _buildProfileImage() {
    // Show saved image from secure storage (persists across restarts)
    if (!_loadingImage && _savedProfileImage != null) {
      return Image.memory(
        _savedProfileImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Show loading indicator while fetching saved image
    if (_loadingImage) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Fallback to current profileImage if available
    if (widget.profileImage != null) {
      if (kIsWeb) {
        return Image.network(
          widget.profileImage!.path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            );
          },
        );
      }

      return Image.file(
        File(widget.profileImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            size: 60,
            color: Colors.grey,
          );
        },
      );
    }

    // Default avatar if no image exists
    return Image.network(
      'https://api.dicebear.com/7.x/avataaars/svg?seed=User',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.person,
          size: 60,
          color: Colors.grey,
        );
      },
    );
  }

  Widget _darkModeTile(BuildContext context, Color textColor) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.dark_mode_outlined,
          color: AppTheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        AppStrings.of(context).darkMode,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: widget.onToggleDarkMode,
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    Color textColor, {
    bool isLast = false,
    VoidCallback? tap,
  }) {
    return ListTile(
      onTap: tap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }

  int _calculateStreakDays(List<FocusSession> sessions) {
    if (sessions.isEmpty) {
      return 0;
    }

    final completedDays = <DateTime>{
      for (final session in sessions)
        DateTime(session.date.year, session.date.month, session.date.day),
    };

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    // Active streak only: if user has not read today, streak resets immediately.
    if (!completedDays.contains(cursor)) {
      return 0;
    }

    var streak = 0;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}


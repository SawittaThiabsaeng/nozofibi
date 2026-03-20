import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ProfileView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor =
        isDark ? Colors.white : AppTheme.textDark;

    final mutedColor =
        isDark ? Colors.white70 : AppTheme.textMuted;

    return ListView(
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: AppTheme.h1.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'NOZOFIBI MASTER • LEVEL 24',
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        Text(
          "System Settings",
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
                "Edit Profile",
                textColor,
                tap: onEditProfile,
              ),
              _tile(
                Icons.settings_outlined,
                "Account Settings",
                textColor,
                tap: onGoSettings,
              ),
              _darkModeTile(context, textColor),
              _tile(
                Icons.logout,
                "Sign Out",
                Colors.redAccent,
                isLast: true,
                tap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Profile Image Fix (Full Circle + Web + Mobile)
  Widget _buildProfileImage() {
    if (profileImage == null) {
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

    if (kIsWeb) {
      return Image.network(
        profileImage!.path,
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
      File(profileImage!.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
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
        "Dark Mode",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: onToggleDarkMode,
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
}
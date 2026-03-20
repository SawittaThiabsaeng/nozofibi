import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onNavigateToSchedule,
    required this.userName,
    required this.profileImage, // ✅ รับรูปจาก MainNavigation
  });

  final VoidCallback onNavigateToSchedule;
  final String userName;
  final XFile? profileImage;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: isDark ? AppTheme.darkGradient : null,
        child: SoftBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
            children: [

              /// 🔹 TOP SECTION
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              Theme.of(context).cardColor,
                          child: ClipOval(
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: _buildProfileImage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, $userName',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: isDark
                                    ? AppTheme.h1.copyWith(
                                        color: Colors.white)
                                    : AppTheme.h1.copyWith(
                                        color:
                                            AppTheme.textDark,
                                      ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tuesday, Oct 13',
                                style:
                                    AppTheme.caption.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_none,
                    color: isDark
                        ? Colors.white70
                        : Colors.black26,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 🔹 DAILY PLAN CARD
              GlassCard(
                onTap: onNavigateToSchedule,
                padding: EdgeInsets.zero,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primary,
                        Color(0xFF60A5FA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 180,
                          color:
                              Colors.white.withOpacity(0.1),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius:
                                    BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  'DAILY PLAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Reading Schedule',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            Spacer(),
                            Row(
                              children: [
                                Text(
                                  'Manage Plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 WELLNESS TITLE
              Text(
                'Wellness Metrics',
                style: isDark
                    ? AppTheme.h2.copyWith(
                        color: Colors.white)
                    : AppTheme.h2.copyWith(
                        color: AppTheme.textDark),
              ),

              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;

                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth >
                      600) {
                    crossAxisCount = 3;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _metric(context,
                          Icons.nights_stay,
                          'SLEEP',
                          '7.2h',
                          const Color(0xFF60A5FA)),
                      _metric(context,
                          Icons.local_fire_department,
                          'STREAK',
                          '15d',
                          Colors.orangeAccent),
                      _metric(context,
                          Icons.center_focus_strong,
                          'FOCUS',
                          '3.1h',
                          AppTheme.primary),
                      _metric(context,
                          Icons.bolt,
                          'ENERGY',
                          'High',
                          Colors.amber),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ ฟังก์ชันสร้างรูปโปรไฟล์ (รองรับ Web + Mobile)
  Widget _buildProfileImage() {
    if (profileImage == null) {
      return Image.network(
        'https://api.dicebear.com/7.x/avataaars/png?seed=$userName',
        fit: BoxFit.cover,
      );
    }

    if (kIsWeb) {
      return Image.network(
        profileImage!.path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 40),
      );
    }

    return Image.file(
      File(profileImage!.path),
      fit: BoxFit.cover,
    );
  }

  Widget _metric(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color) {

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: isDark
                      ? Colors.white60
                      : AppTheme.textMuted,
                ),
              ),
              Text(
                value,
                style: isDark
                    ? AppTheme.h2.copyWith(
                        color: Colors.white)
                    : AppTheme.h2.copyWith(
                        color:
                            AppTheme.textDark,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
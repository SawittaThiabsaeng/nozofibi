import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeView extends StatelessWidget {

  const HomeView({super.key, required this.onNavigateToSchedule, this.isDarkMode = false});
  final VoidCallback onNavigateToSchedule;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 150),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white, child: ClipOval(child: Image.network('https://api.dicebear.com/7.x/avataaars/svg?seed=Alex'))),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good morning, Alex', style: isDarkMode ? AppTheme.h1.copyWith(color: Colors.white) : AppTheme.h1),
                Text('Tuesday, Oct 13', style: AppTheme.caption),
              ]),
            ]),
            Icon(Icons.notifications_none, color: isDarkMode ? Colors.white24 : Colors.black12),
          ],
        ),
        const SizedBox(height: 32),
        GlassCard(
          onTap: onNavigateToSchedule,
          padding: EdgeInsets.zero,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(children: [
              Positioned(right: -10, top: -10, child: Icon(Icons.auto_stories_rounded, size: 180, color: Colors.white.withOpacity(0.1))),
              Padding(padding: const EdgeInsets.all(32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('DAILY PLAN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),
                const Text('Reading Schedule', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                const Spacer(),
                const Row(children: [Text('Manage Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 32),
        Text('Wellness Metrics', style: isDarkMode ? AppTheme.h2.copyWith(color: Colors.white) : AppTheme.h2),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _metric(Icons.nights_stay, 'SLEEP', '7.2h', const Color(0xFF60A5FA), isDarkMode),
            _metric(Icons.local_fire_department, 'STREAK', '15d', Colors.orangeAccent, isDarkMode),
            _metric(Icons.center_focus_strong, 'FOCUS', '3.1h', AppTheme.primary, isDarkMode),
            _metric(Icons.bolt, 'ENERGY', 'High', Colors.amber, isDarkMode),
          ],
        ),
      ],
    );

  Widget _metric(IconData i, String l, String v, Color c, bool dark) => GlassCard(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(i, color: c),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: AppTheme.caption),
        Text(v, style: dark ? AppTheme.h2.copyWith(color: Colors.white) : AppTheme.h2),
      ])
    ]),
  );
}


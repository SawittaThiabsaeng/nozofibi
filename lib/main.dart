import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/task.dart';
import 'screens/home_view.dart';
import 'screens/timer_view.dart';
import 'screens/schedule_view.dart';
import 'screens/analytics_view.dart';
import 'screens/profile_view.dart';
import 'widgets/glass_card.dart';

void main() => runApp(const NozofibiApp());

class NozofibiApp extends StatefulWidget {
  const NozofibiApp({super.key});
  @override
  State<NozofibiApp> createState() => _NozofibiAppState();
}

class _NozofibiAppState extends State<NozofibiApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nozofibi',
      theme: ThemeData(fontFamily: 'Plus Jakarta Sans', useMaterial3: true),
      home: AppRoot(
        darkMode: isDarkMode, 
        onToggleDark: () => setState(() => isDarkMode = !isDarkMode)
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  final bool darkMode;
  final VoidCallback onToggleDark;
  const AppRoot({super.key, required this.darkMode, required this.onToggleDark});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int currentIndex = 0;
  final List<ScheduleTask> _tasks = [
    ScheduleTask(id: '1', date: DateTime.now(), time: '08:00 AM', title: 'Productivity Research', type: TaskType.study, completed: true),
    ScheduleTask(id: '2', date: DateTime.now(), time: '10:30 AM', title: 'Biology Chapter 4', type: TaskType.study),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeView(isDarkMode: widget.darkMode, onNavigateToSchedule: () => setState(() => currentIndex = 2)),
      TimerView(isDarkMode: widget.darkMode),
      ScheduleView(
        tasks: _tasks, 
        onAddTask: (t) => setState(() => _tasks.add(t)),
        onToggle: (id) => setState(() {
          final i = _tasks.indexWhere((t) => t.id == id);
          if (i != -1) _tasks[i].completed = !_tasks[i].completed;
        }),
        onDelete: (id) => setState(() => _tasks.removeWhere((t) => t.id == id)),
      ),
      const AnalyticsView(),
      ProfileView(
        onLogout: () {}, 
        onGoPremium: () {}, 
        onGoSettings: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: widget.darkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Glow Background (Matching React)
          Positioned(
            top: -100, right: -100,
            child: _glow(widget.darkMode ? AppTheme.primary.withOpacity(0.1) : AppTheme.primary.withOpacity(0.08), 400)
          ),
          Positioned(
            bottom: -100, left: -100,
            child: _glow(widget.darkMode ? AppTheme.secondary.withOpacity(0.1) : AppTheme.secondary.withOpacity(0.08), 400)
          ),
          
          SafeArea(
            bottom: false,
            child: IndexedStack(index: currentIndex, children: screens),
          ),

          // Theme Toggle
          Positioned(
            top: 20, right: 24,
            child: IconButton.filled(
              onPressed: widget.onToggleDark,
              icon: Icon(widget.darkMode ? Icons.auto_awesome : Icons.nights_stay, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: widget.darkMode ? AppTheme.cardDark : Colors.white,
                foregroundColor: widget.darkMode ? Colors.amber : AppTheme.primary,
                shadowColor: Colors.black12, elevation: 8,
                fixedSize: const Size(54, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
              ),
            ),
          ),

          // Floating Nav Bar
          Positioned(
            bottom: 30, left: 24, right: 24,
            child: GlassCard(
              isDarkMode: widget.darkMode,
              borderRadius: 32,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navBtn(0, Icons.home_rounded),
                  _navBtn(1, Icons.timer_outlined),
                  _navBtn(2, Icons.calendar_today_rounded),
                  _navBtn(3, Icons.bar_chart_rounded),
                  _navBtn(4, Icons.person_rounded),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _glow(Color c, double s) => Container(
    width: s, height: s, 
    decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c, blurRadius: 100, spreadRadius: 50)])
  );

  Widget _navBtn(int index, IconData icon) {
    bool sel = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary : Colors.transparent, 
          borderRadius: BorderRadius.circular(22),
          boxShadow: sel ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null
        ),
        child: Icon(icon, color: sel ? Colors.white : AppTheme.textMuted.withOpacity(0.4), size: 24),
      ),
    );
  }
}

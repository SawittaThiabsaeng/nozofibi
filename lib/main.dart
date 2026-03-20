import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/task.dart';
import 'screens/home_view.dart';
import 'screens/login_screen.dart';
import 'screens/timer_view.dart';
import 'screens/schedule_view.dart';
import 'screens/analytics_view.dart';
import 'screens/profile_view.dart';
import 'screens/edit_profile_page.dart';
import 'screens/settings_view.dart';

void main() => runApp(const ProductivityApp());

class ProductivityApp extends StatefulWidget {
  const ProductivityApp({super.key});

  @override
  State<ProductivityApp> createState() => _ProductivityAppState();
}

class _ProductivityAppState extends State<ProductivityApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

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

     home: Builder(
  builder: (context) {
    return LoginScreen(
      onLogin: (name) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(
              userName: name,
              onToggleDarkMode: toggleTheme,
            ),
          ),
        );
      },
    );
  },
),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String userName;
  final Function(bool) onToggleDarkMode;

  const MainNavigation({
    super.key,
    required this.userName,
    required this.onToggleDarkMode,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late String _profileName;
  XFile? _profileImage;

  final List<ScheduleTask> _tasks = [
    ScheduleTask(
      id: '1',
      date: DateTime.now(),
      time: '08:00 AM',
      title: 'Morning Ritual',
      type: TaskType.rest,
      completed: true,
    ),
    ScheduleTask(
      id: '2',
      date: DateTime.now(),
      time: '10:30 AM',
      title: 'Biology Chapter 4',
      type: TaskType.study,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _profileName = widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeView(
        userName: _profileName,
        profileImage: _profileImage,
        onNavigateToSchedule: () {
          setState(() => _currentIndex = 2);
        },
      ),

      TimerView(
        onSaved: () {
          setState(() => _currentIndex = 3);
        },
      ),

      ScheduleView(
        tasks: _tasks,
        onAddTask: (task) {
          setState(() => _tasks.add(task));
        },
        onToggle: (id) {
          setState(() {
            final i = _tasks.indexWhere((t) => t.id == id);
            if (i != -1) {
              _tasks[i].completed = !_tasks[i].completed;
            }
          });
        },
        onDelete: (id) {
          setState(() {
            _tasks.removeWhere((t) => t.id == id);
          });
        },
      ),

      AnalyticsView(tasks: _tasks),

      ProfileView(
        userName: _profileName,
        profileImage: _profileImage,
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                onLogin: (name) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainNavigation(
                        userName: name,
                        onToggleDarkMode: widget.onToggleDarkMode,
                      ),
                    ),
                  );
                },
              ),
            ),
            (route) => false,
          );
        },
        onGoSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsView(
                onBack: () => Navigator.pop(context),
                onThemeChanged: widget.onToggleDarkMode,
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
    setState(() {
      _profileName = result["name"];
      _profileImage = result["image"];
    });
  }
},
        onToggleDarkMode: widget.onToggleDarkMode,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
  index: _currentIndex,
  children: screens,
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

          return IconButton(
            onPressed: () => onTap(index),
            icon: Icon(
              items[index],
              color: selected
                  ? Colors.white
                  : const Color(0xFF94A3B8),
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  selected ? const Color(0xFF8B5CF6) : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          );
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../data/focus_storage.dart';
import 'dart:ui';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({
    super.key,
    required this.tasks,
  });

  final List<ScheduleTask> tasks;

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  List<FocusSession> sessions = [];

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  loadSessions();
}

  Future<void> loadSessions() async {
    final data = await FocusStorage.loadSessions();
    setState(() {
      sessions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));

    /// 🔹 คำนวณ 7 วัน (Mon - Sun)
    List<double> weeklyHours = List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));

      /// นาทีจาก ScheduleTask
      final taskMinutes = widget.tasks
          .where((t) =>
              t.completed &&
              DateUtils.isSameDay(t.date, day))
          .fold<int>(0, (sum, t) => sum + t.focusMinutes);

      /// นาทีจาก FocusSession (โหลดจาก Storage)
      final sessionMinutes = sessions
          .where((s) =>
              DateUtils.isSameDay(s.date, day))
          .fold<int>(0, (sum, s) => sum + s.minutes);

      return (taskMinutes + sessionMinutes) / 60;
    });

    final days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    final double total =
        weeklyHours.fold(0, (a, b) => a + b);

    final double average =
        total == 0 ? 0 : total / 7;

    final double maxValue =
        weeklyHours.isEmpty
            ? 0
            : weeklyHours.reduce(
                (a, b) => a > b ? a : b);

    final int bestIndex =
        weeklyHours.indexWhere(
      (e) => e == maxValue,
    );
final isDark = Theme.of(context).brightness == Brightness.dark;

return Scaffold(
  backgroundColor: isDark ? null : const Color(0xFFF6F4FA),
  body: Container(
    decoration: isDark ? AppTheme.darkGradient : null,
    child: Stack(
      children: [

        /// 🔵 มุมล่างซ้าย
        Positioned(
          bottom: -120,
          left: -120,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 140, sigmaY: 140),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.6),
              ),
            ),
          ),
        ),

        /// 🟣 มุมบนขวา
        Positioned(
          top: -150,
          right: -150,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 140, sigmaY: 140),
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6)
                    .withOpacity(0.6),
              ),
            ),
          ),
        ),

        /// 📊 เนื้อหา
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 20),

              Text(
                'Insights',
                style: AppTheme.h1.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 24),

              // 👇 ของเดิมวางต่อได้เลย

          /// 🟣 WEEKLY SUMMARY
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEEKLY SUMMARY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Focus This Week: ${total.toStringAsFixed(1)}h',
                    style: AppTheme.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average Per Day: ${average.toStringAsFixed(1)}h',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total == 0
                        ? 'Best Day: -'
                        : 'Best Day: ${days[bestIndex]}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          /// 🟣 WEEKLY BAR CHART
          GlassCard(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WEEKLY FOCUS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children:
                        List.generate(7, (index) {
                      return Column(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          _bar(
                            weeklyHours[index] * 25,
                            active:
                                index == bestIndex &&
                                    total > 0,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            days[index],
                            style:
                                const TextStyle(
                                    fontSize: 11),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          ],
        ),
      ),
    ],
  ),
  ),
);
  }

  static Widget _bar(double height,
      {bool active = false}) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 400),
      width: 22,
      height: height.clamp(4, 180),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primary
            : AppTheme.primary
                .withValues(alpha: 0.3),
        borderRadius:
            BorderRadius.circular(8),
      ),
    );
  }
}
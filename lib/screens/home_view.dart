import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/soft_background.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../providers/task_provider.dart';
import '../providers/study_session_provider.dart';
import '../data/emotion_checkin_storage.dart';
import '../features/emotion_quiz/mood_logic.dart';
import 'mood_log_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onOpenEmotionAnalytics,
    required this.userName,
    required this.profileImage, // ✅ รับรูปจาก MainNavigation
  });

  final VoidCallback onOpenEmotionAnalytics;
  final String userName;
  final XFile? profileImage;
  static int _metricsCacheKey = 0;
  static _HomeMetricsSnapshot? _metricsCache;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isThai = locale.languageCode.toLowerCase().startsWith('th');
    final localeTag = locale.toLanguageTag();

    final taskProvider = context.watch<TaskProvider>();
    final sessionProvider = context.watch<StudySessionProvider>();
    final isMetricsFirstLoad = !taskProvider.isLoaded || !sessionProvider.isLoaded;

    final tasks = taskProvider.tasks;
    final sessions = sessionProvider.sessions;
    final now = DateTime.now();
    final metrics = _memoizedMetrics(tasks: tasks, sessions: sessions, now: now);

    final todayFocusValue = metrics.todayFocusValue;
    final streakValue = metrics.streakValue;
    final weeklyFocusValue = metrics.weeklyFocusValue;
    final completedValue = metrics.completedValue;

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
                          userName,
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
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('EEEE d MMMM', localeTag)
                              .format(now),
                          style: (isThai
                                  ? AppTheme.bodyBold.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    )
                                  : AppTheme.caption)
                              .copyWith(
                            color: isDark
                                ? Colors.white60
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              _currentMoodCard(context, isThai),

              const SizedBox(height: 24),

              /// 🔹 WELLNESS TITLE
              Text(
                isThai ? 'สรุปประจำวัน' : 'Wellness Metrics',
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
                    children: isMetricsFirstLoad
                        ? List<Widget>.generate(4, (_) => _metricSkeleton(context))
                        : [
                      _metric(context,
                          Icons.today,
                          isThai ? 'วันนี้' : 'TODAY',
                          todayFocusValue,
                          const Color(0xFF60A5FA),
                          onTap: () {
                            _showMetricDetailSheet(
                              context: context,
                              title: isThai ? 'วันนี้' : 'TODAY',
                              description: isThai
                                  ? 'เวลาโฟกัสรวมของวันนี้จากงานที่ทำเสร็จและการจับเวลา'
                                  : 'Total focus time for today from completed tasks and timer sessions.',
                              records: _todayFocusRecords(
                                tasks: tasks,
                                sessions: sessions,
                                now: now,
                                isThai: isThai,
                              ),
                            );
                          }),
                      _metric(context,
                          Icons.local_fire_department,
                          isThai ? 'ต่อเนื่อง' : 'STREAK',
                          streakValue,
                          Colors.orangeAccent,
                          onTap: () {
                            _showMetricDetailSheet(
                              context: context,
                              title: isThai ? 'ต่อเนื่อง' : 'STREAK',
                              description: isThai
                                  ? 'จำนวนวันที่มีการอ่าน/โฟกัสต่อเนื่องย้อนหลังจากวันนี้'
                                  : 'Number of consecutive active reading/focus days counting backward from today.',
                              records: _streakRecords(
                                tasks: tasks,
                                sessions: sessions,
                                now: now,
                                isThai: isThai,
                              ),
                            );
                          }),
                      _metric(context,
                          Icons.center_focus_strong,
                          isThai ? 'โฟกัส 7 วัน' : 'FOCUS 7D',
                          weeklyFocusValue,
                          AppTheme.primary,
                          onTap: () {
                            _showMetricDetailSheet(
                              context: context,
                              title: isThai ? 'โฟกัส 7 วัน' : 'FOCUS 7D',
                              description: isThai
                                  ? 'เวลาโฟกัสรวมในช่วง 7 วันที่ผ่านมา'
                                  : 'Total focus time accumulated in the last 7 days.',
                              records: _weeklyFocusRecords(
                                tasks: tasks,
                                sessions: sessions,
                                now: now,
                                isThai: isThai,
                              ),
                            );
                          }),
                      _metric(context,
                          Icons.task_alt,
                          isThai ? 'เสร็จ 7 วัน' : 'DONE 7D',
                          completedValue,
                          Colors.amber,
                          onTap: () {
                            _showMetricDetailSheet(
                              context: context,
                              title: isThai ? 'เสร็จ 7 วัน' : 'DONE 7D',
                              description: isThai
                                  ? 'จำนวนงานที่ทำสำเร็จใน 7 วันที่ผ่านมา'
                                  : 'Count of completed tasks in the last 7 days.',
                              records: _completedTasksRecords(
                                tasks: tasks,
                                now: now,
                                isThai: isThai,
                              ),
                            );
                          }),
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
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const Icon(Icons.person, size: 34, color: Color(0xFF94A3B8)),
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

  Widget _currentMoodCard(BuildContext context, bool isThai) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<EmotionCheckin>>(
      future: EmotionCheckinStorage.loadCheckins(),
      builder: (context, snapshot) {
        final checkins = snapshot.data ?? const <EmotionCheckin>[];
        final latest = checkins.isNotEmpty ? checkins.last : null;

        final localizedName = latest == null
            ? ''
            : getMoodNameForLocale(latest.mood, isThai: isThai);
        final localizedMessage = latest == null
            ? (isThai
                ? 'ยังไม่มีการเช็กอารมณ์ ลองสุ่มครั้งแรกของวันนี้'
                : 'No mood check-in yet. Start your first mood check-in today.')
            : getMoodMessageForLocale(latest.mood, isThai: isThai);
        final details = latest == null ? null : getMoodDetailsByMood(latest.mood);
        final moodAsset = latest == null ? null : getMoodSvgAsset(latest.mood);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE6EAF2),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                offset: const Offset(0, 14),
                color: (isDark ? Colors.black : const Color(0xFF8B5CF6))
                    .withValues(alpha: isDark ? 0.18 : 0.08),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenEmotionAnalytics,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFB794F4),
                            Color(0xFF7FA8F8),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 14,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                                Icon(
                                  Icons.favorite_rounded,
                                  size: 74,
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.24),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(18),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    isThai ? 'ข้อมูลเชิงลึก' : 'INSIGHTS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Emotion Analytics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 1.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isThai
                                    ? 'ติดตามอารมณ์และสุขภาวะใจของคุณ'
                                    : 'Track your mood and mental well-being.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text(
                                    isThai ? 'ดูการวิเคราะห์' : 'View Analysis',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isThai ? 'อารมณ์ล่าสุด' : 'Today\'s Mood',
                              style: TextStyle(
                                fontSize: 21,
                                height: 1.0,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF243145),
                              ),
                            ),
                          ),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFF3F6FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: latest == null
                                ? Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 24,
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFFB5C1D2),
                                  )
                                : (moodAsset != null
                                    ? SvgPicture.asset(
                                        moodAsset,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                      )
                                    : Text(
                                        details!.emoji,
                                        style: const TextStyle(fontSize: 26),
                                      )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (latest != null) ...[
                        Text(
                          localizedName,
                          style: TextStyle(
                            color: details!.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'EEE d MMM, HH:mm',
                            Localizations.localeOf(context).toLanguageTag(),
                          ).format(latest.date),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppTheme.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        localizedMessage,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF8A9AB2),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFA78BFA), Color(0xFF8B7CF8)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: onOpenEmotionAnalytics,
                                  icon: const Icon(Icons.casino_outlined),
                                  label: Text(isThai ? 'สุ่มอารมณ์ตอนนี้' : 'Check Mood Now'),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MoodLogScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.history_rounded),
                                label: Text(isThai ? 'ประวัติ' : 'History'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? const Color(0xFFCFD8E8)
                                      : const Color(0xFF64748B),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFD8DEE8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metric(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      Color color, {
      VoidCallback? onTap,
      }) {

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
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

  Widget _metricSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF1F2F7);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : const Color(0xFFE4E7F2);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 10,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 56,
                height: 26,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  _HomeMetricsSnapshot _memoizedMetrics({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
  }) {
    final key = _buildMetricsCacheKey(tasks: tasks, sessions: sessions, now: now);

    if (_metricsCache != null && _metricsCacheKey == key) {
      return _metricsCache!;
    }

    final snapshot = _computeMetricsSnapshot(tasks: tasks, sessions: sessions, now: now);
    _metricsCacheKey = key;
    _metricsCache = snapshot;
    return snapshot;
  }

  int _buildMetricsCacheKey({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
  }) {
    final dayKey = (now.year * 10000) + (now.month * 100) + now.day;
    var hash = dayKey;

    for (final t in tasks) {
      final taskDay = (t.date.year * 10000) + (t.date.month * 100) + t.date.day;
      hash = Object.hash(hash, t.id, taskDay, t.completed, t.focusMinutes);
    }

    for (final s in sessions) {
      final sessionDay = (s.date.year * 10000) + (s.date.month * 100) + s.date.day;
      hash = Object.hash(hash, s.title, sessionDay, s.totalSeconds);
    }

    return hash;
  }

  _HomeMetricsSnapshot _computeMetricsSnapshot({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final start7d = today.subtract(const Duration(days: 6));

    var todayTaskSeconds = 0;
    var weeklyTaskSeconds = 0;
    var completedTasks7d = 0;
    final activeDays = <DateTime>{};

    for (final t in tasks) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);

      if (t.completed && !day.isBefore(start7d)) {
        completedTasks7d++;
      }

      if (t.completed && t.focusMinutes > 0) {
        final seconds = t.focusMinutes * 60;
        activeDays.add(day);

        if (!day.isBefore(start7d)) {
          weeklyTaskSeconds += seconds;
        }

        if (day == today) {
          todayTaskSeconds += seconds;
        }
      }
    }

    var todaySessionSeconds = 0;
    var weeklySessionSeconds = 0;

    for (final s in sessions) {
      final day = DateTime(s.date.year, s.date.month, s.date.day);
      activeDays.add(day);

      if (!day.isBefore(start7d)) {
        weeklySessionSeconds += s.totalSeconds;
      }

      if (day == today) {
        todaySessionSeconds += s.totalSeconds;
      }
    }

    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      if (activeDays.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    final weeklySeconds = weeklyTaskSeconds + weeklySessionSeconds;
    final todaySeconds = todayTaskSeconds + todaySessionSeconds;

    return _HomeMetricsSnapshot(
      todayFocusValue: '${(todaySeconds / 3600).toStringAsFixed(1)}h',
      streakValue: '${streak}d',
      weeklyFocusValue: '${(weeklySeconds / 3600).toStringAsFixed(1)}h',
      completedValue: '$completedTasks7d',
    );
  }

  bool _isWithinLastDays(DateTime date, DateTime now, int days) {
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final current = DateTime(date.year, date.month, date.day);
    return !current.isBefore(start);
  }

  void _showMetricDetailSheet({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> records,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Text(
                  title,
                  style: AppTheme.h2.copyWith(
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF7F7FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white12 : const Color(0xFFE8EAF3),
                        ),
                      ),
                      child: Text(
                        records[index],
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _todayFocusRecords({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
    required bool isThai,
  }) {
    final items = <String>[];

    for (final t in tasks.where((t) => t.completed && _isSameDay(t.date, now) && t.focusMinutes > 0)) {
      items.add(isThai
          ? 'งาน: ${t.title} • ${t.focusMinutes} นาที'
          : 'Task: ${t.title} • ${t.focusMinutes} min');
    }

    for (final s in sessions.where((s) => _isSameDay(s.date, now))) {
      items.add(isThai
          ? 'เซสชัน: ${s.title} • ${_formatDuration(s.totalSeconds)}'
          : 'Session: ${s.title} • ${_formatDuration(s.totalSeconds)}');
    }

    if (items.isEmpty) {
      items.add(isThai ? 'ยังไม่มีข้อมูลวันนี้' : 'No records for today yet.');
    }

    return items;
  }

  List<String> _streakRecords({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
    required bool isThai,
  }) {
    final activeDays = _activeDaySet(tasks: tasks, sessions: sessions);
    final result = <String>[];

    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      if (!activeDays.contains(day)) {
        break;
      }
      result.add(
        isThai
            ? 'ต่อเนื่อง: ${DateFormat('dd MMM yyyy', 'th').format(day)}'
            : 'Streak day: ${DateFormat('dd MMM yyyy').format(day)}',
      );
    }

    if (result.isEmpty) {
      result.add(isThai ? 'ยังไม่เริ่มสตรีควันนี้' : 'No active streak today.');
    }

    return result;
  }

  List<String> _weeklyFocusRecords({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
    required DateTime now,
    required bool isThai,
  }) {
    final items = <String>[];

    for (final t in tasks.where((t) => t.completed && _isWithinLastDays(t.date, now, 7) && t.focusMinutes > 0)) {
      final dateText = DateFormat('dd MMM').format(t.date);
      items.add(isThai
          ? 'งาน: ${t.title} • $dateText • ${t.focusMinutes} นาที'
          : 'Task: ${t.title} • $dateText • ${t.focusMinutes} min');
    }

    for (final s in sessions.where((s) => _isWithinLastDays(s.date, now, 7))) {
      final dateText = DateFormat('dd MMM').format(s.date);
      items.add(isThai
          ? 'เซสชัน: ${s.title} • $dateText • ${_formatDuration(s.totalSeconds)}'
          : 'Session: ${s.title} • $dateText • ${_formatDuration(s.totalSeconds)}');
    }

    if (items.isEmpty) {
      items.add(isThai ? 'ยังไม่มีข้อมูล 7 วันที่ผ่านมา' : 'No records in the last 7 days.');
    }

    return items;
  }

  List<String> _completedTasksRecords({
    required List<ScheduleTask> tasks,
    required DateTime now,
    required bool isThai,
  }) {
    final done = tasks.where((t) => t.completed && _isWithinLastDays(t.date, now, 7)).toList();
    if (done.isEmpty) {
      return [isThai ? 'ยังไม่มีงานที่เสร็จใน 7 วันล่าสุด' : 'No completed tasks in the last 7 days.'];
    }

    return done
        .map(
          (t) => isThai
              ? 'งานเสร็จ: ${t.title} • ${DateFormat('dd MMM').format(t.date)}'
              : 'Completed: ${t.title} • ${DateFormat('dd MMM').format(t.date)}',
        )
        .toList();
  }

  Set<DateTime> _activeDaySet({
    required List<ScheduleTask> tasks,
    required List<FocusSession> sessions,
  }) {
    final result = <DateTime>{};

    for (final t in tasks) {
      if (t.completed && t.focusMinutes > 0) {
        result.add(DateTime(t.date.year, t.date.month, t.date.day));
      }
    }

    for (final s in sessions) {
      result.add(DateTime(s.date.year, s.date.month, s.date.day));
    }

    return result;
  }

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _HomeMetricsSnapshot {
  const _HomeMetricsSnapshot({
    required this.todayFocusValue,
    required this.streakValue,
    required this.weeklyFocusValue,
    required this.completedValue,
  });

  final String todayFocusValue;
  final String streakValue;
  final String weeklyFocusValue;
  final String completedValue;
}
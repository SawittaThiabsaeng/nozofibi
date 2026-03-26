import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/emotion_checkin_storage.dart';
import '../features/emotion_quiz/mood_logic.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/soft_background.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  List<EmotionCheckin> _checkins = const [];
  bool _loading = true;

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loaded = await EmotionCheckinStorage.loadCheckins();
    if (!mounted) {
      return;
    }

    setState(() {
      _checkins = loaded.reversed.toList();
      _loading = false;
    });
  }

  String _dayLabel(DateTime date, bool isThai, String localeTag) {
    final now = DateTime.now();
    final targetDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (targetDay == today) {
      return isThai ? 'วันนี้' : 'Today';
    }
    if (targetDay == yesterday) {
      return isThai ? 'เมื่อวาน' : 'Yesterday';
    }
    return DateFormat('EEEE d MMMM', localeTag).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('th');
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF6F4FA),
      body: Container(
        decoration: isDark ? AppTheme.darkGradient : null,
        child: SoftBackground(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isThai ? 'ประวัติอารมณ์' : 'Mood Log',
                        style: AppTheme.h2.copyWith(
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_checkins.isEmpty)
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isThai
                              ? 'ยังไม่มีประวัติอารมณ์ ลองทำ Emotion Quiz ครั้งแรกของคุณ'
                              : 'No mood history yet. Complete your first Emotion Quiz to start tracking.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  else
                    ...[
                      _weeklyMoodChart(
                        context: context,
                        isThai: isThai,
                        localeTag: localeTag,
                      ),
                      const SizedBox(height: 8),
                      ..._buildGroupedHistory(
                        context: context,
                        isThai: isThai,
                        localeTag: localeTag,
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedHistory({
    required BuildContext context,
    required bool isThai,
    required String localeTag,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = <String, List<EmotionCheckin>>{};

    for (final item in _checkins) {
      final key = DateFormat('yyyy-MM-dd').format(item.date);
      grouped.putIfAbsent(key, () => <EmotionCheckin>[]).add(item);
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final widgets = <Widget>[];

    for (final key in keys) {
      final list = grouped[key]!;
      final label = _dayLabel(list.first.date, isThai, localeTag);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      );

      widgets.add(
        GlassCard(
          child: Column(
            children: list.map((entry) {
              final details = getMoodDetailsByMood(entry.mood);
              final localizedName = getMoodNameForLocale(entry.mood, isThai: isThai);
              final timeText = DateFormat('HH:mm', localeTag).format(entry.date);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: details.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(details.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizedName,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _weeklyMoodChart({
    required BuildContext context,
    required bool isThai,
    required String localeTag,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = _dayOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));

    final dayKeys = List<DateTime>.generate(
      7,
      (index) => start.add(Duration(days: index)),
    );

    final countsByDay = <DateTime, int>{
      for (final day in dayKeys) day: 0,
    };

    for (final item in _checkins) {
      final day = _dayOnly(item.date);
      if (day.isBefore(start) || day.isAfter(today)) {
        continue;
      }
      countsByDay[day] = (countsByDay[day] ?? 0) + 1;
    }

    final maxCount = countsByDay.values.fold<int>(0, (a, b) => a > b ? a : b);
    final chartTop = maxCount == 0 ? 1 : maxCount;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isThai ? 'กราฟอารมณ์ 7 วันล่าสุด' : 'Mood Activity (Last 7 Days)',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 146,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dayKeys.map((day) {
                final count = countsByDay[day] ?? 0;
                final ratio = count / chartTop;
                final barHeight = 10 + (64 * ratio);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: barHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFB794F4),
                                Color(0xFF7FA8F8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('E', localeTag).format(day),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

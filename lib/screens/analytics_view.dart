import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/study_session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/task.dart';
import 'dart:ui';
import '../l10n/app_strings.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({
    super.key,
    required this.tasks,
    required this.refreshToken,
  });

  final List<ScheduleTask> tasks;
  final int refreshToken;

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  static const int _sessionsPerPage = 5;
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant AnalyticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      // Trigger refresh from provider
      if (!mounted) return;
      context.read<StudySessionProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudySessionProvider>(
      builder: (context, sessionProvider, _) {
        final s = AppStrings.of(context);
        // Use precomputed weekly stats from provider
        final weeklyStats = sessionProvider.weeklyStats;
        final allSessions = [...sessionProvider.sessions]
          ..sort((a, b) => b.date.compareTo(a.date));
        
        // Pagination for recent sessions
        final paginatedSessions = allSessions
            .skip(_currentPage * _sessionsPerPage)
            .take(_sessionsPerPage)
            .toList();
        final hasMoreSessions = allSessions.length > (_currentPage + 1) * _sessionsPerPage;

        // Format weekly stats
        final days = s.isThai
          ? ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา']
          : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        final dateFormat = DateFormat('dd MMM yyyy, HH:mm', localeTag);

        return Scaffold(
          backgroundColor: isDark ? null : const Color(0xFFF6F4FA),
          body: Container(
            decoration: isDark ? AppTheme.darkGradient : null,
            child: Stack(
              children: [
                /// 🔵 Bottom left blob
                Positioned(
                  bottom: -120,
                  left: -120,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
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

                /// 🟣 Top right blob
                Positioned(
                  top: -150,
                  right: -150,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withOpacity(0.6),
                      ),
                    ),
                  ),
                ),

                /// 📊 Content
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        s.insights,
                        style: AppTheme.h1.copyWith(
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// 🟣 WEEKLY SUMMARY
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.weeklySummary,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.totalFocusThisWeek(_formatDuration((weeklyStats?.totalSeconds ?? 0))),
                                style: AppTheme.h2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.averagePerDay(_formatDuration((weeklyStats?.totalSeconds ?? 0) ~/ 7)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (weeklyStats?.bestDay ?? -1) < 0
                                    ? s.bestDay('-')
                                    : s.bestDay(days[weeklyStats!.bestDay]),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    s.weeklyFocus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (weeklyStats != null)
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      const labelHeight = 16.0;
                                      const labelGap = 8.0;
                                      final maxBarHeight = (constraints.maxHeight - labelHeight - labelGap)
                                          .clamp(0.0, 180.0);
                                      final maxDailySeconds = weeklyStats.dailySeconds.reduce(
                                        (a, b) => a > b ? a : b,
                                      );

                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(7, (index) {
                                          final dailySeconds = weeklyStats.dailySeconds[index];
                                          final normalizedHeight = maxDailySeconds == 0
                                              ? 0.0
                                              : (dailySeconds / maxDailySeconds) * maxBarHeight;

                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              _bar(
                                                normalizedHeight,
                                                active: index == weeklyStats.bestDay && weeklyStats.totalSeconds > 0,
                                              ),
                                              const SizedBox(height: labelGap),
                                              Text(days[index], style: const TextStyle(fontSize: 11)),
                                            ],
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 🟣 RECENT SESSIONS
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.recentSessions,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (paginatedSessions.isEmpty)
                                Text(
                                  s.noSavedSessions,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : AppTheme.textMuted,
                                  ),
                                )
                              else
                                ...paginatedSessions.map((session) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                session.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dateFormat.format(session.date),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _formatDuration(session.totalSeconds),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              
                              // Pagination controls
                              if (allSessions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (_currentPage > 0)
                                        TextButton(
                                          onPressed: () => setState(() => _currentPage--),
                                          child: Text(s.previous),
                                        )
                                      else
                                        const SizedBox(width: 80),
                                      Text(
                                        s.page(_currentPage + 1),
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                      if (hasMoreSessions)
                                        TextButton(
                                          onPressed: () => setState(() => _currentPage++),
                                          child: Text(s.next),
                                        )
                                      else
                                        const SizedBox(width: 80),
                                    ],
                                  ),
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
      },
    );
  }

  static Widget _bar(double height,
      {bool active = false}) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 400),
      width: 22,
      height: height.clamp(0, 180),
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

  static String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

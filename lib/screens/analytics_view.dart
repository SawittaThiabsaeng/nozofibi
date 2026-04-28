import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/task.dart';
import '../providers/study_session_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({
    required this.tasks,
    required this.refreshToken,
    super.key,
  });

  final List<ScheduleTask> tasks;
  final int refreshToken;

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const int _sessionsPerPage = 5;
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant AnalyticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      if (!mounted) return;
      // FIX 3: Reset page to 0 when data refreshes
      setState(() => _currentPage = 0);
      context.read<StudySessionProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<StudySessionProvider>(
      builder: (context, sessionProvider, _) {
        // FIX 1: ลบการประกาศตัวแปร `s` ซ้ำ เหลือแค่บรรทัดเดียว
        final s = AppStrings.of(context);

        final weeklyStats = sessionProvider.weeklyStats;
        final allSessions = [...sessionProvider.sessions]
          ..sort((a, b) => b.date.compareTo(a.date));

        // Pagination
        final paginatedSessions = allSessions
            .skip(_currentPage * _sessionsPerPage)
            .take(_sessionsPerPage)
            .toList();
        final hasMoreSessions =
            allSessions.length > (_currentPage + 1) * _sessionsPerPage;

        // Format weekly stats
        final days = s.isThai
            ? ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา']
            : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        final dateFormat = DateFormat('dd MMM yyyy, HH:mm', localeTag);

        // FIX 2: คำนวณค่าเฉลี่ยจากวันที่มีข้อมูลจริง ไม่ hardcode หาร 7
        final daysWithData = weeklyStats?.dailySeconds
                .where((sec) => sec > 0)
                .length ??
            0;
        final averageSeconds = daysWithData == 0
            ? 0
            : (weeklyStats!.totalSeconds ~/ daysWithData);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            color: isDark ? null : const Color(0xFFF6F4FA),
            decoration: isDark ? AppTheme.darkGradient : null,
            child: Stack(
              children: [
                /// 🔵 Bottom left blob
                Positioned(
                  bottom: -130,
                  left: -130,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // FIX 2 (ต่อ): ใช้ withValues แบบเดียวกันทั้งไฟล์
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                ),

                /// 🟣 Top right blob
                Positioned(
                  top: -130,
                  right: -130,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                ),

                /// 📊 Content
                SafeArea(
                  top: true,
                  bottom: false,
                  minimum: EdgeInsets.zero,
                 child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24, 24, 24,
                    24 + MediaQuery.of(context).padding.bottom + 90, // เพิ่มส่วนนี้
                  ),
                    
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            s.insights,
                            style: AppTheme.h1.copyWith(
                              color:
                                  isDark ? Colors.white : AppTheme.textDark,
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
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.totalFocusThisWeek(_formatDuration(
                                        weeklyStats?.totalSeconds ?? 0)),
                                    style: AppTheme.h2,
                                  ),
                                  const SizedBox(height: 8),
                                  // FIX 2 (ต่อ): แสดงค่าเฉลี่ยจากวันที่มีข้อมูลจริง
                                  Text(s.averagePerDay(
                                      _formatDuration(averageSeconds))),
                                  const SizedBox(height: 8),
                                  Text(
                                    (weeklyStats?.bestDay ?? -1) < 0
                                        ? s.bestDay('-')
                                        : s.bestDay(
                                            days[weeklyStats!.bestDay]),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        s.weeklyFocus,
                                        style: const TextStyle(
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
                                          final maxBarHeight =
                                              (constraints.maxHeight -
                                                      labelHeight -
                                                      labelGap)
                                                  .clamp(0.0, 180.0);
                                          final maxDailySeconds =
                                              weeklyStats.dailySeconds.reduce(
                                            (a, b) => a > b ? a : b,
                                          );

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children:
                                                List.generate(7, (index) {
                                              final dailySeconds =
                                                  weeklyStats
                                                      .dailySeconds[index];
                                              final normalizedHeight =
                                                  maxDailySeconds == 0
                                                      ? 0.0
                                                      : (dailySeconds /
                                                              maxDailySeconds) *
                                                          maxBarHeight;

                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  _bar(
                                                    normalizedHeight,
                                                    active: index ==
                                                            weeklyStats
                                                                .bestDay &&
                                                        weeklyStats
                                                                .totalSeconds >
                                                            0,
                                                  ),
                                                  const SizedBox(
                                                      height: labelGap),
                                                  Text(days[index],
                                                      style: const TextStyle(
                                                          fontSize: 11)),
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
                                    style: const TextStyle(
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
                                        color: isDark
                                            ? Colors.white70
                                            : AppTheme.textMuted,
                                      ),
                                    )
                                  else
                                    ...paginatedSessions
                                        .map((session) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          session.title,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          dateFormat.format(
                                                              session.date),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .textMuted,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    _formatDuration(
                                                        session.totalSeconds),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDark
                                                          ? Colors.white
                                                          : AppTheme.textDark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),

                                  // Pagination controls
                                  if (allSessions.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (_currentPage > 0)
                                            TextButton(
                                              onPressed: () => setState(
                                                  () => _currentPage--),
                                              child: Text(s.previous),
                                            )
                                          else
                                            const SizedBox(width: 80),
                                          Text(
                                            s.page(_currentPage + 1),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textMuted),
                                          ),
                                          if (hasMoreSessions)
                                            TextButton(
                                              onPressed: () => setState(
                                                  () => _currentPage++),
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
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _bar(double height, {bool active = false}) => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 22,
        height: height.clamp(0, 180),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      );

  static String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

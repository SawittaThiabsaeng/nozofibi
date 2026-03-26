import 'package:flutter/foundation.dart';
import '../models/focus_session.dart';
import '../data/focus_storage.dart';

/// Model for weekly statistics (extracted from calc logic)
class WeeklyStats {
  final List<int> dailySeconds;
  final double totalHours;
  final double averageHours;
  final int bestDay; // day of week (0-6), -1 if no data
  final DateTime weekStart;

  WeeklyStats({
    required this.dailySeconds,
    required this.totalHours,
    required this.averageHours,
    required this.bestDay,
    required this.weekStart,
  });

  int get totalSeconds => dailySeconds.fold(0, (a, b) => a + b);
}

/// Manages focus sessions and weekly statistics.
/// 
/// Consolidated from AnalyticsView to enable:
/// - Testable stats calculations
/// - Reactive updates to weekly data
/// - Centralized session persistence
/// - Coordination with TimerProvider saves
class StudySessionProvider extends ChangeNotifier {
  List<FocusSession> _sessions = [];
  WeeklyStats? _weeklyStats;
  bool _isLoading = false;
  bool _loaded = false;

  // Getters
  List<FocusSession> get sessions => _sessions;
  WeeklyStats? get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;
  bool get isLoaded => _loaded;

  /// Load all sessions from storage and recalculate stats
  Future<void> loadSessions() async {
    if (_loaded || _isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await FocusStorage.loadSessions();
      _sessions = data;
      _recalculateWeeklyStats();
      _loaded = true;
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new session and update stats
  Future<void> addSession(FocusSession session) async {
    try {
      await FocusStorage.addSession(session);
      _sessions.add(session);
      _recalculateWeeklyStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding session: $e');
      rethrow;
    }
  }

  /// Recalculate weekly statistics based on current sessions
  void _recalculateWeeklyStats() {
    _weeklyStats = _calculateWeeklyStats();
  }

  /// Calculate weekly stats for display
  /// Calculates daily focus time across the current week
  WeeklyStats _calculateWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

    // Calculate seconds per day for the week
    final weeklySeconds = List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final dayStart = DateTime(day.year, day.month, day.day);

      // Seconds from focus sessions for this day
      final sessionSeconds = _sessions
          .where((s) {
            final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
            return sessionDate.isAtSameMomentAs(dayStart);
          })
          .fold<int>(0, (sum, s) => sum + s.totalSeconds);

      return sessionSeconds;
    });

    // Calculate aggregate stats
    final totalSeconds = weeklySeconds.fold<int>(0, (a, b) => a + b);
    final totalHours = (totalSeconds / 3600).toDouble();
    final averageHours = totalSeconds == 0 ? 0.0 : ((totalSeconds / 7) / 3600).toDouble();

    // Find best day (most focus time)
    int bestDay = -1;
    if (weeklySeconds.isNotEmpty) {
      final maxSeconds = weeklySeconds.reduce((a, b) => a > b ? a : b);
      if (maxSeconds > 0) {
        bestDay = weeklySeconds.indexOf(maxSeconds);
      }
    }

    return WeeklyStats(
      dailySeconds: weeklySeconds,
      totalHours: totalHours,
      averageHours: averageHours,
      bestDay: bestDay,
      weekStart: startOfWeek,
    );
  }

  /// Get formatted weekly stats for UI display
  Map<String, String> getWeeklyStatsFormatted() {
    final stats = _weeklyStats;
    if (stats == null) {
      return {
        'total': '--',
        'average': '--',
        'bestDay': '--',
      };
    }

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return {
      'total': '${stats.totalHours.toStringAsFixed(1)}h',
      'average': '${stats.averageHours.toStringAsFixed(1)}h',
      'bestDay': stats.bestDay >= 0 ? weekDays[stats.bestDay] : '--',
    };
  }

  /// Refresh stats after sessions are updated
  void refresh() {
    _recalculateWeeklyStats();
    notifyListeners();
  }
}



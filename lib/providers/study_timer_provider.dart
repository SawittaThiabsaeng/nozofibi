import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/focus_session.dart';
import '../data/focus_storage.dart';

/// Manages study timer state and lifecycle.
/// 
/// Consolidated from TimerView to enable:
/// - Testable timer logic
/// - State persistence across widget rebuilds
/// - Coordinated save operations with SessionProvider
class StudyTimerProvider extends ChangeNotifier {
  int _selectedMinutes = 25;
  late int _totalTime;
  late int _time;
  int _focusedSeconds = 0;
  bool _running = false;
  Timer? _timer;

  // Getters for UI
  int get selectedMinutes => _selectedMinutes;
  int get totalTime => _totalTime;
  int get time => _time;
  int get focusedSeconds => _focusedSeconds;
  bool get running => _running;

  StudyTimerProvider() {
    setNewTime(25); // Initialize with default 25 minutes
  }

  /// Start or pause the timer
  void toggle() {
    if (_running) {
      _timer?.cancel();
      _running = false;
      notifyListeners();
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_time > 0) {
        _time--;
        _focusedSeconds++;
        notifyListeners();
      } else {
        _timer?.cancel();
        _running = false;
        notifyListeners();
      }
    });

    _running = true;
    notifyListeners();
  }

  /// Reset timer to initial state
  void resetTimer() {
    _timer?.cancel();
    _time = _totalTime;
    _focusedSeconds = 0;
    _running = false;
    notifyListeners();
  }

  /// Set a new timer duration in minutes
  void setNewTime(int minutes) {
    final durationSeconds = minutes * 60;
    _timer?.cancel();
    _selectedMinutes = minutes;
    _totalTime = durationSeconds;
    _time = _totalTime;
    _focusedSeconds = 0;
    _running = false;
    notifyListeners();
  }

  /// Save current session to storage
  /// Returns the created FocusSession if successful, null if no time elapsed
  Future<FocusSession?> saveSession({
    required String title,
  }) async {
    _timer?.cancel();

    if (_focusedSeconds == 0) return null;

    final session = FocusSession(
      title: title,
      totalSeconds: _focusedSeconds,
      date: DateTime.now(),
    );

    await FocusStorage.addSession(session);

    // Reset after saving
    resetTimer();
    return session;
  }

  /// Cleanup on provider disposal
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

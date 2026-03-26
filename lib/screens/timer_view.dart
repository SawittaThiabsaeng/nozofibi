import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../providers/study_session_provider.dart';
import '../widgets/roller_duration_picker.dart';
import '../l10n/app_strings.dart';

class TimerView extends StatefulWidget {
  const TimerView({
    super.key,
    this.task,
    this.fromSchedule = false,
    this.onSaved,
  });

  final ScheduleTask? task;
  final bool fromSchedule;
  final VoidCallback? onSaved;

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int selectedMinutes = 25;

  late int totalTime;
  late int time;
  int focusedSeconds = 0;

  bool running = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    setNewTime(25);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void toggle() {
    if (running) {
      timer?.cancel();
      setState(() => running = false);
      return;
    }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (time > 0) {
        setState(() {
          time--;
          focusedSeconds++;
        });
      } else {
        timer?.cancel();
        setState(() => running = false);
      }
    });

    setState(() => running = true);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      time = totalTime;
      focusedSeconds = 0;
      running = false;
    });
  }

  void setNewTime(int minutes) {
    final durationSeconds = minutes * 60;
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      totalTime = durationSeconds;
      time = totalTime;
      focusedSeconds = 0;
      running = false;
    });
  }

  Future<void> saveTimer() async {
    timer?.cancel();

    if (focusedSeconds == 0) return;

    final draft = await _showSessionNameDialog();
    if (draft == null) return;

    final session = FocusSession(
      title: draft.title,
      totalSeconds: focusedSeconds,
      date: DateTime.now(),
      type: draft.type,
    );

    await context.read<StudySessionProvider>().addSession(session);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).sessionSaved)),
    );

    widget.onSaved?.call();
  }

  Future<_SessionSaveDraft?> _showSessionNameDialog() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController(
      text: widget.task?.title ?? s.focusSession,
    );
    TaskType selectedType = widget.task?.type ?? TaskType.study;

    final result = await showDialog<_SessionSaveDraft>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          title: Text(
            s.sessionName,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: s.enterSessionName,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                s.planType,
                style: AppTheme.caption.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in const [
                    TaskType.breakTime,
                    TaskType.study,
                    TaskType.exercise,
                    TaskType.rest,
                  ])
                    ChoiceChip(
                      label: Text(_taskTypeLabel(type, s)),
                      selected: selectedType == type,
                      showCheckmark: false,
                      pressElevation: 0,
                      backgroundColor: const Color(0xFFF3F4F6),
                      selectedColor: const Color(0xFFE9D5FF),
                      side: BorderSide(
                        color: selectedType == type
                            ? AppTheme.primary.withValues(alpha: 0.7)
                            : const Color(0xFFE5E7EB),
                      ),
                      labelStyle: TextStyle(
                        color: selectedType == type
                            ? const Color(0xFF5B21B6)
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setModalState(() => selectedType = type);
                      },
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: Text(
                s.cancel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                Navigator.pop(
                  context,
                  _SessionSaveDraft(
                    title: name.isEmpty ? s.focusSession : name,
                    type: selectedType,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                s.save,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// ✅ AppBar แสดงเฉพาะตอนมาจาก Schedule
      appBar: widget.fromSchedule
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(widget.task?.title ?? s.focusTimer),
              centerTitle: true,
            )
          : null,

      body: Stack(
        children: [

          /// 🔵 มุมล่างซ้าย
          Positioned(
            bottom: -120,
            left: -120,
            child: ImageFiltered(
              imageFilter:
                  ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                 color: Colors.blue.withOpacity(isDark ? 0.3 : 0.6),
                ),
              ),
            ),
          ),

          /// 🟣 มุมบนขวา
          Positioned(
            top: -150,
            right: -150,
            child: ImageFiltered(
              imageFilter:
                  ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6)
                      .withOpacity(isDark ? 0.3 : 0.6),
                ),
              ),
            ),
          ),

          /// 📌 เนื้อหาหลัก
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Text(
                    s.focusTimer,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    s.pomodoroProtocol,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 25 / 50 / Custom
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      _timeButton(25),
                      const SizedBox(width: 12),
                      _timeButton(50),
                      const SizedBox(width: 12),
                      _customButton(),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ⏳ TIMER
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -18,
                        child: _progressBadge(isDark),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: totalTime == 0
                              ? 0
                              : time / totalTime,
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        builder: (context, progress, _) {
                          return SizedBox(
                            width: 260,
                            height: 260,
                            child: CustomPaint(
                              painter: _TimerRingPainter(
                                progress: progress,
                                isDark: isDark,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        _formatClock(time),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// 🔥 RESET / PLAY / SAVE
                  SizedBox(
                    width: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sideActionButton(
                          icon: Icons.rotate_left,
                          onPressed: resetTimer,
                        ),
                        _primaryActionButton(),
                        _sideActionButton(
                          icon: Icons.save,
                          onPressed: saveTimer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeButton(int minutes) {
    return ElevatedButton(
      onPressed: () => setNewTime(minutes),
      child: Text("$minutes"),
    );
  }

  Widget _customButton() {
    return ElevatedButton(
      onPressed: () async {
        final seconds = await showRollerDurationPicker(
          context: context,
          initialTotalSeconds: totalTime,
        );

        if (seconds != null && seconds > 0) {
          setState(() {
            selectedMinutes = seconds ~/ 60;
            totalTime = seconds;
            time = totalTime;
            focusedSeconds = 0;
            running = false;
          });
        }
      },
      child: Text(AppStrings.of(context).custom),
    );
  }

  String _formatClock(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _completionRatio() {
    if (totalTime == 0) {
      return 0;
    }
    return (focusedSeconds / totalTime).clamp(0.0, 1.0);
  }

  Widget _progressBadge(bool isDark) {
    final ratio = _completionRatio();
    final percent = (ratio * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: const LinearGradient(
          colors: [Color(0xFFC4B5FD), AppTheme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.45 : 0.3),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }

  Widget _primaryActionButton() {
    return GestureDetector(
      onTap: toggle,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          running ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  String _taskTypeLabel(TaskType type, AppStrings s) {
    switch (type) {
      case TaskType.breakTime:
        return s.typeGeneral;
      case TaskType.study:
        return s.typeReading;
      case TaskType.exercise:
        return s.typeExercise;
      case TaskType.rest:
        return s.typeHomework;
    }
  }
}

class _SessionSaveDraft {
  const _SessionSaveDraft({
    required this.title,
    required this.type,
  });

  final String title;
  final TaskType type;
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    const glowExtra = 3.0;
    const blurSigma = 7.0;
    const edgePadding = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final minSide = math.min(size.width, size.height);
    // Leave room so glow/round caps are not clipped at ring edges.
    final radius = (minSide / 2) - ((strokeWidth + glowExtra) / 2) - (blurSigma / 2) - edgePadding;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.28)
          : Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = (2 * math.pi * progress.clamp(0.0, 1.0));
    if (sweep <= 0) return;

    final gradientShader = SweepGradient(
      colors: const [
        Color(0xFFF5E9FF),
        Color(0xFFE9D5FF),
        Color(0xFFD8B4FE),
        Color(0xFFC4B5FD),
        Color(0xFFA78BFA),
        AppTheme.primary,
      ],
      stops: const [0.0, 0.18, 0.36, 0.58, 0.78, 1.0],
      transform: GradientRotation(-math.pi / 2),
    ).createShader(rect);

    final glowPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + glowExtra
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma)
      ..color = Colors.white.withValues(alpha: 0.35);

    final arcPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);

    final endAngle = -math.pi / 2 + sweep;
    final knobCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final knobPaint = Paint()..color = const Color(0xFFE9D5FF);
    canvas.drawCircle(knobCenter, 4.5, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark;
  }
}
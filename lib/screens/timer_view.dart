import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../models/task.dart';
import '../models/focus_session.dart';
import '../data/focus_storage.dart';

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
    timer?.cancel();
    setState(() {
      selectedMinutes = minutes;
      totalTime = minutes * 60;
      time = totalTime;
      focusedSeconds = 0;
      running = false;
    });
  }

  Future<void> saveTimer() async {
    timer?.cancel();

    if (focusedSeconds == 0) return;

    final session = FocusSession(
      title: widget.task?.title ?? "Focus Session",
      minutes: (focusedSeconds / 60).round(),
      date: DateTime.now(),
    );

    await FocusStorage.addSession(session);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session Saved")),
    );

    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text(widget.task?.title ?? "Focus Timer"),
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
                    "Focus Timer",
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
                    "Pomodoro Protocol",
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
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: totalTime == 0
                              ? 0
                              : time / totalTime,
                          strokeWidth: 8,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        '${(time ~/ 60).toString().padLeft(2, '0')}:${(time % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 56,
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
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: resetTimer,
                        icon: const Icon(Icons.rotate_left),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: toggle,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            running
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      IconButton.filled(
                        onPressed: saveTimer,
                        icon: const Icon(Icons.save),
                      ),
                    ],
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
        final controller = TextEditingController();

        final result = await showDialog<String>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Custom Time"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(
                hintText: "Minutes",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                    context, controller.text),
                child: const Text("Set"),
              ),
            ],
          ),
        );

        if (result != null) {
          final minutes =
              int.tryParse(result) ?? 25;
          setNewTime(minutes);
        }
      },
      child: const Text("Custom"),
    );
  }
}
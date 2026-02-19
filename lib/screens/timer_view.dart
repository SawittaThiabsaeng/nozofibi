import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key, this.isDarkMode = false});
  final bool isDarkMode;
  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int time = 1500; bool running = false; Timer? timer;

  void toggle() {
    if (running) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => time > 0 ? time-- : toggle()));
    }
    setState(() => running = !running);
  }

  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text('Focus Timer', style: widget.isDarkMode ? AppTheme.h1.copyWith(color: Colors.white) : AppTheme.h1),
    Text('Pomodoro Protocol', style: AppTheme.caption),
    const SizedBox(height: 60),
    Stack(alignment: Alignment.center, children: [
      SizedBox(width: 280, height: 280, child: CircularProgressIndicator(value: time/1500, strokeWidth: 8, color: AppTheme.primary, backgroundColor: widget.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05), strokeCap: StrokeCap.round)),
      Text('${(time~/60).toString().padLeft(2,'0')}:${(time%60).toString().padLeft(2,'0')}', style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: widget.isDarkMode ? Colors.white : AppTheme.textDark)),
    ]),
    const SizedBox(height: 60),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _btn(Icons.rotate_left, () => setState(() { time = 1500; running = false; timer?.cancel(); })),
      const SizedBox(width: 32),
      GestureDetector(
        onTap: toggle,
        child: Container(width: 96, height: 96, decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))]), child: Icon(running ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40)),
      ),
      const SizedBox(width: 32),
      _btn(Icons.more_horiz, () {}),
    ])
  ]));

  Widget _btn(IconData i, VoidCallback t) => IconButton.filled(onPressed: t, icon: Icon(i, color: AppTheme.textMuted), style: IconButton.styleFrom(backgroundColor: widget.isDarkMode ? const Color(0xFF1A1C26) : Colors.white, fixedSize: const Size(64, 64)));
}


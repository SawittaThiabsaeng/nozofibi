import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../features/emotion_quiz/mood_logic.dart';
import 'emotion_quiz_screen.dart';

class EmotionResultScreen extends StatefulWidget {
  const EmotionResultScreen({
    super.key,
    required this.mood,
  });

  final String mood;

  @override
  State<EmotionResultScreen> createState() => _EmotionResultScreenState();
}

class _EmotionResultScreenState extends State<EmotionResultScreen> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _revealed = true;
      });
    });
  }

  void _backToAnalytics() {
    for (int i = 0; i < 3; i++) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('th');
    final colorScheme = Theme.of(context).colorScheme;
    final details = getMoodDetailsByMood(widget.mood);
    final localizedMoodName = getMoodNameForLocale(widget.mood, isThai: isThai);
    final localizedMessage = getMoodMessageForLocale(widget.mood, isThai: isThai);
    final svgAsset = getMoodSvgAsset(widget.mood);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final moodVisualSize = screenWidth < 600 ? 132.0 : 180.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              details.color.withValues(alpha: 0.24),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 480),
                curve: Curves.easeOutBack,
                scale: _revealed ? 1 : 0.84,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 380),
                  opacity: _revealed ? 1 : 0,
                  child: svgAsset != null
                      ? SvgPicture.asset(
                          svgAsset,
                          width: moodVisualSize,
                          height: moodVisualSize,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          details.emoji,
                          style: TextStyle(fontSize: moodVisualSize * 0.82),
                        ),
                ),
              ),
              const SizedBox(height: 26),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 480),
                opacity: _revealed ? 1 : 0,
                child: Text(
                  localizedMoodName,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: details.color,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  localizedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: details.color.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 54),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmotionQuizScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: details.color,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(isThai ? 'สุ่มอีกครั้ง' : 'Random Again'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _backToAnalytics();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  foregroundColor: colorScheme.onSurface,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(isThai ? 'กลับ' : 'Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

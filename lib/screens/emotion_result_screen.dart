import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../features/emotion_quiz/mood_logic.dart';
import 'emotion_quiz_screen.dart';

class EmotionResultScreen extends StatefulWidget {
  const EmotionResultScreen({
    required this.mood, super.key,
  });

  final String mood;

  @override
  State<EmotionResultScreen> createState() => _EmotionResultScreenState();
}

class _EmotionResultScreenState extends State<EmotionResultScreen> {
  bool _revealed = false;
  Future<void>? _moodAssetWarmup;
  String? _moodSvgAsset;

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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_moodAssetWarmup != null) {
      return;
    }

    _moodSvgAsset = getMoodSvgAsset(widget.mood);
    if (_moodSvgAsset == null) {
      _moodAssetWarmup = Future.value();
      return;
    }

    final loader = SvgPicture.asset(
      _moodSvgAsset!,
      width: 1,
      height: 1,
    ).bytesLoader;
    _moodAssetWarmup = loader.loadBytes(context).then((_) {});
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
    final warmupFuture = _moodAssetWarmup ?? Future.value();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              details.color.withValues(alpha: 0.18),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThai ? 'ผลลัพธ์อารมณ์' : 'Emotion Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        localizedMoodName,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: details.color,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: Center(
                    child: FutureBuilder<void>(
                      future: warmupFuture,
                      builder: (context, snapshot) {
                        final ready = snapshot.connectionState == ConnectionState.done;
                        return AnimatedScale(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutBack,
                          scale: _revealed ? 1 : 0.94,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 320),
                            opacity: _revealed ? 1 : 0,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 420),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: details.color.withValues(alpha: 0.14),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: details.color.withValues(alpha: 0.12),
                                    blurRadius: 32,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: moodVisualSize + 36,
                                    height: moodVisualSize + 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          details.color.withValues(alpha: 0.18),
                                          details.color.withValues(alpha: 0.08),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: ready && svgAsset != null
                                        ? SvgPicture.asset(
                                            svgAsset,
                                            width: moodVisualSize,
                                            height: moodVisualSize,
                                            fit: BoxFit.contain,
                                          )
                                        : SizedBox(
                                            width: moodVisualSize,
                                            height: moodVisualSize,
                                          ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: details.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isThai ? 'ตรวจแล้ว' : 'Checked',
                                      style: TextStyle(
                                        color: details.color,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    localizedMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurface.withValues(alpha: 0.74),
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
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
                onPressed: _backToAnalytics,
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

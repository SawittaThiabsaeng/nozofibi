import 'package:flutter/material.dart';

import 'emotion_quiz_screen.dart';

class MoodStartScreen extends StatelessWidget {
  const MoodStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('th');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F2FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF131B2E)]
                : const [Color(0xFFF8F4FF), Color(0xFFFDFBFF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                isThai ? 'แบบทดสอบอารมณ์' : 'Mood Quiz',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 34),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFEDE9FE),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                      color: (isDark ? Colors.black : const Color(0xFF8B5CF6))
                          .withValues(alpha: isDark ? 0.22 : 0.12),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA78BFA), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isThai ? 'วันนี้คุณรู้สึกยังไงบ้าง?' : 'How are you, really?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isThai
                          ? 'ทำแบบทดสอบสั้น ๆ 5 ข้อ เพื่อสำรวจสภาวะอารมณ์ปัจจุบันของคุณ'
                          : 'Take a quick 5-question quiz to discover your current emotional state.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA78BFA), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmotionQuizScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          child: Text(isThai ? 'เริ่มแบบทดสอบ →' : 'Start Quiz →'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
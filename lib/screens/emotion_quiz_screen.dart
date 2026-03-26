import 'package:flutter/material.dart';
import '../features/emotion_quiz/mood_logic.dart';
import '../data/emotion_checkin_storage.dart';
import 'emotion_result_screen.dart';

class EmotionQuizScreen extends StatefulWidget {
  const EmotionQuizScreen({super.key});

  @override
  State<EmotionQuizScreen> createState() => _EmotionQuizScreenState();
}

class _EmotionQuizScreenState extends State<EmotionQuizScreen> {
  int _currentStep = 0;
  String _focus = '';
  String _energy = '';
  String _feeling = '';
  String _motivation = '';
  String _session = '';

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Focus Level',
      'options': ['high', 'medium', 'low'],
    },
    {
      'title': 'Energy Level',
      'options': ['high', 'medium', 'low'],
    },
    {
      'title': 'How are you feeling?',
      'options': ['calm', 'happy', 'stressed', 'bored', 'sleepy', 'love'],
    },
    {
      'title': 'Motivation Level',
      'options': ['high', 'medium', 'low'],
    },
    {
      'title': 'Session Experience',
      'options': ['smooth', 'difficult', 'distracted'],
    },
  ];

  String _questionTitleForStep(int step, bool isThai) {
    switch (step) {
      case 0:
        return isThai ? 'ระดับสมาธิ' : 'Focus Level';
      case 1:
        return isThai ? 'ระดับพลังงาน' : 'Energy Level';
      case 2:
        return isThai ? 'ตอนนี้คุณรู้สึกอย่างไร?' : 'How are you feeling?';
      case 3:
        return isThai ? 'ระดับแรงจูงใจ' : 'Motivation Level';
      case 4:
        return isThai ? 'ประสบการณ์ระหว่างทำงาน' : 'Session Experience';
      default:
        return '';
    }
  }

  String _optionLabel(String value, bool isThai) {
    if (!isThai) {
      return value;
    }

    switch (value) {
      case 'high':
        return 'สูง';
      case 'medium':
        return 'ปานกลาง';
      case 'low':
        return 'ต่ำ';
      case 'calm':
        return 'สงบ';
      case 'happy':
        return 'มีความสุข';
      case 'stressed':
        return 'เครียด';
      case 'bored':
        return 'เบื่อ';
      case 'sleepy':
        return 'ง่วง';
      case 'love':
        return 'อบอุ่นใจ';
      case 'smooth':
        return 'ราบรื่น';
      case 'difficult':
        return 'ค่อนข้างยาก';
      case 'distracted':
        return 'วอกแวก';
      default:
        return value;
    }
  }

  Future<void> _next(String value) async {
    if (_currentStep == 0) {
      _focus = value;
    } else if (_currentStep == 1) {
      _energy = value;
    } else if (_currentStep == 2) {
      _feeling = value;
    } else if (_currentStep == 3) {
      _motivation = value;
    } else if (_currentStep == 4) {
      _session = value;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    final mood = getMood(
      _focus,
      _energy,
      _feeling,
      _motivation,
      _session,
    );

    await EmotionCheckinStorage.addCheckin(mood: mood);

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmotionResultScreen(mood: mood),
      ),
    );
  }

  Color _stepAccent(int step) {
    switch (step) {
      case 0:
        return const Color(0xFF8B5CF6);
      case 1:
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFFEC4899);
      case 3:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildOption(String text, VoidCallback onTap, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE9D5FF),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  color: (isDark ? Colors.black : accentColor).withValues(
                    alpha: isDark ? 0.16 : 0.12,
                  ),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt, color: accentColor),
                ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    fontSize: 18,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentStep];
    final isThai = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('th');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _stepAccent(_currentStep);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF1F2937)),
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
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isThai
                    ? 'ขั้นตอนที่ ${_currentStep + 1} จาก 5'
                    : 'Step ${_currentStep + 1} of 5',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 5,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFEDE9FE),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _questionTitleForStep(_currentStep, isThai),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 34),
              Expanded(
                child: ListView(
                  children: (q['options'] as List<String>).map<Widget>((opt) {
                    return _buildOption(
                      _optionLabel(opt, isThai),
                      () => _next(opt),
                      accentColor,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/emotion_checkin_storage.dart';
import 'emotion_result_screen.dart';

class EmotionQuizScreen extends StatefulWidget {
  const EmotionQuizScreen({super.key});

  @override
  State<EmotionQuizScreen> createState() => _EmotionQuizScreenState();
}

class _EmotionQuizScreenState extends State<EmotionQuizScreen> {
  int _currentStep = 0;
  final Map<String, int> _moodScores = <String, int>{};
  final List<List<String>> _selectedMoodGroups = <List<String>>[];

  final List<Map<String, dynamic>> _questions = [
    {
      'titleTh': 'ช่วงนี้เวลาคุณตื่นขึ้นมา ความรู้สึกแรกที่เข้ามาในใจคือแบบไหน?',
      'titleEn': 'When you wake up these days, what is the first feeling that comes to mind?',
      'options': [
        {
          'key': 'A',
          'labelTh': 'มีบางอย่างให้รออยู่ข้างหน้า',
          'labelEn': 'There is something ahead that I look forward to',
          'moods': ['Excited', 'Motivated'],
        },
        {
          'key': 'B',
          'labelTh': 'พร้อมจะจัดการสิ่งต่าง ๆ ทีละอย่าง',
          'labelEn': 'Ready to handle things one by one',
          'moods': ['Focused'],
        },
        {
          'key': 'C',
          'labelTh': 'เฉย ๆ อีกวันหนึ่ง',
          'labelEn': 'Just another day',
          'moods': ['Neutral'],
        },
        {
          'key': 'D',
          'labelTh': 'ยังอยากนอนต่ออีกหน่อย',
          'labelEn': 'Still want to sleep a little longer',
          'moods': ['Sleepy'],
        },
      ],
    },
    {
      'titleTh': 'ถ้าวันนี้มีเรื่องไม่เป็นไปตามแผน คุณมักจะรู้สึกยังไงกับมัน?',
      'titleEn': 'If something does not go as planned today, how do you usually feel about it?',
      'options': [
        {
          'key': 'A',
          'labelTh': 'มันก็แค่เรื่องหนึ่ง เดี๋ยวก็ผ่านไป',
          'labelEn': 'It is just one thing, it will pass',
          'moods': ['Calm'],
        },
        {
          'key': 'B',
          'labelTh': 'พยายามแก้ให้ดีที่สุด',
          'labelEn': 'I try my best to fix it',
          'moods': ['Trying', 'Motivated'],
        },
        {
          'key': 'C',
          'labelTh': 'รู้สึกว่ามันเริ่มหนักขึ้นเรื่อย ๆ',
          'labelEn': 'It starts to feel heavier and heavier',
          'moods': ['Calm', 'Sleepy'],
        },
        {
          'key': 'D',
          'labelTh': 'แอบรู้สึกแย่กับตัวเองนิด ๆ',
          'labelEn': 'I quietly feel a bit bad about myself',
          'moods': ['Sad'],
        },
      ],
    },
    {
      'titleTh': 'เวลาที่คุณอยู่คนเดียวเงียบ ๆ คุณมักจะ…',
      'titleEn': 'When you are alone in quiet moments, you usually...',
      'options': [
        {
          'key': 'A',
          'labelTh': 'คิดถึงเรื่องดี ๆ หรือคนสำคัญ',
          'labelEn': 'Think about good moments or important people',
          'moods': ['Love', 'Happy'],
        },
        {
          'key': 'B',
          'labelTh': 'ปล่อยใจนิ่ง ๆ ไม่คิดอะไรมาก',
          'labelEn': 'Let your mind rest without thinking too much',
          'moods': ['Calm', 'Sleepy'],
        },
        {
          'key': 'C',
          'labelTh': 'เลื่อนอะไรไปเรื่อย ๆ',
          'labelEn': 'Scroll through things endlessly',
          'moods': ['Bored'],
        },
        {
          'key': 'D',
          'labelTh': 'คิดวนไปมา',
          'labelEn': 'Overthink in loops',
          'moods': ['Stressed', 'Sad'],
        },
      ],
    },
    {
      'titleTh': 'เวลาคุณอยากทำอะไรสักอย่าง คุณมักจะ…',
      'titleEn': 'When you want to do something, you usually...',
      'options': [
        {
          'key': 'A',
          'labelTh': 'ลงมือทำทันที',
          'labelEn': 'Start doing it right away',
          'moods': ['Excited'],
        },
        {
          'key': 'B',
          'labelTh': 'วางแผนก่อนแล้วค่อยทำ',
          'labelEn': 'Plan first, then do it',
          'moods': ['Focused'],
        },
        {
          'key': 'C',
          'labelTh': 'ลองดูเท่าที่ไหว',
          'labelEn': 'Try as much as I can',
          'moods': ['Trying'],
        },
        {
          'key': 'D',
          'labelTh': 'รู้สึกว่าเริ่มยากตั้งแต่ยังไม่เริ่ม',
          'labelEn': 'It already feels hard before starting',
          'moods': ['Stressed'],
        },
      ],
    },
    {
      'titleTh': 'ช่วงนี้ชีวิตของคุณให้ความรู้สึกแบบไหนมากที่สุด?',
      'titleEn': 'What feeling describes your life most these days?',
      'options': [
        {
          'key': 'A',
          'labelTh': 'กำลังไปข้างหน้า',
          'labelEn': 'Moving forward',
          'moods': ['Motivated'],
        },
        {
          'key': 'B',
          'labelTh': 'ไหลไปเรื่อย ๆ',
          'labelEn': 'Just flowing along',
          'moods': ['Neutral', 'Calm'],
        },
        {
          'key': 'C',
          'labelTh': 'เหมือนติดอยู่กับที่',
          'labelEn': 'Feeling stuck in place',
          'moods': ['Bored'],
        },
        {
          'key': 'D',
          'labelTh': 'เหมือนต้องแบกอะไรบางอย่าง',
          'labelEn': 'Like carrying something heavy',
          'moods': ['Sad', 'Stressed'],
        },
      ],
    },
    {
      'titleTh': 'เวลามีช่วงเวลาน่ารักเล็ก ๆ เกิดขึ้น คุณมักจะ…',
      'titleEn': 'When a small lovely moment happens, you usually...',
      'options': [
        {
          'key': 'A',
          'labelTh': 'ยิ้มออกมาโดยไม่รู้ตัว',
          'labelEn': 'Smile without realizing it',
          'moods': ['Happy'],
        },
        {
          'key': 'B',
          'labelTh': 'อยากแบ่งปันให้ใครสักคน',
          'labelEn': 'Want to share it with someone',
          'moods': ['Love'],
        },
        {
          'key': 'C',
          'labelTh': 'รับรู้มันแล้วก็ผ่านไป',
          'labelEn': 'Notice it and move on',
          'moods': ['Sleepy', 'Calm'],
        },
        {
          'key': 'D',
          'labelTh': 'แทบไม่ได้สังเกตมันเลย',
          'labelEn': 'Barely notice it',
          'moods': ['Bored', 'Sad'],
        },
      ],
    },
  ];

  String _questionTitleForStep(int step, bool isThai) {
    final q = _questions[step];
    return isThai ? q['titleTh'] as String : q['titleEn'] as String;
  }

  void _addMoodScores(List<String> moods) {
    for (final mood in moods) {
      _moodScores.update(mood, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  String _resolveMood() {
    if (_moodScores.isEmpty) {
      return 'Calm';
    }

    final maxScore = _moodScores.values.reduce((a, b) => a > b ? a : b);
    final topMoods = _moodScores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toSet();

    for (final selectedGroup in _selectedMoodGroups.reversed) {
      for (final mood in selectedGroup) {
        if (topMoods.contains(mood)) {
          return mood;
        }
      }
    }

    return topMoods.first;
  }

  Future<void> _next(List<String> moods) async {
    _selectedMoodGroups.add(moods);
    _addMoodScores(moods);

    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    final mood = _resolveMood();

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

  Widget _buildOption({
    required String keyLabel,
    required String text,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    keyLabel,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                      fontSize: 18,
                    ),
                  ),
                ),
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
                  ? 'ข้อที่ ${_currentStep + 1} จาก ${_questions.length}'
                  : 'Question ${_currentStep + 1} of ${_questions.length}',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _questions.length,
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
                  children: (q['options'] as List<Map<String, dynamic>>).map<Widget>((opt) => _buildOption(
                      keyLabel: opt['key'] as String,
                      text: isThai ? opt['labelTh'] as String : opt['labelEn'] as String,
                      onTap: () => _next(List<String>.from(opt['moods'] as List<dynamic>)),
                      accentColor: accentColor,
                    )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

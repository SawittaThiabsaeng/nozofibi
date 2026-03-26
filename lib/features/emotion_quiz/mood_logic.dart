import 'package:flutter/material.dart';

class MoodResult {
  final String name;
  final String emoji;
  final String message;
  final Color color;

  MoodResult({
    required this.name,
    required this.emoji,
    required this.message,
    required this.color,
  });
}

String getMood(
  String focus,
  String energy,
  String feeling,
  String motivation,
  String session,
) {
  final f = focus.toLowerCase();
  final e = energy.toLowerCase();
  final feelingValue = feeling.toLowerCase();
  final m = motivation.toLowerCase();
  final s = session.toLowerCase();

  if (f == 'high' && e == 'high' && m == 'high') {
    return 'Focused';
  }
  if (m == 'high') {
    return 'Motivated';
  }
  if (s == 'difficult') {
    return 'Trying';
  }
  if (feelingValue == 'calm' && s == 'smooth') {
    return 'Calm';
  }
  if (feelingValue == 'happy' && e == 'high') {
    return 'Excited';
  }
  if (feelingValue == 'happy') {
    return 'Happy';
  }
  if (feelingValue == 'love') {
    return 'Love';
  }
  if (e == 'low') {
    return 'Sleepy';
  }
  if (feelingValue == 'bored' || s == 'distracted') {
    return 'Bored';
  }
  if (f == 'low' && e == 'medium') {
    return 'Neutral';
  }
  if (feelingValue == 'stressed' && s == 'difficult') {
    return 'Stressed';
  }
  if (feelingValue == 'stressed') {
    return 'Sad';
  }

  return 'Calm';
}

String getMoodEmoji(String mood) {
  switch (mood) {
    case 'Focused':
      return '🎯';
    case 'Motivated':
      return '🔥';
    case 'Trying':
      return '💪';
    case 'Calm':
      return '🌿';
    case 'Excited':
      return '⚡';
    case 'Happy':
      return '😊';
    case 'Love':
      return '💖';
    case 'Sleepy':
      return '😴';
    case 'Bored':
      return '🥱';
    case 'Neutral':
      return '😐';
    case 'Stressed':
      return '😣';
    case 'Sad':
      return '😔';
    default:
      return '🌿';
  }
}

MoodResult getMoodDetails(
  String focus,
  String energy,
  String feeling,
  String motivation,
  String session,
) {
  final moodName = getMood(focus, energy, feeling, motivation, session);
  return getMoodDetailsByMood(moodName);
}

MoodResult getMoodDetailsByMood(String moodName) {
  switch (moodName) {
    case 'Focused':
      return MoodResult(
        name: 'Focused',
        emoji: '🎯',
        message: "You're in deep focus mode",
        color: const Color(0xFFA78BFA),
      );
    case 'Motivated':
      return MoodResult(
        name: 'Motivated',
        emoji: '🚀',
        message: "You're ready to take on anything",
        color: const Color(0xFFA78BFA),
      );
    case 'Trying':
      return MoodResult(
        name: 'Trying',
        emoji: '💪',
        message: "Keep going, you're doing your best",
        color: const Color(0xFFFB923C),
      );
    case 'Excited':
      return MoodResult(
        name: 'Excited',
        emoji: '✨',
        message: 'Your energy is contagious!',
        color: const Color(0xFFF472B6),
      );
    case 'Happy':
      return MoodResult(
        name: 'Happy',
        emoji: '😊',
        message: 'Keep spreading that positivity',
        color: const Color(0xFFFFD60A),
      );
    case 'Love':
      return MoodResult(
        name: 'Love',
        emoji: '💖',
        message: 'Feeling the warmth today',
        color: const Color(0xFFEC4899),
      );
    case 'Sleepy':
      return MoodResult(
        name: 'Sleepy',
        emoji: '😴',
        message: 'You seem low on energy',
        color: const Color(0xFF94A3B8),
      );
    case 'Bored':
      return MoodResult(
        name: 'Bored',
        emoji: '😑',
        message: "Maybe it's time for a change of pace",
        color: const Color(0xFF64748B),
      );
    case 'Neutral':
      return MoodResult(
        name: 'Neutral',
        emoji: '😐',
        message: "You're feeling balanced",
        color: const Color(0xFFCBD5E1),
      );
    case 'Stressed':
      return MoodResult(
        name: 'Stressed',
        emoji: '😫',
        message: "Take a deep breath, you've got this",
        color: const Color(0xFFEF4444),
      );
    case 'Sad':
      return MoodResult(
        name: 'Sad',
        emoji: '😔',
        message: "It's okay to have off days",
        color: const Color(0xFF3B82F6),
      );
    default:
      return MoodResult(
        name: 'Calm',
        emoji: '🌿',
        message: 'You feel balanced',
        color: const Color(0xFF10B981),
      );
  }
}

String getMoodMessage(String mood) {
  switch (mood) {
    case 'Focused':
      return "You're in deep focus mode 🎯";
    case 'Motivated':
      return "Your drive is strong. Keep it going.";
    case 'Trying':
      return 'It was challenging, but you kept pushing.';
    case 'Calm':
      return 'You feel balanced 🌿';
    case 'Excited':
      return 'Great energy and positive momentum.';
    case 'Happy':
      return 'You seem to be in a good mood today.';
    case 'Love':
      return 'You are feeling warm and connected.';
    case 'Sleepy':
      return 'You seem low on energy 😴';
    case 'Bored':
      return 'Focus drifted. A short reset may help.';
    case 'Neutral':
      return 'A steady baseline. You can build from here.';
    case 'Stressed':
      return 'A lot was going on. Take a small breather.';
    case 'Sad':
      return 'You may be feeling heavy. Be gentle with yourself.';
    default:
      return 'You feel balanced 🌿';
  }
}

String getMoodMessageForLocale(
  String mood, {
  required bool isThai,
}) {
  switch (mood) {
    case 'Happy':
      return isThai
          ? 'วันนี้มีความสุขเล็ก ๆ อยู่รอบตัวคุณนะ ลองเก็บมันไว้ในใจดี ๆ'
          : 'Little moments of joy are all around you today. Hold them close 💛';
    case 'Calm':
      return isThai
          ? 'ใจคุณกำลังนิ่งสบายดีนะ อยู่กับความรู้สึกนี้ไปเรื่อย ๆ'
          : 'Your mind feels at ease. Stay in this calm for a while 🌿';
    case 'Excited':
      return isThai
          ? 'ความตื่นเต้นกำลังพาคุณไปสู่บางสิ่งที่น่ารอคอยนะ'
          : 'Your excitement is leading you toward something exciting ✨';
    case 'Focused':
      return isThai
          ? 'ตอนนี้คุณกำลังโฟกัสดีมาก ทำต่อไปได้เลยนะ'
          : 'You\'re in a strong focus right now. Keep it going 🎯';
    case 'Love':
      return isThai
          ? 'หัวใจคุณกำลังอบอุ่นดีนะ ลองส่งต่อความรู้สึกนี้ให้ใครสักคน'
          : 'Your heart feels warm. Share it with someone 💖';
    case 'Motivated':
      return isThai
          ? 'คุณมีแรงใจดีมากตอนนี้ ก้าวต่อไปได้อีกไกลเลยนะ'
          : 'You\'re feeling driven right now. Keep moving forward 🚀';
    case 'Neutral':
      return isThai
          ? 'วันนี้อาจจะเรียบ ๆ แต่ก็เป็นวันที่คุณยังไปต่อได้เรื่อย ๆ'
          : 'Today feels simple, but you\'re still moving forward 🌫️';
    case 'Sad':
      return isThai
          ? 'ถ้าวันนี้มันหนักไปบ้าง ก็ไม่เป็นไรนะ ค่อย ๆ อยู่กับมันไป'
          : 'If today feels heavy, that\'s okay. Take it one moment at a time 💙';
    case 'Sleepy':
      return isThai
          ? 'คุณดูเหนื่อยนิดหน่อยนะ ลองพักให้ตัวเองสบายขึ้นหน่อยนะ'
          : 'You seem a little tired. Give yourself some rest 😴';
    case 'Stressed':
      return isThai
          ? 'เหมือนทุกอย่างจะถาโถมเข้ามาเลยนะ ลองพักหายใจลึก ๆ ก่อน'
          : 'It feels like everything is piling up. Take a deep breath 🌧️';
    case 'Trying':
      return isThai
          ? 'คุณยังพยายามอยู่เสมอ และนั่นก็เก่งมากแล้วนะ'
          : 'You keep trying, and that\'s already something to be proud of 🌱';
    case 'Bored':
      return isThai
          ? 'ความเบื่ออาจกำลังบอกว่า ถึงเวลาลองอะไรใหม่ ๆ แล้วนะ'
          : 'Boredom might be a sign it\'s time to try something new 🌈';
    default:
      return isThai
          ? 'ใจคุณนิ่งดีนะ ใช้ช่วงเวลานี้พักผ่อนให้เต็มที่'
          : 'You feel calm. Take this moment to truly rest 🌿';
  }
}

String getMoodNameForLocale(
  String mood, {
  required bool isThai,
}) {
  if (!isThai) {
    return mood;
  }

  switch (mood) {
    case 'Focused':
      return 'โฟกัสดี';
    case 'Motivated':
      return 'มีแรงใจ';
    case 'Trying':
      return 'พยายามอยู่';
    case 'Calm':
      return 'สงบ';
    case 'Excited':
      return 'ตื่นเต้น';
    case 'Happy':
      return 'มีความสุข';
    case 'Love':
      return 'อบอุ่นใจ';
    case 'Sleepy':
      return 'ง่วง';
    case 'Bored':
      return 'เบื่อ';
    case 'Neutral':
      return 'เฉย ๆ';
    case 'Stressed':
      return 'เครียด';
    case 'Sad':
      return 'เศร้า';
    default:
      return mood;
  }
}

String? getMoodSvgAsset(String mood) {
  switch (mood) {
    case 'Focused':
      return 'assets/images/Focused.svg';
    case 'Motivated':
      return 'assets/images/Motivated.svg';
    case 'Trying':
      return 'assets/images/Trying.svg';
    case 'Calm':
      return 'assets/images/Calm.svg';
    case 'Excited':
      return 'assets/images/Excited.svg';
    case 'Happy':
      return 'assets/images/Happy.svg';
    case 'Love':
      return 'assets/images/Love.svg';
    case 'Sleepy':
      return 'assets/images/Sleepy.svg';
    case 'Bored':
      return 'assets/images/Bored.svg';
    case 'Neutral':
      return 'assets/images/Neutral.svg';
    case 'Stressed':
      return 'assets/images/Stressed.svg';
    case 'Sad':
      return 'assets/images/Sad.svg';
    default:
      return null;
  }
}

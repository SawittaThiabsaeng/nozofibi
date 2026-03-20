import 'dart:ui';
import 'package:flutter/material.dart';

class SoftBackground extends StatelessWidget {
  final Widget child;

  const SoftBackground({super.key, required this.child});

@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Stack(
    children: [

      /// Base Background (รองรับ Dark Mode)
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),

      /// Top Right Purple Blur
      Positioned(
        top: -120,
        right: -120,
        child: _blurCircle(
          color: const Color(0xFF8B5CF6),
          size: 300,
        ),
      ),

      /// Bottom Left Blue Blur
      Positioned(
        bottom: -150,
        left: -150,
        child: _blurCircle(
          color: const Color(0xFF60A5FA),
          size: 350,
        ),
      ),

      child,
    ],
  );
}

  Widget _blurCircle({
    required Color color,
    required double size,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.4),
        ),
      ),
    );
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';

class SoftBackground extends StatelessWidget {
  const SoftBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          /// Base Background (รองรับ Dark Mode)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),

          /// Top Right Purple Blur
          Positioned(
            top: -130,
            right: -130,
            child: _blurCircle(
              color: const Color(0xFF8B5CF6),
              size: 320,
            ),
          ),

          /// Bottom Left Blue Blur
          Positioned(
            bottom: -130,
            left: -130,
            child: _blurCircle(
              color: const Color(0xFF60A5FA),
              size: 320,
            ),
          ),

          child,
        ],
      );

  Widget _blurCircle({
    required Color color,
    required double size,
  }) =>
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.32),
          ),
        ),
      );
}

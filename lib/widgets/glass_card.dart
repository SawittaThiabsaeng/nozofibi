import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius = 40,
    this.isDarkMode = false,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.03),
            blurRadius: 32,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding ?? const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color ?? (isDarkMode ? const Color(0xCC1A1C26) : Colors.white.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
}

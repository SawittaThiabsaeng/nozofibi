import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {

  const GlassCard({
    required this.child, super.key,
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
  Widget build(BuildContext context) {
    final isDark =
      Theme.of(context).brightness == Brightness.dark ||
        isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.03),
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
                color: color ??
                    (isDark
                        ? const Color(0xCC11182A)
                        : Colors.white.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E2A45).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.6),
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
}

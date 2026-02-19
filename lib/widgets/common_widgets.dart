import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {

  const GlassCard({super.key, required this.child, this.padding, this.onTap, this.borderRadius = 32, this.color, this.height});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final double? height;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: height,
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color ?? Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
}

class GlowBlob extends StatelessWidget {
  const GlowBlob({super.key, required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
  );
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.label, required this.val, required this.color});
  final IconData icon;
  final String label;
  final String val;
  final Color color;
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: color, size: 28),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.caption),
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ])
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NozofibiText extends StatelessWidget {
  const NozofibiText({
    super.key,
    this.fontSize = 48,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
        'Nozofibi',
        style: GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D3436),
          letterSpacing: -1.8,
        ),
      );
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.fontSize = 48,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) => NozofibiText(fontSize: fontSize);
}

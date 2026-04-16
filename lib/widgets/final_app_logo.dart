import 'package:flutter/material.dart';

class NozofibiLogo extends StatefulWidget {
  const NozofibiLogo({super.key, this.size = 170});
  final double size;

  @override
  State<NozofibiLogo> createState() => _NozofibiLogoState();
}

class _NozofibiLogoState extends State<NozofibiLogo>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addObserver(this);
    // ⭐ Start animation after first frame to avoid unnecessary early renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    // ⭐ Pause animation when app is backgrounded to save battery
    if (state == AppLifecycleState.paused && _controller.isAnimating) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: LogoPainter(animationValue: _controller.value),
        ),
      );
}

class LogoPainter extends CustomPainter {
  LogoPainter({required this.animationValue});
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * scale
      ..strokeCap = StrokeCap.round;

    // 1. Define the Gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const Gradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF70A1FF), // Pastel Blue
        Color(0xFFA29BFE), // Soft Purple
        Color(0xFFFF9FF3), // Candy Pink
      ],
    );
    paint.shader = gradient.createShader(rect);

    // 2. Draw the 'N' Shape (Interlocking Loops)
    final leftPath = Path()
      ..moveTo(28 * scale, 75 * scale)
      ..lineTo(28 * scale, 45 * scale)
      ..cubicTo(
        28 * scale,
        25 * scale,
        48 * scale,
        25 * scale,
        50 * scale,
        45 * scale,
      )
      ..lineTo(50 * scale, 55 * scale);
    canvas.drawPath(leftPath, paint);

    final rightPath = Path()
      ..moveTo(50 * scale, 45 * scale)
      ..lineTo(50 * scale, 55 * scale)
      ..cubicTo(
        52 * scale,
        75 * scale,
        72 * scale,
        75 * scale,
        72 * scale,
        45 * scale,
      )
      ..lineTo(72 * scale, 25 * scale);
    canvas.drawPath(rightPath, paint);

    // 3. Draw Spark Glow
    final sparkX = 85 * scale;
    final sparkY = 15 * scale;
    final glowScale = 1.0 + (animationValue * 0.2);

    final glowPaint = Paint()
      ..color = const Color(0xFFFDCB6E).withValues(
        alpha: 0.3 * (1 - animationValue * 0.5),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale * glowScale);
    canvas.drawCircle(
        Offset(sparkX, sparkY), 12 * scale * glowScale, glowPaint);

    // 4. Draw the Spark (Golden Star)
    final sparkPaint = Paint()
      ..color = const Color(0xFFFDCB6E)
      ..style = PaintingStyle.fill;

    final sparkPath = Path()
      ..moveTo(85 * scale, 5 * scale)
      ..lineTo(88 * scale, 12 * scale)
      ..lineTo(95 * scale, 15 * scale)
      ..lineTo(88 * scale, 18 * scale)
      ..lineTo(85 * scale, 25 * scale)
      ..lineTo(82 * scale, 18 * scale)
      ..lineTo(75 * scale, 15 * scale)
      ..lineTo(82 * scale, 12 * scale)
      ..close();

    // Subtle Spark Animation (Scale & Rotate)
    canvas
      ..save()
      ..translate(sparkX, sparkY)
      ..scale(1.0 + (animationValue * 0.1))
      ..rotate(animationValue * 0.1)
      ..translate(-sparkX, -sparkY)
      ..drawPath(sparkPath, sparkPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) => true;
}

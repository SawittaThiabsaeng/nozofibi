import 'package:flutter/material.dart';

import '../widgets/brand_wordmark.dart';

class NozofibiSplashScreen extends StatefulWidget {
  const NozofibiSplashScreen({
    super.key,
    this.size = 150,
  });

  final double size;

  @override
  State<NozofibiSplashScreen> createState() => _NozofibiSplashScreenState();
}

class _NozofibiSplashScreenState extends State<NozofibiSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _drawingAnimation;
  late final Animation<double> _contentOpacity;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _drawingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.6, curve: Curves.easeInOutQuart),
      ),
    );

    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 1, curve: Curves.linear),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA29BFE).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _drawingAnimation,
                    builder: (context, child) => CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter:
                          NozofibiPainter(progress: _drawingAnimation.value),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: Column(
                      children: [
                        const NozofibiText(fontSize: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Feel everything, softly.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                const Color(0xFF2D3436).withValues(alpha: 0.4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) => Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200 * _progressAnimation.value,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF70A1FF), Color(0xFFA29BFE)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class NozofibiPainter extends CustomPainter {
  NozofibiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const Gradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF70A1FF), Color(0xFFA29BFE), Color(0xFFFF9FF3)],
    );
    paint.shader = gradient.createShader(rect);

    final fullPath = Path()
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

    for (final pathMetric in fullPath.computeMetrics()) {
      final extractPath = pathMetric.extractPath(
        0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }

    if (progress > 0.8) {
      final sparkOpacity = ((progress - 0.8) / 0.2).clamp(0, 1).toDouble();
      final sparkPaint = Paint()
        ..color = const Color(0xFFFDCB6E).withValues(alpha: sparkOpacity);
      final spark = Path()
        ..moveTo(85 * scale, 5 * scale)
        ..lineTo(88 * scale, 12 * scale)
        ..lineTo(95 * scale, 15 * scale)
        ..lineTo(88 * scale, 18 * scale)
        ..lineTo(85 * scale, 25 * scale)
        ..lineTo(82 * scale, 18 * scale)
        ..lineTo(75 * scale, 15 * scale)
        ..lineTo(82 * scale, 12 * scale)
        ..close();
      canvas.drawPath(spark, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant NozofibiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

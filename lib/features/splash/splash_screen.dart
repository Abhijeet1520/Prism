import 'dart:math';
import 'package:flutter/material.dart';

/// Animated splash screen with rotating Prism logo.
/// Shows geometric shapes orbiting a center while app initializes.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _shapeCtrl;
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shapeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadAndTransition();
  }

  Future<void> _loadAndTransition() async {
    // Minimum splash time for smooth animation
    await Future.delayed(const Duration(milliseconds: 2500));
    await _fadeCtrl.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _scaleCtrl.dispose();
    _shapeCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF060610),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Prism logo
              SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rotateCtrl, _scaleCtrl, _shapeCtrl]),
                  builder: (context, _) {
                    final scale = 0.9 + 0.1 * _scaleCtrl.value;
                    return Transform.scale(
                      scale: scale,
                      child: CustomPaint(
                        painter: _PrismLogoPainter(
                          rotation: _rotateCtrl.value * 2 * pi,
                          entrance: CurvedAnimation(
                            parent: _shapeCtrl,
                            curve: Curves.easeOutBack,
                          ).value,
                        ),
                        size: const Size(140, 140),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Title
              AnimatedBuilder(
                animation: _shapeCtrl,
                builder: (context, _) {
                  final opacity = Curves.easeOut.transform(
                    (_shapeCtrl.value - 0.3).clamp(0, 1).toDouble(),
                  );
                  return Opacity(
                    opacity: opacity,
                    child: const Text(
                      'Prism',
                      style: TextStyle(
                        color: Color(0xFFE2E2EC),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _shapeCtrl,
                builder: (context, _) {
                  final opacity = Curves.easeOut.transform(
                    (_shapeCtrl.value - 0.5).clamp(0, 1).toDouble(),
                  );
                  return Opacity(
                    opacity: opacity,
                    child: const Text(
                      'Your AI companion',
                      style: TextStyle(
                        color: Color(0xFF7A7A90),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFF818CF8).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the Prism logo: 4 colored geometric shapes orbiting a center.
class _PrismLogoPainter extends CustomPainter {
  final double rotation;
  final double entrance;

  _PrismLogoPainter({required this.rotation, required this.entrance});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    final shapes = [
      _ShapeInfo(const Color(0xFF818CF8), 0),
      _ShapeInfo(const Color(0xFF34D399), pi / 2),
      _ShapeInfo(const Color(0xFFF97316), pi),
      _ShapeInfo(const Color(0xFFF43F5E), 3 * pi / 2),
    ];

    for (var i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final angle = shape.angle + rotation;
      final delay = i * 0.15;
      final t = (entrance - delay).clamp(0.0, 1.0);
      final pos = Offset(
        center.dx + cos(angle) * radius * t,
        center.dy + sin(angle) * radius * t,
      );

      final paint = Paint()
        ..color = shape.color.withValues(alpha: t)
        ..style = PaintingStyle.fill;
      final glowPaint = Paint()
        ..color = shape.color.withValues(alpha: 0.3 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final shapeSize = 14.0 * t;

      switch (i) {
        case 0:
          canvas.drawCircle(pos, shapeSize, glowPaint);
          canvas.drawCircle(pos, shapeSize, paint);
        case 1:
          _drawDiamond(canvas, pos, shapeSize, glowPaint);
          _drawDiamond(canvas, pos, shapeSize, paint);
        case 2:
          _drawPentagon(canvas, pos, shapeSize, glowPaint);
          _drawPentagon(canvas, pos, shapeSize, paint);
        case 3:
          _drawStar(canvas, pos, shapeSize, glowPaint);
          _drawStar(canvas, pos, shapeSize, paint);
      }
    }

    final centerPaint = Paint()
      ..color = const Color(0xFFE2E2EC).withValues(alpha: entrance * 0.6);
    canvas.drawCircle(center, 4 * entrance, centerPaint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.7, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawPentagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final point = Offset(
        center.dx + cos(angle) * size,
        center.dy + sin(angle) * size,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) - pi / 2;
      final r = i.isEven ? size : size * 0.5;
      final point = Offset(
        center.dx + cos(angle) * r,
        center.dy + sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PrismLogoPainter old) =>
      rotation != old.rotation || entrance != old.entrance;
}

class _ShapeInfo {
  final Color color;
  final double angle;
  const _ShapeInfo(this.color, this.angle);
}

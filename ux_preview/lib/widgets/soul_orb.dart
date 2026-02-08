import 'dart:math';
import 'package:flutter/material.dart';

/// Animated soul-like orb widget.
/// Not a perfect circle — has organic edges with noise displacement,
/// gentle pulsing, rotation, and glow effect.
class SoulOrb extends StatefulWidget {
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final bool animationsEnabled;

  const SoulOrb({
    super.key,
    this.size = 180,
    this.color = const Color(0xFF818CF8),
    this.onTap,
    this.animationsEnabled = true,
  });

  @override
  State<SoulOrb> createState() => _SoulOrbState();
}

class _SoulOrbState extends State<SoulOrb> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _morphCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    if (widget.animationsEnabled) {
      _pulseCtrl.repeat(reverse: true);
      _rotateCtrl.repeat();
      _morphCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(SoulOrb old) {
    super.didUpdateWidget(old);
    if (widget.animationsEnabled && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
      _rotateCtrl.repeat();
      _morphCtrl.repeat();
    } else if (!widget.animationsEnabled && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _rotateCtrl.stop();
      _morphCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _morphCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseCtrl, _rotateCtrl, _morphCtrl]),
        builder: (context, _) {
          final scale = 0.95 + 0.05 * _pulseCtrl.value;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _SoulOrbPainter(
                  color: widget.color,
                  rotation: _rotateCtrl.value * 2 * pi,
                  morphPhase: _morphCtrl.value * 2 * pi,
                  pulseValue: _pulseCtrl.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Paints the organic orb shape with glow layers.
class _SoulOrbPainter extends CustomPainter {
  final Color color;
  final double rotation;
  final double morphPhase;
  final double pulseValue;

  _SoulOrbPainter({
    required this.color,
    required this.rotation,
    required this.morphPhase,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.38;

    // Outer glow (3 layers)
    for (var i = 3; i >= 1; i--) {
      final glowPath = _buildOrbPath(
        center,
        baseRadius + i * 8,
        rotation,
        morphPhase,
        noiseAmount: 0.08,
      );
      canvas.drawPath(
        glowPath,
        Paint()
          ..color = color.withValues(alpha: 0.05 * (4 - i))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 + i * 6),
      );
    }

    // Inner glow
    final innerGlowPath = _buildOrbPath(
      center, baseRadius + 2, rotation, morphPhase,
      noiseAmount: 0.1,
    );
    canvas.drawPath(
      innerGlowPath,
      Paint()
        ..color = color.withValues(alpha: 0.2 + 0.1 * pulseValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Main body — gradient fill
    final mainPath = _buildOrbPath(
      center, baseRadius, rotation, morphPhase,
      noiseAmount: 0.12,
    );

    final gradient = RadialGradient(
      colors: [
        color.withValues(alpha: 0.6),
        color.withValues(alpha: 0.3),
        color.withValues(alpha: 0.08),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawPath(
      mainPath,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: baseRadius),
        ),
    );

    // Edge highlight
    canvas.drawPath(
      mainPath,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Core bright spot
    final coreGradient = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.25 + 0.1 * pulseValue),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
    canvas.drawCircle(
      Offset(center.dx - baseRadius * 0.15, center.dy - baseRadius * 0.15),
      baseRadius * 0.35,
      Paint()
        ..shader = coreGradient.createShader(
          Rect.fromCircle(
            center: Offset(center.dx - baseRadius * 0.15, center.dy - baseRadius * 0.15),
            radius: baseRadius * 0.35,
          ),
        ),
    );
  }

  /// Build an organic orb path using sine-based noise displacement.
  Path _buildOrbPath(
    Offset center,
    double radius,
    double rotation,
    double phase, {
    double noiseAmount = 0.1,
  }) {
    final path = Path();
    const segments = 72;

    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;

      // Multi-frequency noise for organic shape
      final noise = noiseAmount *
          radius *
          (sin(angle * 3 + phase) * 0.4 +
              sin(angle * 5 + phase * 1.3 + rotation) * 0.3 +
              sin(angle * 7 + phase * 0.7) * 0.2 +
              cos(angle * 2 + rotation * 0.5) * 0.1);

      final r = radius + noise;
      final x = center.dx + cos(angle + rotation * 0.1) * r;
      final y = center.dy + sin(angle + rotation * 0.1) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SoulOrbPainter old) =>
      rotation != old.rotation ||
      morphPhase != old.morphPhase ||
      pulseValue != old.pulseValue ||
      color != old.color;
}

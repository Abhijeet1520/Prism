import 'package:flutter/material.dart';

/// Animated splash screen with the Soul Orb.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)),
    );
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.7, curve: Curves.easeIn)),
    );
    _ctrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: _scale.value,
                  child: _SoulOrb(accent: accent),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: _opacity.value,
                  child: Text(
                    'Prism',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SoulOrb extends StatelessWidget {
  final Color accent;
  const _SoulOrb({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.2),
          colors: [accent, accent.withValues(alpha: 0.6), const Color(0xFF1E1B4B)],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 10),
          BoxShadow(color: accent.withValues(alpha: 0.06), blurRadius: 120, spreadRadius: 40),
        ],
      ),
    );
  }
}

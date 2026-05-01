import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/groove_pattern.dart';

class LatticeStage extends StatelessWidget {
  const LatticeStage({
    super.key,
    required this.pattern,
    required this.phase,
    required this.visualCrossings,
    required this.glow,
  });

  final GroovePattern pattern;
  final double phase;
  final bool visualCrossings;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _StagePainter(
          steps: pattern.steps,
          phase: phase,
          crossings: visualCrossings,
          glow: glow,
          primary: cs.primary,
          secondary: cs.secondary,
          outline: cs.outline,
        ),
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  _StagePainter({
    required this.steps,
    required this.phase,
    required this.crossings,
    required this.glow,
    required this.primary,
    required this.secondary,
    required this.outline,
  });

  final List<int> steps;
  final double phase;
  final bool crossings;
  final bool glow;
  final Color primary;
  final Color secondary;
  final Color outline;

  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a ~/ _gcd(a, b)) * b;
  }

  static int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x;
  }

  int _cycleLen() {
    if (steps.isEmpty) return 1;
    var g = steps.first;
    for (var i = 1; i < steps.length; i++) {
      g = _lcm(g, steps[i]);
    }
    return g;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.shortestSide * 0.28;
    final cycle = _cycleLen();
    final tick = (phase * cycle).floor() % cycle;

    for (var vi = 0; vi < steps.length; vi++) {
      final s = steps[vi];
      if (s <= 0) continue;
      final stepWidth = cycle ~/ s;
      final r = baseR + vi * 16.0;

      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = crossings ? 3 : 2
        ..color = outline.withValues(alpha: crossings ? 0.32 : 0.2);
      canvas.drawCircle(center, r, ring);

      for (var k = 0; k < s; k++) {
        final slot = (k * stepWidth) % cycle;
        final active = tick == slot;
        final ang = -math.pi / 2 + 2 * math.pi * (k / s);
        final pos = center + Offset(math.cos(ang), math.sin(ang)) * r;
        if (glow && crossings && active) {
          canvas.drawCircle(
            pos,
            16,
            Paint()
              ..color = secondary.withValues(alpha: 0.35)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
          );
        }
        final fill = vi.isEven ? primary : secondary;
        canvas.drawCircle(
          pos,
          active ? 9 : 6,
          Paint()..color = fill.withValues(alpha: crossings ? (active ? 1 : 0.55) : 0.7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StagePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.crossings != crossings ||
      oldDelegate.glow != glow ||
      oldDelegate.steps.join(',') != steps.join(',');
}

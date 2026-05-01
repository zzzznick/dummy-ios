import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rhythmic lattice used on the cold-start gate before the local shell mounts.
class GrooveBootLattice extends StatelessWidget {
  const GrooveBootLattice({
    super.key,
    required this.phase,
    required this.color,
    required this.secondary,
  });

  final double phase;
  final Color color;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: CustomPaint(
        painter: _LatticePainter(phase: phase, color: color, secondary: secondary),
      ),
    );
  }
}

class _LatticePainter extends CustomPainter {
  _LatticePainter({
    required this.phase,
    required this.color,
    required this.secondary,
  });

  final double phase;
  final Color color;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color.withValues(alpha: 0.35);
    canvas.drawCircle(c, r * 0.92, ring);

    const voices = 5;
    for (var v = 0; v < voices; v++) {
      final t = (phase + v / voices) % 1.0;
      final a = t * 2 * math.pi;
      final len = r * (0.35 + 0.12 * math.sin((v + 1) * 1.7 + phase * 6));
      final p2 = c + Offset(math.cos(a), math.sin(a)) * len;
      final line = Paint()
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: <Color>[
            secondary.withValues(alpha: 0.15 + 0.55 * math.sin(v + phase * 12).abs()),
            color.withValues(alpha: 0.55),
          ],
        ).createShader(Rect.fromPoints(c, p2));
      canvas.drawLine(c, p2, line);

      canvas.drawCircle(
        p2,
        5 + v.toDouble(),
        Paint()..color = color.withValues(alpha: 0.35 + (1 - v / voices) * 0.4),
      );
    }

    canvas.drawCircle(
      c,
      10 + 8 * math.sin(phase * 2 * math.pi),
      Paint()..color = secondary,
    );
  }

  @override
  bool shouldRepaint(covariant _LatticePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color || oldDelegate.secondary != secondary;
}

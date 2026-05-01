import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Orbital facet gate before the local shell mounts (distinct from lattice / petal boot UIs).
class OreBootProbe extends StatelessWidget {
  const OreBootProbe({
    super.key,
    required this.phase,
    required this.primary,
    required this.accent,
  });

  final double phase;
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey<String>('ov_boot_gate'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          SizedBox(
            width: 176,
            height: 176,
            child: CustomPaint(
              painter: _OrbitFacetPainter(phase: phase, primary: primary, accent: accent),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ore Vein',
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Charting the fracture line',
            style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
    );
  }
}

class _OrbitFacetPainter extends CustomPainter {
  _OrbitFacetPainter({
    required this.phase,
    required this.primary,
    required this.accent,
  });

  final double phase;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;

    for (var ring = 0; ring < 3; ring++) {
      final rr = r * (0.38 + ring * 0.18);
      final rot = (phase + ring * 0.11) * 2 * math.pi;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 + ring.toDouble()
        ..color = (ring.isEven ? primary : accent).withValues(alpha: 0.28 + ring * 0.12);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rr * 2.15, height: rr * 1.35), p);
      canvas.restore();
    }

    final core = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          accent.withValues(alpha: 0.92),
          primary.withValues(alpha: 0.55),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r * 0.22));
    canvas.drawCircle(c, r * 0.22 + 4 * math.sin(phase * 2 * math.pi), core);

    for (var k = 0; k < 6; k++) {
      final a = (k / 6 + phase * 0.4) * 2 * math.pi;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * r * 0.55;
      final p2 = c + Offset(math.cos(a + 0.9), math.sin(a + 0.9)) * r * 0.72;
      final edge = Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = primary.withValues(alpha: 0.45);
      canvas.drawLine(p1, p2, edge);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitFacetPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.primary != primary || oldDelegate.accent != accent;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Blossom drift + segmented progress used on cold-start before shell mounts.
class EastGardenBootBloom extends StatelessWidget {
  const EastGardenBootBloom({
    super.key,
    required this.phase,
    required this.pulse,
    required this.primary,
    required this.accent,
  });

  /// 0–1 looping controller value.
  final double phase;

  /// 0–1 second slower wave for bars.
  final double pulse;

  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _PetalPainter(phase: phase, primary: primary, accent: accent),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  key: const ValueKey<String>('eg_boot_gate'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _SegmentGlow(phase: phase, pulse: pulse, primary: primary, accent: accent),
                    const SizedBox(height: 18),
                    Text(
                      'East Garden',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quiet hands, steady winds ahead',
                      style: t.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentGlow extends StatelessWidget {
  const _SegmentGlow({
    required this.phase,
    required this.pulse,
    required this.primary,
    required this.accent,
  });

  final double phase;
  final double pulse;
  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(5, (i) {
        final t = (phase + i * 0.18 + pulse * 0.06) % 1.0;
        final glow = Curves.easeInOut.transform(t);
        final shimmer = (0.25 + glow * 0.5).clamp(0.08, 0.92);
        final accentFill = (0.35 + glow * 0.35).clamp(0.08, 0.94);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 5, right: i == 4 ? 0 : 0),
            child: Container(
              height: (10 + glow * 6).clamp(8.0, 18.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: <Color>[
                    primary.withValues(alpha: shimmer),
                    accent.withValues(alpha: accentFill),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 0.5,
                    color: accent.withValues(alpha: (0.22 + glow * 0.35).clamp(0.12, 0.55)),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PetalPainter extends CustomPainter {
  _PetalPainter({
    required this.phase,
    required this.primary,
    required this.accent,
  });

  final double phase;
  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var k = 0; k < 18; k++) {
      final x0 = rnd.nextDouble() * size.width;
      final spd = 0.35 + rnd.nextDouble() * 0.55;
      final y = ((phase * spd + k * 0.07) % 1.4) * size.height * 0.92;
      final wobble = math.sin((phase + k * 0.21) * 2 * math.pi) * 6;
      final c = Offset(x0 + wobble, y);

      final p = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.35),
            primary.withValues(alpha: 0.08),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: 9));

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate((phase + k * 0.13) * 2 * math.pi);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(6, -10, 12, 0)
        ..quadraticBezierTo(6, 10, 0, 0);
      canvas.drawPath(path, p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.primary != primary || oldDelegate.accent != accent;
}

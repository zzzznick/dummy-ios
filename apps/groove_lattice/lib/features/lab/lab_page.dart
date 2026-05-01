import 'dart:math' as math;

import 'package:flutter/material.dart';

class LabPage extends StatefulWidget {
  const LabPage({super.key});

  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> with SingleTickerProviderStateMixin {
  double _ratioA = 3;
  double _ratioB = 4;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
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

  static int _lcmPair(int x, int y) {
    if (x == 0 || y == 0) return 0;
    return (x ~/ _gcd(x, y)) * y;
  }

  String get _resetWindow {
    final x = _ratioA.round();
    final y = _ratioB.round();
    final l = _lcmPair(x, y);
    return 'Cycles realign after $l master ticks ($x:$y).';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Polyrhythm microscope', style: t.titleMedium),
          Text(
            'Pair two denominators without audio—watch how rotations line up visually.',
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text('Numerator ${_ratioA.round()} • Denominator ${_ratioB.round()}', style: t.bodyLarge),
          Slider(
            value: _ratioA,
            min: 2,
            max: 13,
            divisions: 11,
            label: '${_ratioA.round()}',
            onChanged: (v) => setState(() => _ratioA = v.roundToDouble()),
          ),
          Slider(
            value: _ratioB,
            min: 2,
            max: 13,
            divisions: 11,
            label: '${_ratioB.round()}',
            onChanged: (v) => setState(() => _ratioB = v.roundToDouble()),
          ),
          Text(
            _resetWindow,
            style: t.bodyMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _spin,
              builder: (context, _) {
                return CustomPaint(
                  painter: _DualRingPainter(
                    a: _ratioA.round(),
                    b: _ratioB.round(),
                    phase: _spin.value,
                    primary: cs.primary,
                    secondary: cs.secondary,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  _DualRingPainter({
    required this.a,
    required this.b,
    required this.phase,
    required this.primary,
    required this.secondary,
  });

  final int a;
  final int b;
  final double phase;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rOuter = math.min(size.width, size.height) * 0.38;
    final rInner = rOuter - 42;

    void drawDots(int divisions, Color color, double radius, double twist) {
      for (var i = 0; i < divisions; i++) {
        final ang = twist + 2 * math.pi * (i / divisions) + phase * 2 * math.pi * 0.4;
        final p = center + Offset(math.cos(ang), math.sin(ang)) * radius;
        canvas.drawCircle(
          p,
          8,
          Paint()..color = color.withValues(alpha: 0.9),
        );
      }
    }

    canvas.drawCircle(
      center,
      rOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = primary.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      center,
      rInner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = secondary.withValues(alpha: 0.35),
    );

    drawDots(a.clamp(2, 32), primary, rOuter, 0);
    drawDots(b.clamp(2, 32), secondary, rInner, math.pi / 12);
  }

  @override
  bool shouldRepaint(covariant _DualRingPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.a != a || oldDelegate.b != b;
}

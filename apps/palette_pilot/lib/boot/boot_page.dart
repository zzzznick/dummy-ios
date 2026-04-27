import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../app_common/app_common.dart';
import '../app/settings/app_settings_controller.dart';
import '../shell/palette_pilot_shell.dart';
import 'remote_config_spec.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key, required this.settings, this.enableAutoStart = true});

  final AppSettingsController settings;
  final bool enableAutoStart;

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final BootCoordinator _coordinator = BootCoordinator(
    remoteConfigClient: RemoteConfigClient(
      endpoint: remoteConfigEndpoint,
      keys: remoteConfigKeys,
    ),
    localHomeBuilder: (_) => PalettePilotShell(settings: widget.settings),
    debugLog: (m) => debugPrint(m),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enableAutoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        _coordinator.start(context);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.18),
              scheme.tertiary.withValues(alpha: 0.14),
              scheme.surface,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OrbitMark(controller: _controller),
                    const SizedBox(height: 28),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 6,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: (sin(_controller.value * pi * 2) + 1) / 2,
                              backgroundColor: scheme.outlineVariant.withValues(alpha: 0.25),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Preparing your color lab',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Palettes, contrast, mixing, and exports are ready offline.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitMark extends StatelessWidget {
  const _OrbitMark({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 156,
      height: 156,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _OrbitPainter(
              t: controller.value,
              a: scheme.primary,
              b: scheme.secondary,
              c: scheme.tertiary,
              stroke: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.t,
    required this.a,
    required this.b,
    required this.c,
    required this.stroke,
  });

  final double t;
  final Color a;
  final Color b;
  final Color c;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = min(size.width, size.height) * 0.34;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = stroke;
    canvas.drawCircle(center, r, ring);

    void dot(double phase, Color color, double radius) {
      final ang = (t * pi * 2) + phase;
      final p = center + Offset(cos(ang), sin(ang)) * r;
      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(p, radius, paint);
      canvas.drawCircle(p, radius - 2, Paint()..color = color);
    }

    dot(0.2, a, 10);
    dot(2.4, b, 9);
    dot(4.6, c, 8);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.a != a ||
        oldDelegate.b != b ||
        oldDelegate.c != c ||
        oldDelegate.stroke != stroke;
  }
}


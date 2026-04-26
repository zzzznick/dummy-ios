import 'dart:math' as math;

import 'package:app_common/app_common.dart';
import 'package:flutter/material.dart';

import '../app/gauge_scope.dart';
import '../data/gauge_store.dart';
import '../shell/main_shell.dart';
import 'remote_config_endpoint.dart';
import 'remote_config_keys.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> with SingleTickerProviderStateMixin {
  late final Future<GaugeStore> _storeReady;
  late final AnimationController _ring;
  late final BootCoordinator _coordinator;
  var _minBootElapsed = false;

  @override
  void initState() {
    super.initState();
    _storeReady = _load();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _coordinator = BootCoordinator(
      remoteConfigClient: RemoteConfigClient(
        endpoint: remoteConfigEndpoint,
        keys: remoteConfigKeys,
      ),
      localHomeBuilder: (_) {
        return FutureBuilder<GaugeStore>(
          future: _storeReady,
          builder: (BuildContext c, AsyncSnapshot<GaugeStore> s) {
            if (s.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (!s.hasData) {
              return const Scaffold(
                body: Center(child: Text('Could not load workspace')),
              );
            }
            return GaugeScope(store: s.data!, child: const MainShell());
          },
        );
      },
      debugLog: (String m) => debugPrint(m),
    );
    Future<void>.delayed(const Duration(milliseconds: 480), () {
      if (mounted) setState(() => _minBootElapsed = true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _storeReady;
      } catch (_) {}
      if (!mounted) return;
      if (!context.mounted) return;
      await _coordinator.start(context);
    });
  }

  Future<GaugeStore> _load() async {
    final s = GaugeStore();
    await s.ready;
    return s;
  }

  @override
  void dispose() {
    _ring.dispose();
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF134E4A), Color(0xFF0F766E), Color(0xFF0D9488)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _ring,
                builder: (BuildContext c, _) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: _DialRingsPainter(phase: _ring.value, readyHint: _minBootElapsed),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Dialing the grid',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gauge Grid · local measurements',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (BuildContext c, double v, _) {
                      return LinearProgressIndicator(
                        value: v,
                        minHeight: 5,
                        color: const Color(0xFF99F6E4),
                        backgroundColor: Colors.white12,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialRingsPainter extends CustomPainter {
  _DialRingsPainter({required this.phase, required this.readyHint});

  final double phase;
  final bool readyHint;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final m = size.shortestSide * 0.5;
    for (var k = 0; k < 4; k++) {
      final r = m * (0.3 + 0.18 * k);
      final t = 2 * math.pi * (phase * 0.4 + k * 0.15);
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF5EEAD4),
          const Color(0xFF14B8A6),
          ((k + phase) * 0.2).remainder(1.0).abs(),
        )!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + 2.0 * math.sin(t);
      canvas.drawCircle(c, r, paint);
    }
    for (var i = 0; i < 8; i++) {
      final a = (2 * math.pi * i) / 8 + phase * 2 * math.pi;
      final p = c + Offset(m * 0.38 * math.cos(a), m * 0.38 * math.sin(a));
      final paint = Paint()..color = const Color(0xCCFFFFFF);
      canvas.drawCircle(p, 2.5, paint);
    }
    if (readyHint) {
      final t = 2 * math.pi * phase;
      for (var j = 0; j < 3; j++) {
        final a = t + j * 2.1;
        final p = c + Offset(22 * math.cos(a), 22 * math.sin(a));
        canvas.drawCircle(
          p,
          4,
          Paint()..color = const Color(0x88FFFFFF)..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DialRingsPainter old) =>
      old.phase != phase || old.readyHint != readyHint;
}

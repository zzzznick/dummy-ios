import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/settings/east_settings_controller.dart';

class BloomGardenPage extends StatefulWidget {
  const BloomGardenPage({super.key, required this.settings});

  final EastSettingsController settings;

  @override
  State<BloomGardenPage> createState() => _BloomGardenPageState();
}

class _BloomGardenPageState extends State<BloomGardenPage> with TickerProviderStateMixin {
  Timer? _ticker;
  int _secondsLeft = 0;
  var _running = false;
  DateTime _anchor = DateTime.now();
  Duration _planned = Duration.zero;

  late final AnimationController _breathe =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

  @override
  void dispose() {
    _ticker?.cancel();
    _breathe.dispose();
    super.dispose();
  }

  void _startSession() {
    _ticker?.cancel();
    final minutes = widget.settings.value.bloomPresetMinutes;
    final target = Duration(minutes: minutes);
    _anchor = DateTime.now();
    _planned = target;
    setState(() {
      _running = true;
      _secondsLeft = target.inSeconds.clamp(0, 86400);
    });

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_running) return;
      final elapsed = DateTime.now().difference(_anchor);
      final left = (_planned - elapsed).inSeconds;
      setState(() {
        _secondsLeft = left.clamp(0, 86400);
        if (_secondsLeft <= 0) {
          _running = false;
          _ticker?.cancel();
        }
      });
    });
  }

  void _halt() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final m = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        final preset = widget.settings.value.bloomPresetMinutes;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Bloom nook', style: m.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'A quiet ring that borrows timing from Sketch settings. Pause between wind drills or let petals mark a soft break.',
                style: m.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Center(
                child: AnimatedBuilder(
                  animation: _breathe,
                  builder: (context, _) {
                    final scale = Curves.easeInOut.transform(_breathe.value) * 0.08 + 0.94;
                    final denom = math.max(_planned.inSeconds, 1);
                    final frac = !_running ? 0.0 : ((_planned.inSeconds - _secondsLeft).clamp(0, denom)) / denom;
                    return SizedBox.square(
                      dimension: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Transform.scale(
                            scale: scale,
                            child: SizedBox.square(
                              dimension: 200,
                              child: CircularProgressIndicator(
                                strokeWidth: 10,
                                value: frac,
                                backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          if (_running && _planned.inSeconds > 0 && _secondsLeft > 0)
                            Text(
                              _formatRemain(_secondsLeft),
                              style: m.titleLarge,
                            ),
                          if (!_running)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                'Preset $preset minutes from Settings.',
                                style: m.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (_running && _secondsLeft <= 0)
                            Text(
                              'Session eased',
                              style: m.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.tonal(onPressed: _running ? null : _startSession, child: const Text('Begin calm ring')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _running ? _halt : null, child: const Text('Pause ring')),
              const SizedBox(height: 20),
              Text(
                'Not medical advice · pure ambient timing for rehearsals.',
                style: m.bodySmall?.copyWith(color: cs.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatRemain(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

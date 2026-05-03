import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../services/ore_vein_data_store.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key, required this.settings, required this.data});

  final AppSettingsController settings;
  final OreVeinDataStore data;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late Duration _remaining;
  Timer? _t;
  var _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = Duration(seconds: widget.data.lastTimerSeconds);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_running && oldWidget.data.lastTimerSeconds != widget.data.lastTimerSeconds) {
      setState(() {
        _remaining = Duration(seconds: widget.data.lastTimerSeconds);
      });
    }
  }

  void _applyPreset(int sec) {
    _t?.cancel();
    setState(() {
      _running = false;
      _remaining = Duration(seconds: sec);
    });
    widget.data.setLastTimerSeconds(sec);
  }

  void _toggle() {
    if (_running) {
      _t?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining.inSeconds <= 0) {
      _remaining = Duration(seconds: widget.data.lastTimerSeconds);
    }
    setState(() => _running = true);
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds <= 1) {
        _t?.cancel();
        setState(() {
          _running = false;
          _remaining = Duration.zero;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer finished')),
        );
        return;
      }
      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    });
  }

  void _reset() {
    _t?.cancel();
    setState(() {
      _running = false;
      _remaining = Duration(seconds: widget.data.lastTimerSeconds);
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[widget.settings, widget.data]),
      builder: (context, _) {
        final face = widget.settings.value.timerFace;
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final e in <MapEntry<String, int>>[
                    const MapEntry('1 min', 60),
                    const MapEntry('5 min', 300),
                    const MapEntry('10 min', 600),
                    const MapEntry('15 min', 900),
                  ])
                    FilledButton.tonal(
                      onPressed: _running ? null : () => _applyPreset(e.value),
                      child: Text(e.key),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: face == TimerFace.rings
                      ? SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: CircularProgressIndicator(
                                  value: () {
                                    final d = widget.data.lastTimerSeconds <= 0 ? 1 : widget.data.lastTimerSeconds;
                                    return (_remaining.inSeconds / d).clamp(0.0, 1.0);
                                  }(),
                                  strokeWidth: 10,
                                  backgroundColor: cs.surfaceContainerHighest,
                                ),
                              ),
                              Text(
                                _fmt(_remaining),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                                    ),
                              ),
                            ],
                          ),
                        )
                      : face == TimerFace.bold
                          ? Text(
                              _fmt(_remaining),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                                  ),
                            )
                          : Text(
                              _fmt(_remaining),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                                  ),
                            ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: _toggle,
                      child: Text(_running ? 'Pause' : 'Start'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _running ? null : _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../models/groove_pattern.dart';
import '../../services/groove_store.dart';
import '../../widgets/lattice_stage.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({
    super.key,
    required this.store,
    required this.settings,
  });

  final GrooveStore store;
  final AppSettingsController settings;

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> with SingleTickerProviderStateMixin {
  late final AnimationController _beat;
  int _lastBpm = -1;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _beat.repeat();
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[widget.store, widget.settings]),
      builder: (context, _) {
        final g = widget.store.active;
        if (g == null) {
          return const Center(child: Text('Add a lattice from the Composer tab.'));
        }
        if (g.bpm != _lastBpm) {
          _lastBpm = g.bpm;
          final ms = (60000 / g.bpm).round().clamp(240, 2200);
          _beat.duration = Duration(milliseconds: ms);
          if (!_beat.isAnimating) {
            _beat.repeat();
          }
        }
        final s = widget.settings.value;
        final visualCrossings = s.visualMode == LatticeVisualMode.crossings;
        return AnimatedBuilder(
          animation: _beat,
          builder: (context, _) {
            final phase = (_beat.value) % 1.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _GrooveSwitcher(store: widget.store, current: g),
                  const SizedBox(height: 12),
                  LatticeStage(
                    pattern: g,
                    phase: phase,
                    visualCrossings: visualCrossings,
                    glow: s.showBeatGlow,
                  ),
                  const SizedBox(height: 16),
                  _MetaStrip(pattern: g),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _GrooveSwitcher extends StatelessWidget {
  const _GrooveSwitcher({required this.store, required this.current});

  final GrooveStore store;
  final GroovePattern current;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: current.id,
            items: [
              for (final p in store.items)
                DropdownMenuItem<String>(
                  value: p.id,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (id) {
              if (id != null) store.setActive(id);
            },
          ),
        ),
      ),
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({required this.pattern});

  final GroovePattern pattern;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cycle = pattern.pulseCycleLength;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Pulse window', style: t.titleMedium),
            const SizedBox(height: 6),
            Text('BPM · ${pattern.bpm}', style: t.bodyLarge),
            Text('Cycle length · $cycle ticks', style: t.bodyMedium),
            Text('Voices · ${pattern.steps.join(' : ')}', style: t.bodyMedium),
          ],
        ),
      ),
    );
  }
}

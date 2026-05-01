import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../services/groove_store.dart';

class GrooveSettingsPage extends StatelessWidget {
  const GrooveSettingsPage({
    super.key,
    required this.settings,
    required this.store,
  });

  final AppSettingsController settings;
  final GrooveStore store;

  Future<void> _patch(AppSettingsController c, AppSettings Function(AppSettings) patch) =>
      c.update(patch(c.value));

  Future<void> _clearStore(BuildContext context) async {
    final ids = store.items.map((e) => e.id).toList();
    for (final id in ids) {
      await store.remove(id);
    }
    await store.load();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grooves wiped')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groove settings')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final s = settings.value;
          final t = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: <Widget>[
              Text('Studio optics', style: t.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Controls how crossings render in Studio and preview cards.',
                style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              SegmentedButtonLatticeVisual(current: s.visualMode, onChanged: (m) async {
                await _patch(settings, (v) => v.copyWith(visualMode: m));
              }),
              const SizedBox(height: 20),
              SwitchListTile.adaptive(
                title: const Text('Beat halo emphasis'),
                subtitle: const Text('Adds a softened bloom whenever a lattice dot fires.'),
                value: s.showBeatGlow,
                onChanged: (v) async => _patch(settings, (x) => x.copyWith(showBeatGlow: v)),
              ),
              const Divider(height: 36),
              Text('Composer seeds', style: t.headlineSmall),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Default BPM for new grooves · ${s.defaultBpmForNewGroove}'),
              ),
              Slider(
                value: s.defaultBpmForNewGroove.toDouble(),
                min: 40,
                max: 210,
                divisions: 170,
                onChanged: (v) async =>
                    _patch(settings, (x) => x.copyWith(defaultBpmForNewGroove: v.round())),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Voice ribbons when sketching · ${s.layerCountDefault}'),
              ),
              Slider(
                value: s.layerCountDefault.toDouble(),
                min: 3,
                max: 6,
                divisions: 3,
                onChanged: (v) async =>
                    _patch(settings, (x) => x.copyWith(layerCountDefault: v.round())),
              ),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Stamp flavor preset'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StarterGridFlavor>(
                    value: s.gridFlavor,
                    isExpanded: true,
                    onChanged: (f) async {
                      if (f == null) return;
                      await _patch(settings, (v) => v.copyWith(gridFlavor: f));
                    },
                    items: const <DropdownMenuItem<StarterGridFlavor>>[
                      DropdownMenuItem(
                        value: StarterGridFlavor.fourThree,
                        child: Text('4 × 3 lattice'),
                      ),
                      DropdownMenuItem(
                        value: StarterGridFlavor.threeTwo,
                        child: Text('3 × 2 braid'),
                      ),
                      DropdownMenuItem(
                        value: StarterGridFlavor.euclideanSeven,
                        child: Text('7 · 5 · 4 Euclidean halo'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 36),
              Text('Chromatic runway', style: t.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Pick a backstage wash for sliders, chips, and boot gradients.',
                style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              _ColorRunway(seed: s.seedColor, onPick: (c) async => _patch(settings, (v) => v.copyWith(seedColor: c))),
              const Divider(height: 36),
              Text('Maintenance', style: t.headlineSmall),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async => _clearStore(context),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Wipe every saved groove'),
                style: FilledButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SegmentedButtonLatticeVisual extends StatelessWidget {
  const SegmentedButtonLatticeVisual({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final LatticeVisualMode current;
  final ValueChanged<LatticeVisualMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LatticeVisualMode>(
      segments: const <ButtonSegment<LatticeVisualMode>>[
        ButtonSegment(value: LatticeVisualMode.crossings, label: Text('Crossings')),
        ButtonSegment(value: LatticeVisualMode.layers, label: Text('Layer rings')),
      ],
      selected: <LatticeVisualMode>{current},
      onSelectionChanged: (sel) async {
        if (sel.length != 1) return;
        onChanged(sel.single);
      },
    );
  }
}

class _ColorRunway extends StatelessWidget {
  const _ColorRunway({required this.seed, required this.onPick});

  final Color seed;
  final ValueChanged<Color> onPick;

  static const palettes = <Color>[
    Color(0xFF0F766E),
    Color(0xFF92400E),
    Color(0xFF9333EA),
    Color(0xFFB45309),
    Color(0xFF1D4ED8),
    Color(0xFF047857),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: palettes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = palettes[i];
          final active = identical(seed, c) || seed == c;
          return InkResponse(
            onTap: () => onPick(c),
            radius: 36,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: active ? 3 : 1,
                  color: active ? Colors.white.withValues(alpha: 0.9) : Colors.black26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

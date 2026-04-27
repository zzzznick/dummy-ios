import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../services/palette_store.dart';

class PalettePilotSettingsPage extends StatelessWidget {
  const PalettePilotSettingsPage({
    super.key,
    required this.settings,
    required this.store,
  });

  final AppSettingsController settings;
  final PaletteStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = settings.value;
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text('Format & accessibility', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _SegmentedSetting<ColorFormat>(
                    title: 'Default color format',
                    value: s.colorFormat,
                    items: const {
                      ColorFormat.hex: Text('HEX'),
                      ColorFormat.rgb: Text('RGB'),
                      ColorFormat.hsl: Text('HSL'),
                    },
                    onChanged: (v) => settings.update(s.copyWith(colorFormat: v)),
                  ),
                  const Divider(height: 1),
                  _SegmentedSetting<ContrastTarget>(
                    title: 'Contrast target',
                    value: s.contrastTarget,
                    items: const {
                      ContrastTarget.aa: Text('AA'),
                      ContrastTarget.aaa: Text('AAA'),
                    },
                    onChanged: (v) => settings.update(s.copyWith(contrastTarget: v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Export', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _SliderSetting(
                    title: 'Preview padding',
                    value: s.exportPadding.toDouble(),
                    min: 0,
                    max: 48,
                    trailing: Text('${s.exportPadding}px'),
                    onChanged: (v) => settings.update(s.copyWith(exportPadding: v.round())),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('App style', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Group(
                children: [
                  _SeedChips(
                    seed: s.seedColor,
                    onPick: (c) => settings.update(s.copyWith(seedColor: c)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Data', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Group(
                children: [
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded),
                    title: const Text('Reset palettes'),
                    subtitle: const Text('Replace your library with starter palettes.'),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset palettes?'),
                          content: const Text('This will replace your palette library with starter data.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.reset();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Palettes reset')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AboutCard(),
            ],
          ),
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _SegmentedSetting<T> extends StatelessWidget {
  const _SegmentedSetting({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final T value;
  final Map<T, Widget> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<T>(
              segments: [
                for (final e in items.entries) ButtonSegment<T>(value: e.key, label: e.value),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.trailing,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final Widget trailing;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
              trailing,
            ],
          ),
          const SizedBox(height: 8),
          Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SeedChips extends StatelessWidget {
  const _SeedChips({required this.seed, required this.onPick});

  final Color seed;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) {
    final candidates = <Color>[
      const Color(0xFF5E60CE),
      const Color(0xFF0081A7),
      const Color(0xFF6D597A),
      const Color(0xFF2A9D8F),
      const Color(0xFFB5179E),
      const Color(0xFF9B2226),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in candidates)
            _SeedChip(
              color: c,
              selected: c.value == seed.value,
              onTap: () => onPick(c),
            ),
        ],
      ),
    );
  }
}

class _SeedChip extends StatelessWidget {
  const _SeedChip({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        width: 44,
        height: 44,
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Palette Pilot is an offline color lab for quick palette building, contrast checks, mixing, and export handoff.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/settings/east_settings.dart';
import '../../app/settings/east_settings_controller.dart';
import '../../models/tile_catalog.dart';
import '../../services/hand_library_store.dart';

class EastAppSettingsPage extends StatelessWidget {
  const EastAppSettingsPage({
    super.key,
    required this.settings,
    required this.library,
  });

  final EastSettingsController settings;
  final HandLibraryStore library;

  Future<void> _patch(EastSettings Function(EastSettings) patch) =>
      settings.update(patch(settings.value));

  Future<void> _exportSketches(BuildContext context) async {
    final txt = library.items.map((h) => '"${h.title}": ${h.tiles.join(", ")}').join('\n');
    await Clipboard.setData(ClipboardData(text: txt.isEmpty ? '(empty library)' : txt));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sketch list copied')));
    }
  }

  Future<void> _purgeSketches(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erase Library?'),
            content: const Text('Removes every saved sketch from this device.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Erase')),
            ],
          ),
        ) ??
        false;
    if (!ok || !context.mounted) return;
    final ids = library.items.map((e) => e.id).toList();
    await Future.wait(ids.map(library.remove));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Library emptied')));
    }
  }

  static String _previewLabel(String id, HonorGlyphWeight g) {
    if (!TileCatalog.isHonor(id)) return TileCatalog.face(id);
    return g == HonorGlyphWeight.soft ? TileCatalog.syllable(id) : TileCatalog.face(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courtyard')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final s = settings.value;
          final tt = Theme.of(context).textTheme;
          final cs = Theme.of(context).colorScheme;

          const previewTiles = <String>['m3', 'p6', 's9', 'ew', 'gd'];

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: <Widget>[
              Text('Courtyard moods', style: tt.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'These washes tint gradients, blossoms, and chips without fighting your sketches.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: EastFeltPalette.swatches.map((c) {
                  final active = c == s.seedColor;
                  return FilterChip(
                    label: SizedBox.square(
                      dimension: 32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withValues(alpha: 0.12),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    selected: active,
                    showCheckmark: false,
                    onSelected: (_) => _patch((v) => v.copyWith(seedColor: c)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Honor chip typography', style: tt.titleMedium),
              const SizedBox(height: 8),
              SegmentedButtonHonorGlyph(
                current: s.honorGlyphWeight,
                onChanged: (g) => _patch((v) => v.copyWith(honorGlyphWeight: g)),
              ),
              const SizedBox(height: 16),
              Text('Comfort preview (${(s.chipComfort * 100).round()} pt feel)', style: tt.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: previewTiles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final id = previewTiles[i];
                    return _TinyPreviewChip(
                      label: _previewLabel(id, s.honorGlyphWeight),
                      honor: TileCatalog.isHonor(id),
                      scale: s.chipComfort,
                    );
                  },
                ),
              ),
              Slider(
                min: 0.82,
                max: 1.14,
                divisions: 16,
                value: s.chipComfort.clamp(0.82, 1.14),
                onChanged: (v) => _patch((x) => x.copyWith(chipComfort: v)),
              ),
              Divider(height: 36, color: cs.outlineVariant.withValues(alpha: 0.55)),
              Text('Bloom preset', style: tt.titleMedium),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Calm ring length · ${s.bloomPresetMinutes} min'),
              ),
              Slider(
                min: 3,
                max: 25,
                divisions: 22,
                value: s.bloomPresetMinutes.toDouble(),
                label: '${s.bloomPresetMinutes} min',
                onChanged: (v) => _patch((x) => x.copyWith(bloomPresetMinutes: v.round())),
              ),
              Divider(height: 36, color: cs.outlineVariant.withValues(alpha: 0.55)),
              Text('Seat ribbons', style: tt.titleMedium),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show seat compass ribbon'),
                subtitle: const Text('Surfaces gentle context on Winds with your favored compass seat.'),
                value: s.showSeatWindRibbon,
                onChanged: (v) => _patch((x) => x.copyWith(showSeatWindRibbon: v)),
              ),
              const SizedBox(height: 8),
              SegmentedSeatWind(
                current: s.defaultSeatWind,
                onChanged: (w) => _patch((v) => v.copyWith(defaultSeatWind: w)),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: Text('Clipboard manifest (${library.items.length})'),
                onPressed: () => _exportSketches(context),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  foregroundColor: cs.onPrimary,
                  backgroundColor: cs.error,
                ),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Erase sketch library'),
                onPressed: () => _purgeSketches(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

abstract final class EastFeltPalette {
  static final List<Color> swatches = <Color>[
    const Color(0xFFEC407A),
    const Color(0xFFD81B60),
    const Color(0xFF7986CB),
    const Color(0xFF0097A7),
    const Color(0xFF689F38),
  ];
}

class SegmentedSeatWind extends StatelessWidget {
  const SegmentedSeatWind({super.key, required this.current, required this.onChanged});

  final DefaultSeatWind current;
  final ValueChanged<DefaultSeatWind> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DefaultSeatWind>(
      segments: const <ButtonSegment<DefaultSeatWind>>[
        ButtonSegment(value: DefaultSeatWind.east, label: Text('East')),
        ButtonSegment(value: DefaultSeatWind.south, label: Text('South')),
        ButtonSegment(value: DefaultSeatWind.west, label: Text('West')),
        ButtonSegment(value: DefaultSeatWind.north, label: Text('North')),
      ],
      selected: <DefaultSeatWind>{current},
      multiSelectionEnabled: false,
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        final only = selection.isEmpty ? current : selection.first;
        if (only != current) {
          onChanged(only);
        }
      },
    );
  }
}

class SegmentedButtonHonorGlyph extends StatelessWidget {
  const SegmentedButtonHonorGlyph({super.key, required this.current, required this.onChanged});

  final HonorGlyphWeight current;
  final ValueChanged<HonorGlyphWeight> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HonorGlyphWeight>(
      segments: const <ButtonSegment<HonorGlyphWeight>>[
        ButtonSegment(value: HonorGlyphWeight.soft, label: Text('Soft syllables')),
        ButtonSegment(value: HonorGlyphWeight.vivid, label: Text('Full names')),
      ],
      selected: <HonorGlyphWeight>{current},
      multiSelectionEnabled: false,
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        final only = selection.isEmpty ? current : selection.first;
        if (only != current) {
          onChanged(only);
        }
      },
    );
  }
}

class _TinyPreviewChip extends StatelessWidget {
  const _TinyPreviewChip({
    required this.label,
    required this.honor,
    required this.scale,
  });

  final String label;
  final bool honor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final w = ((honor ? 46.0 : 40.0) * scale).clamp(36.0, 54.0);
    final h = ((honor ? 54.0 : 44.0) * scale).clamp(44.0, 62.0);

    final cs = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minWidth: w + 14, maxHeight: h + 22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: honor ? cs.secondaryContainer.withValues(alpha: 0.55) : cs.surfaceContainerHigh,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

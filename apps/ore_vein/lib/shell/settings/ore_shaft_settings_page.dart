import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/settings/ore_settings.dart';
import '../../app/settings/ore_settings_controller.dart';
import '../../services/field_note_store.dart';

class OreShaftSettingsPage extends StatelessWidget {
  const OreShaftSettingsPage({
    super.key,
    required this.settings,
    required this.notes,
  });

  final OreSettingsController settings;
  final FieldNoteStore notes;

  Future<void> _patch(OreSettings Function(OreSettings) f) =>
      settings.update(f(settings.value));

  Future<void> _clipVault(BuildContext context) async {
    final lines = notes.items.map((n) => '• ${n.title}: ${n.mineralKey}').join('\n');
    await Clipboard.setData(ClipboardData(text: lines.isEmpty ? '(empty vault)' : lines));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault list copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shaft controls')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final s = settings.value;
          final tt = Theme.of(context).textTheme;
          final cs = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: <Widget>[
              Text('Vein washes', style: tt.headlineSmall),
              Text(
                'Seed colors tint navigation, cards, boot gradients.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: OreVeinAshPalette.swatches.map((c) {
                  final sel = _sameArgb(c, s.seedColor);
                  return FilterChip(
                    label: SizedBox.square(
                      dimension: 32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white70, width: 2),
                        ),
                      ),
                    ),
                    selected: sel,
                    showCheckmark: false,
                    onSelected: (_) => _patch((x) => x.copyWith(seedColor: c)),
                  );
                }).toList(),
              ),
              const Divider(height: 34),
              Text('Field pings', style: tt.titleMedium),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Surface haptic pings'),
                subtitle: const Text('Reserved for tactile polish on future specimen saves.'),
                value: s.fieldPingsEnabled,
                onChanged: (v) => _patch((x) => x.copyWith(fieldPingsEnabled: v)),
              ),
              Text('Mohs bench coaching density', style: tt.titleMedium),
              Slider(
                value: s.mohsCoachBias.clamp(0.0, 1.0),
                onChanged: (v) => _patch((x) => x.copyWith(mohsCoachBias: v)),
              ),
              Text('Vault card pacing', style: tt.titleMedium),
              SegmentedButton<VaultCardDensity>(
                segments: const <ButtonSegment<VaultCardDensity>>[
                  ButtonSegment(value: VaultCardDensity.relaxed, label: Text('Relaxed')),
                  ButtonSegment(value: VaultCardDensity.compact, label: Text('Compact')),
                ],
                selected: <VaultCardDensity>{s.vaultDensity},
                multiSelectionEnabled: false,
                showSelectedIcon: false,
                onSelectionChanged: (sel) {
                  if (sel.isEmpty) return;
                  final only = sel.first;
                  _patch((x) => x.copyWith(vaultDensity: only));
                },
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: Text('Copy vault roster (${notes.items.length})'),
                onPressed: () => _clipVault(context),
              ),
            ],
          );
        },
      ),
    );
  }

  static bool _sameArgb(Color a, Color b) => a.toARGB32() == b.toARGB32();
}

abstract final class OreVeinAshPalette {
  static final List<Color> swatches = <Color>[
    const Color(0xFF00695C),
    const Color(0xFF5D4037),
    const Color(0xFF546E7A),
    const Color(0xFFB71C1C),
    const Color(0xFF6A1B9A),
  ];
}

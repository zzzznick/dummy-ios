import 'package:flutter/material.dart';

import '../../app/settings/ore_settings_controller.dart';
import '../../models/mineral_ref.dart';

class MohsLabPage extends StatefulWidget {
  const MohsLabPage({super.key, required this.settings});

  final OreSettingsController settings;

  @override
  State<MohsLabPage> createState() => _MohsLabPageState();
}

class _MohsLabPageState extends State<MohsLabPage> {
  MineralRef? _a;
  MineralRef? _b;

  @override
  void initState() {
    super.initState();
    final c = MineralRef.catalog;
    if (c.length >= 2) {
      _a = c[2];
      _b = c[3];
    }
  }

  Widget _dropdown({
    required String label,
    required MineralRef? value,
    required ValueChanged<MineralRef?> onPick,
    required List<MineralRef> minerals,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MineralRef>(
          isExpanded: true,
          value: value,
          items: minerals
              .map(
                (m) => DropdownMenuItem<MineralRef>(
                  value: m,
                  child: Text('${m.commonName} (${m.mohs})'),
                ),
              )
              .toList(),
          onChanged: onPick,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final coach = widget.settings.value.mohsCoachBias;
        final cs = Theme.of(context).colorScheme;
        final cat = MineralRef.catalog;

        String verdict() {
          if (_a == null || _b == null) return 'Pick two samples to duel.';
          if (_a!.key == _b!.key) return 'Choose two distinct entries for contrast.';
          if (_a!.mohs > _b!.mohs) {
            return '${_a!.commonName} can scratch ${_b!.commonName}.';
          }
          if (_b!.mohs > _a!.mohs) {
            return '${_b!.commonName} resists gouging from ${_a!.commonName}.';
          }
          return '${_a!.commonName} and ${_b!.commonName} occupy the same rough tier — check cleavage in the field.';
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
          children: <Widget>[
            Text('Scratch duel', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Mohs hardness is ordinal, not infinitely precise—but it still tells you what grinds what.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            _dropdown(
              label: 'Scout mineral',
              value: _a,
              onPick: (m) => setState(() => _a = m),
              minerals: cat,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Target mineral',
              value: _b,
              onPick: (m) => setState(() => _b = m),
              minerals: cat,
            ),
            const SizedBox(height: 22),
            Card(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Bench readout', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Text(verdict(), style: Theme.of(context).textTheme.bodyLarge),
                    if (coach > 0.35) ...<Widget>[
                      const SizedBox(height: 14),
                      Text(
                        coach > 0.7
                            ? 'Reminder: hardness ignores density—always pair with streak and breakage.'
                            : 'Tip: if results feel ambiguous, try a softer reference first.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

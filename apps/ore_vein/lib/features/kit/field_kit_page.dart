import 'package:flutter/material.dart';

import '../../app/settings/ore_settings.dart';
import '../../app/settings/ore_settings_controller.dart';

class FieldKitPage extends StatelessWidget {
  const FieldKitPage({super.key, required this.settings});

  final OreSettingsController settings;

  Future<void> _patch(OreSettings Function(OreSettings) f) =>
      settings.update(f(settings.value));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = settings.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          children: <Widget>[
            Text('Staging kit', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Track what you slid into your pack before tromping uphill—purely mnemonic.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              title: const Text('Hand lens'),
              subtitle: const Text('10× stereo loupe imaginary'),
              value: s.kitHandLens,
              onChanged: (v) => _patch((x) => x.copyWith(kitHandLens: v)),
            ),
            SwitchListTile.adaptive(
              title: const Text('Streak plate'),
              subtitle: const Text('Unglazed ceramic square'),
              value: s.kitStreakPlate,
              onChanged: (v) => _patch((x) => x.copyWith(kitStreakPlate: v)),
            ),
            SwitchListTile.adaptive(
              title: const Text('Magnet'),
              subtitle: const Text('For iron-flavor hints'),
              value: s.kitMagnet,
              onChanged: (v) => _patch((x) => x.copyWith(kitMagnet: v)),
            ),
            SwitchListTile.adaptive(
              title: const Text('Pocket scale'),
              subtitle: const Text('Not for explosives—just mass curiosity'),
              value: s.kitScale,
              onChanged: (v) => _patch((x) => x.copyWith(kitScale: v)),
            ),
            SwitchListTile.adaptive(
              title: const Text('Impact goggles'),
              subtitle: const Text('Chips fly when wedges slip'),
              value: s.kitGoggles,
              onChanged: (v) => _patch((x) => x.copyWith(kitGoggles: v)),
            ),
          ],
        );
      },
    );
  }
}

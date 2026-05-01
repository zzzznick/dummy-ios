import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../features/editor/groove_editor_page.dart';
import '../../models/groove_pattern.dart';
import '../../services/groove_store.dart';

List<int> stepsFromFlavor(StarterGridFlavor flavor, int layers) {
  final base = switch (flavor) {
    StarterGridFlavor.fourThree => <int>[4, 3],
    StarterGridFlavor.threeTwo => <int>[3, 2],
    StarterGridFlavor.euclideanSeven => <int>[7, 5, 4],
  };
  final out = List<int>.from(base);
  var n = 5;
  while (out.length < layers) {
    out.add((n++ % 6) + 2);
  }
  return out.take(layers).toList();
}

Future<void> openGrooveEditor(
  BuildContext context, {
  required GrooveStore store,
  required AppSettingsController settings,
  required GroovePattern draft,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => GrooveEditorPage(
        store: store,
        settings: settings,
        initial: draft,
      ),
    ),
  );
}

class ComposerPage extends StatelessWidget {
  const ComposerPage({
    super.key,
    required this.store,
    required this.settings,
  });

  final GrooveStore store;
  final AppSettingsController settings;

  Future<void> _spawn(
    BuildContext context, {
    required String name,
    required List<int> steps,
    required int bpm,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final g = GroovePattern(
      id: 'g-$now',
      name: name,
      bpm: bpm,
      steps: steps,
      updatedMillis: now,
    );
    await openGrooveEditor(context, store: store, settings: settings, draft: g);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = settings.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Quick lattice recipes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  ActionChip(
                    avatar: Icon(Icons.shuffle_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                    label: const Text('4 × 3 field'),
                    onPressed: () => _spawn(
                      context,
                      name: 'Four over three',
                      steps: stepsFromFlavor(StarterGridFlavor.fourThree, s.layerCountDefault),
                      bpm: s.defaultBpmForNewGroove,
                    ),
                  ),
                  ActionChip(
                    avatar: Icon(Icons.scatter_plot_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
                    label: const Text('Triplet braid'),
                    onPressed: () => _spawn(
                      context,
                      name: 'Triplet braid',
                      steps: stepsFromFlavor(StarterGridFlavor.threeTwo, s.layerCountDefault),
                      bpm: s.defaultBpmForNewGroove,
                    ),
                  ),
                  ActionChip(
                    avatar: Icon(Icons.hexagon_rounded, size: 18, color: Theme.of(context).colorScheme.tertiary),
                    label: const Text('Euclidean halo'),
                    onPressed: () => _spawn(
                      context,
                      name: 'Euclidean halo',
                      steps: stepsFromFlavor(StarterGridFlavor.euclideanSeven, s.layerCountDefault),
                      bpm: s.defaultBpmForNewGroove,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Use Settings defaults'),
                onPressed: () async {
                  final layers = s.layerCountDefault.clamp(3, 6);
                  final steps = stepsFromFlavor(s.gridFlavor, layers);
                  await _spawn(
                    context,
                    name: 'Settings sketch',
                    steps: steps,
                    bpm: s.defaultBpmForNewGroove,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Blank lattice editor'),
                onPressed: () async {
                  final now = DateTime.now().millisecondsSinceEpoch;
                  final layers = s.layerCountDefault.clamp(3, 6);
                  final g = GroovePattern(
                    id: 'g-$now',
                    name: 'Untitled lattice',
                    bpm: s.defaultBpmForNewGroove,
                    steps: List<int>.generate(layers, (i) => i + 3),
                    updatedMillis: now,
                  );
                  await openGrooveEditor(context, store: store, settings: settings, draft: g);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

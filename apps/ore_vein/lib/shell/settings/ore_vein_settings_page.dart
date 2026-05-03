import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../models/checklist.dart';
import '../../models/saved_swatch.dart';
import '../../services/ore_vein_data_store.dart';

class OreVeinSettingsPage extends StatelessWidget {
  const OreVeinSettingsPage({super.key, required this.settings, required this.data});

  final AppSettingsController settings;
  final OreVeinDataStore data;

  static const _accents = <MapEntry<String, Color>>[
    MapEntry('Teal tool', Color(0xFF006978)),
    MapEntry('Indigo night', Color(0xFF283593)),
    MapEntry('Amber desk', Color(0xFFFF8F00)),
    MapEntry('Forest calm', Color(0xFF2E7D32)),
    MapEntry('Violet focus', Color(0xFF6A1B9A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final s = settings.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Accent palette', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _matchAccent(s.seedColor),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: _accents
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(backgroundColor: e.value, radius: 10),
                                    const SizedBox(width: 10),
                                    Text(e.key),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (name) async {
                          if (name == null) return;
                          final c = _accents.firstWhere((e) => e.key == name).value;
                          await settings.update(s.copyWith(seedColor: c));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Timer face', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      SegmentedButton<TimerFace>(
                        segments: const <ButtonSegment<TimerFace>>[
                          ButtonSegment(value: TimerFace.minimal, label: Text('Digits')),
                          ButtonSegment(value: TimerFace.rings, label: Text('Ring')),
                          ButtonSegment(value: TimerFace.bold, label: Text('Bold')),
                        ],
                        selected: <TimerFace>{s.timerFace},
                        onSelectionChanged: (v) async {
                          await settings.update(s.copyWith(timerFace: v.first));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Number density', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      SegmentedButton<NumberDensity>(
                        segments: const <ButtonSegment<NumberDensity>>[
                          ButtonSegment(value: NumberDensity.comfortable, label: Text('Comfort')),
                          ButtonSegment(value: NumberDensity.compact, label: Text('Compact')),
                        ],
                        selected: <NumberDensity>{s.numberDensity},
                        onSelectionChanged: (v) async {
                          await settings.update(s.copyWith(numberDensity: v.first));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('New checklists on top'),
                subtitle: const Text('Changes ordering on the Lists tab'),
                value: s.listsNewestFirst,
                onChanged: (v) async => settings.update(s.copyWith(listsNewestFirst: v)),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Default tip for Tip tab (${s.defaultTipPercent.toStringAsFixed(0)}%)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: s.defaultTipPercent.clamp(5, 35),
                        min: 5,
                        max: 35,
                        divisions: 30,
                        label: '${s.defaultTipPercent.round()}%',
                        onChanged: (v) async => settings.update(s.copyWith(defaultTipPercent: v)),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),
              ListTile(
                title: const Text('Clear saved swatches'),
                subtitle: const Text('Removes palette entries only'),
                onTap: () async {
                  for (final x in List<SavedSwatch>.from(data.swatches)) {
                    await data.removeSwatch(x.id);
                  }
                },
              ),
              ListTile(
                title: const Text('Clear all checklists'),
                subtitle: const Text('Cannot be undone'),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete all lists?'),
                      actions: <Widget>[
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  for (final c in List<Checklist>.from(data.checklists)) {
                    await data.removeChecklist(c.id);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _matchAccent(Color c) {
    for (final e in _accents) {
      if (e.value.value == c.value) return e.key;
    }
    return _accents.first.key;
  }
}

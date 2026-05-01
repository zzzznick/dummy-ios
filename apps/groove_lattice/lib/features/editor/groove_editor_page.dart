import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../models/groove_pattern.dart';
import '../../services/groove_store.dart';
import '../../widgets/lattice_stage.dart';

class GrooveEditorPage extends StatefulWidget {
  const GrooveEditorPage({
    super.key,
    required this.store,
    required this.settings,
    required this.initial,
  });

  final GrooveStore store;
  final AppSettingsController settings;
  final GroovePattern initial;

  @override
  State<GrooveEditorPage> createState() => _GrooveEditorPageState();
}

class _GrooveEditorPageState extends State<GrooveEditorPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _name;
  late GroovePattern _draft;
  late final AnimationController _preview;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial.copyWith();
    _name = TextEditingController(text: _draft.name);
    _preview = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _pulse();
  }

  void _pulse() {
    final ms = (60000 / _draft.bpm).round().clamp(240, 2200);
    _preview.duration = Duration(milliseconds: ms);
  }

  @override
  void dispose() {
    _name.dispose();
    _preview.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _name.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    _draft = _draft.copyWith(
      name: trimmed,
      updatedMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await widget.store.upsert(_draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lattice editor'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) {
          final s = widget.settings.value;
          final crossings = s.visualMode == LatticeVisualMode.crossings;
          return AnimatedBuilder(
            animation: _preview,
            builder: (context, _) {
              final phase = _preview.value % 1.0;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Lattice title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Tempo ${_draft.bpm} BPM'),
                    Slider(
                      value: _draft.bpm.toDouble(),
                      min: 40,
                      max: 240,
                      divisions: 200,
                      label: '${_draft.bpm} BPM',
                      onChanged: (v) => setState(() {
                        _draft = _draft.copyWith(bpm: v.round());
                        _pulse();
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text('Living preview', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    LatticeStage(
                      pattern: _draft,
                      phase: phase,
                      visualCrossings: crossings,
                      glow: s.showBeatGlow,
                    ),
                    const SizedBox(height: 20),
                    Text('Voice densities', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _draft.steps.length,
                      onReorder: (a, b) {
                        setState(() {
                          if (b > a) b--;
                          final item = _draft.steps.removeAt(a);
                          _draft.steps.insert(b, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final v = _draft.steps[index];
                        return Card(
                          key: ValueKey<int>(index),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text('$v pulses / cycle slice'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  tooltip: 'Fewer pulses',
                                  onPressed: () {
                                    setState(() {
                                      final next = v - 1;
                                      _draft.steps[index] = next.clamp(2, 16);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                IconButton(
                                  tooltip: 'More pulses',
                                  onPressed: () {
                                    setState(() {
                                      final next = v + 1;
                                      _draft.steps[index] = next.clamp(2, 16);
                                    });
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _draft.steps.length >= 8
                                ? null
                                : () {
                                    setState(() {
                                      _draft.steps.add(5);
                                    });
                                  },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('Add voice'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _draft.steps.length <= 2
                                ? null
                                : () {
                                    setState(() {
                                      _draft.steps.removeLast();
                                    });
                                  },
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            label: const Text('Remove voice'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

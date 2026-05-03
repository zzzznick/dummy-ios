import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/settings/app_settings_controller.dart';
import '../../models/saved_swatch.dart';
import '../../services/ore_vein_data_store.dart';

class SwatchesPage extends StatelessWidget {
  const SwatchesPage({super.key, required this.settings, required this.data});

  final AppSettingsController settings;
  final OreVeinDataStore data;

  static String _hex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[settings, data]),
      builder: (context, _) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  onPressed: () async {
                    Color draft = Color(settings.value.seedColor.value);
                    final picked = await showDialog<Color>(
                      context: context,
                      builder: (ctx) => _PickerDialog(initial: draft),
                    );
                    if (picked == null || !context.mounted) return;
                    draft = picked;
                    final label = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _LabelDialog(),
                    );
                    if (!context.mounted) return;
                    await data.addSwatch(
                      SavedSwatch(
                        id: '${DateTime.now().millisecondsSinceEpoch}',
                        colorArgb: draft.value,
                        label: label?.trim() ?? '',
                      ),
                    );
                  },
                  icon: const Icon(Icons.color_lens_outlined),
                  label: const Text('Save a swatch'),
                ),
              ),
            ),
            if (data.swatches.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No swatches yet. Save colors you use often.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = data.swatches[i];
                    final c = Color(s.colorArgb);
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: c),
                      title: Text(s.label.isEmpty ? _hex(c) : s.label),
                      subtitle: Text(_hex(c)),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: _hex(c)));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied ${_hex(c)}')),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => data.removeSwatch(s.id),
                      ),
                    );
                  },
                  childCount: data.swatches.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PickerDialog extends StatefulWidget {
  const _PickerDialog({required this.initial});

  final Color initial;

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  late double _r;
  late double _g;
  late double _b;

  @override
  void initState() {
    super.initState();
    _r = widget.initial.red.toDouble();
    _g = widget.initial.green.toDouble();
    _b = widget.initial.blue.toDouble();
  }

  Color get _c => Color.fromARGB(255, _r.round().clamp(0, 255), _g.round().clamp(0, 255), _b.round().clamp(0, 255));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 56, child: DecoratedBox(decoration: BoxDecoration(color: _c, borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 12),
            Text('Red ${_r.round()}'),
            Slider(value: _r.clamp(0, 255), max: 255, onChanged: (v) => setState(() => _r = v)),
            Text('Green ${_g.round()}'),
            Slider(value: _g.clamp(0, 255), max: 255, onChanged: (v) => setState(() => _g = v)),
            Text('Blue ${_b.round()}'),
            Slider(value: _b.clamp(0, 255), max: 255, onChanged: (v) => setState(() => _b = v)),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _c), child: const Text('Use color')),
      ],
    );
  }
}

class _LabelDialog extends StatefulWidget {
  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Label (optional)'),
      content: TextField(
        controller: _c,
        decoration: const InputDecoration(hintText: 'Kitchen accent', border: OutlineInputBorder()),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip')),
        FilledButton(onPressed: () => Navigator.pop(context, _c.text), child: const Text('Save')),
      ],
    );
  }
}

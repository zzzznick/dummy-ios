import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../models/palette.dart';
import '../../services/palette_store.dart';
import '../../utils/color_utils.dart';

class PaletteEditorPage extends StatefulWidget {
  const PaletteEditorPage({
    super.key,
    required this.store,
    required this.settings,
    this.paletteId,
  });

  final PaletteStore store;
  final AppSettingsController settings;
  final String? paletteId;

  @override
  State<PaletteEditorPage> createState() => _PaletteEditorPageState();
}

class _PaletteEditorPageState extends State<PaletteEditorPage> {
  late final TextEditingController _name;
  late final List<Color> _colors;
  late final bool _isNew;
  late final String _id;
  late final int _createdAtMs;

  @override
  void initState() {
    super.initState();
    final existing = widget.paletteId == null ? null : widget.store.byId(widget.paletteId!);
    _isNew = existing == null;
    final seeded = existing ?? Palette.seed('Untitled', random: Random());
    _id = seeded.id;
    _createdAtMs = seeded.createdAtMs;
    _name = TextEditingController(text: _isNew ? 'New palette' : seeded.name);
    _colors = seeded.colors.map((v) => Color(v)).toList(growable: true);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name can’t be empty')),
      );
      return;
    }
    if (_colors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one color')),
      );
      return;
    }
    final palette = Palette(
      id: _id,
      name: name,
      colors: _colors.map((c) => c.value).toList(growable: false),
      createdAtMs: _createdAtMs,
    );
    if (_isNew) {
      await widget.store.add(palette);
    } else {
      await widget.store.update(palette);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final format = widget.settings.value.colorFormat;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Create palette' : 'Edit palette'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Palette name',
              hintText: 'e.g. Sunset UI',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Colors', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              FilledButton.icon(
                onPressed: () async {
                  final picked = await showDialog<Color>(
                    context: context,
                    builder: (_) => _QuickPickDialog(seed: scheme.primary),
                  );
                  if (picked == null) return;
                  setState(() => _colors.add(picked));
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _colors.length; i++) ...[
            _ColorRow(
              index: i,
              color: _colors[i],
              format: format,
              onEdit: () async {
                final picked = await showDialog<Color>(
                  context: context,
                  builder: (_) => _QuickPickDialog(seed: _colors[i]),
                );
                if (picked == null) return;
                setState(() => _colors[i] = picked);
              },
              onRemove: () => setState(() => _colors.removeAt(i)),
              onMoveUp: i == 0 ? null : () => setState(() => _swap(i, i - 1)),
              onMoveDown: i == _colors.length - 1 ? null : () => setState(() => _swap(i, i + 1)),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save palette'),
          ),
        ],
      ),
    );
  }

  void _swap(int a, int b) {
    final tmp = _colors[a];
    _colors[a] = _colors[b];
    _colors[b] = tmp;
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.index,
    required this.color,
    required this.format,
    required this.onEdit,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final int index;
  final Color color;
  final ColorFormat format;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 18,
              child: Container(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    formatColor(color, format),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(tooltip: 'Move up', onPressed: onMoveUp, icon: const Icon(Icons.arrow_upward_rounded)),
            IconButton(
              tooltip: 'Move down',
              onPressed: onMoveDown,
              icon: const Icon(Icons.arrow_downward_rounded),
            ),
            IconButton(tooltip: 'Edit', onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
            IconButton(tooltip: 'Remove', onPressed: onRemove, icon: const Icon(Icons.close_rounded)),
          ],
        ),
      ),
    );
  }
}

class _QuickPickDialog extends StatefulWidget {
  const _QuickPickDialog({required this.seed});

  final Color seed;

  @override
  State<_QuickPickDialog> createState() => _QuickPickDialogState();
}

class _QuickPickDialogState extends State<_QuickPickDialog> {
  late double _h;
  late double _s;
  late double _l;

  @override
  void initState() {
    super.initState();
    final hsl = HSLColor.fromColor(widget.seed);
    _h = hsl.hue;
    _s = hsl.saturation;
    _l = hsl.lightness;
  }

  @override
  Widget build(BuildContext context) {
    final color = HSLColor.fromAHSL(1, _h, _s, _l).toColor();
    return AlertDialog(
      title: const Text('Pick a color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'Hue',
            value: _h,
            min: 0,
            max: 360,
            onChanged: (v) => setState(() => _h = v),
          ),
          _SliderRow(
            label: 'Sat',
            value: _s * 100,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _s = v / 100),
          ),
          _SliderRow(
            label: 'Light',
            value: _l * 100,
            min: 0,
            max: 100,
            onChanged: (v) => setState(() => _l = v / 100),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, color), child: const Text('Use')),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}


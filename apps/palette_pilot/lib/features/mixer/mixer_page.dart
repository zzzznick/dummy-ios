import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../models/palette.dart';
import '../../services/palette_store.dart';
import '../../utils/color_utils.dart';

class MixerPage extends StatefulWidget {
  const MixerPage({super.key, required this.store, required this.settings});

  final PaletteStore store;
  final AppSettingsController settings;

  @override
  State<MixerPage> createState() => _MixerPageState();
}

class _MixerPageState extends State<MixerPage> {
  Color _a = const Color(0xFF0EA5E9);
  Color _b = const Color(0xFFF97316);
  double _t = 0.5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mixed = Color.lerp(_a, _b, _t) ?? _a;
    final fmt = widget.settings.value.colorFormat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _MixCard(
          a: _a,
          b: _b,
          mixed: mixed,
          t: _t,
          fmt: fmt,
          onPickA: () => _pick('Color A', _a, (c) => setState(() => _a = c)),
          onPickB: () => _pick('Color B', _b, (c) => setState(() => _b = c)),
          onT: (v) => setState(() => _t = v),
        ),
        const SizedBox(height: 14),
        Text('Apply', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (!widget.store.loaded || widget.store.palettes.isEmpty)
          Text(
            'Create a palette first to save your mixed color.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in widget.store.palettes.take(6))
                _ActionChip(
                  label: 'Add to "${p.name}"',
                  onTap: () async {
                    final next = p.copyWith(colors: [...p.colors, mixed.value]);
                    await widget.store.update(next);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to "${p.name}"')),
                      );
                    }
                  },
                ),
              _ActionChip(
                label: 'Create new palette from mix',
                onTap: () async {
                  final created = Palette(
                    id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}',
                    name: 'Mix ${formatColor(mixed, ColorFormat.hex)}',
                    colors: [_a.value, _b.value, mixed.value],
                    createdAtMs: DateTime.now().millisecondsSinceEpoch,
                  );
                  await widget.store.add(created);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Palette created')),
                    );
                  }
                },
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pick(String title, Color current, ValueChanged<Color> setColor) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _HslDialog(title: title, seed: current),
    );
    if (picked == null) return;
    setColor(picked);
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({
    required this.a,
    required this.b,
    required this.mixed,
    required this.t,
    required this.fmt,
    required this.onPickA,
    required this.onPickB,
    required this.onT,
  });

  final Color a;
  final Color b;
  final Color mixed;
  final double t;
  final ColorFormat fmt;
  final VoidCallback onPickA;
  final VoidCallback onPickB;
  final ValueChanged<double> onT;

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
            Text('Mix colors', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PickTile(title: 'A', color: a, subtitle: formatColor(a, fmt), onTap: onPickA),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickTile(title: 'B', color: b, subtitle: formatColor(b, fmt), onTap: onPickB),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Blend', style: Theme.of(context).textTheme.titleSmall),
            Slider(value: t, onChanged: onT),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [a, mixed, b]),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            formatColor(mixed, fmt),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({required this.title, required this.color, required this.subtitle, required this.onTap});

  final String title;
  final Color color;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Color $title', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: on)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: on.withValues(alpha: 0.9))),
              const SizedBox(height: 10),
              Text('Tap to pick', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: on.withValues(alpha: 0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
    );
  }
}

class _HslDialog extends StatefulWidget {
  const _HslDialog({required this.title, required this.seed});

  final String title;
  final Color seed;

  @override
  State<_HslDialog> createState() => _HslDialogState();
}

class _HslDialogState extends State<_HslDialog> {
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
      title: Text(widget.title),
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
          _Slider(label: 'Hue', v: _h, min: 0, max: 360, onChanged: (v) => setState(() => _h = v)),
          _Slider(label: 'Sat', v: _s * 100, min: 0, max: 100, onChanged: (v) => setState(() => _s = v / 100)),
          _Slider(label: 'Light', v: _l * 100, min: 0, max: 100, onChanged: (v) => setState(() => _l = v / 100)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, color), child: const Text('Use')),
      ],
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({required this.label, required this.v, required this.min, required this.max, required this.onChanged});

  final String label;
  final double v;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 54, child: Text(label)),
        Expanded(child: Slider(value: v.clamp(min, max), min: min, max: max, onChanged: onChanged)),
      ],
    );
  }
}


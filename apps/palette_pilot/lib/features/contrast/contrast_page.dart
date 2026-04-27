import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../services/palette_store.dart';
import '../../utils/color_utils.dart';

class ContrastPage extends StatefulWidget {
  const ContrastPage({super.key, required this.store, required this.settings});

  final PaletteStore store;
  final AppSettingsController settings;

  @override
  State<ContrastPage> createState() => _ContrastPageState();
}

class _ContrastPageState extends State<ContrastPage> {
  Color _fg = Colors.white;
  Color _bg = Colors.black;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = contrastRatio(_fg, _bg);
    final target = widget.settings.value.contrastTarget;
    final ok = meetsTarget(ratio, target);

    final fgOn = ThemeData.estimateBrightnessForColor(_fg) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bgOn = ThemeData.estimateBrightnessForColor(_bg) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        DecoratedBox(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _Badge(ok: ok, target: target),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 138,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: _bg),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Readable text matters',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: _fg,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.62),
                          child: Text(
                            'Contrast ratio: ${ratio.toStringAsFixed(2)}:1',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _fg.withValues(alpha: 0.9),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ColorPickCard(
                        title: 'Foreground',
                        subtitle: formatColor(_fg, widget.settings.value.colorFormat),
                        color: _fg,
                        textColor: fgOn,
                        onPick: () => _pick('Foreground', _fg, (c) => setState(() => _fg = c)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ColorPickCard(
                        title: 'Background',
                        subtitle: formatColor(_bg, widget.settings.value.colorFormat),
                        color: _bg,
                        textColor: bgOn,
                        onPick: () => _pick('Background', _bg, (c) => setState(() => _bg = c)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Quick picks', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (!widget.store.loaded || widget.store.palettes.isEmpty)
          Text(
            'Create a palette to enable one-tap foreground/background picks.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in widget.store.palettes.take(4))
                for (final v in p.colors.take(min(5, p.colors.length)))
                  _SmallColorButton(
                    color: Color(v),
                    onTap: () => setState(() => _fg = Color(v)),
                    tooltip: 'Set foreground',
                  ),
              for (final p in widget.store.palettes.take(4))
                for (final v in p.colors.take(min(5, p.colors.length)))
                  _SmallColorButton(
                    color: Color(v),
                    onTap: () => setState(() => _bg = Color(v)),
                    tooltip: 'Set background',
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

class _Badge extends StatelessWidget {
  const _Badge({required this.ok, required this.target});

  final bool ok;
  final ContrastTarget target;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = target == ContrastTarget.aa ? 'AA' : 'AAA';
    final bg = ok ? scheme.primaryContainer : scheme.errorContainer;
    final fg = ok ? scheme.onPrimaryContainer : scheme.onErrorContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          ok ? '$label pass' : '$label fail',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _ColorPickCard extends StatelessWidget {
  const _ColorPickCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
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
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textColor)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor.withValues(alpha: 0.9))),
              const SizedBox(height: 10),
              Text('Tap to pick', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor.withValues(alpha: 0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallColorButton extends StatelessWidget {
  const _SmallColorButton({required this.color, required this.onTap, required this.tooltip});

  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35)),
          ),
        ),
      ),
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


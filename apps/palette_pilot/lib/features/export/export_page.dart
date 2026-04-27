import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/settings/app_settings.dart';
import '../../app/settings/app_settings_controller.dart';
import '../../services/palette_store.dart';
import '../../utils/color_utils.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key, required this.store, required this.settings});

  final PaletteStore store;
  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    if (!store.loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final fmt = settings.value.colorFormat;
    final padding = settings.value.exportPadding.toDouble();
    final payload = _buildExportPayload(fmt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Card(
          title: 'Export as text',
          subtitle: 'Copy a compact list of swatches for design handoff.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(payload, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: payload));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy export'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'Preview cards',
          subtitle: 'A padded preview (controlled by Settings → Export padding).',
          child: Column(
            children: [
              for (final p in store.palettes.take(4)) ...[
                _PreviewCard(paletteName: p.name, colors: p.colors.map((v) => Color(v)).toList(), padding: padding),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _buildExportPayload(ColorFormat fmt) {
    final lines = <String>[];
    for (final p in store.palettes) {
      lines.add('[${p.name}]');
      for (final v in p.colors) {
        lines.add('- ${formatColor(Color(v), fmt)}');
      }
      lines.add('');
    }
    return lines.join('\n').trim();
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

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
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.paletteName, required this.colors, required this.padding});

  final String paletteName;
  final List<Color> colors;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: scheme.surface,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(paletteName, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final c in colors.take(5)) ...[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.7,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ]..removeLast(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


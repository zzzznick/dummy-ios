import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/settings/app_settings_controller.dart';
import '../../services/palette_store.dart';
import '../../utils/color_utils.dart';

class SwatchesPage extends StatelessWidget {
  const SwatchesPage({super.key, required this.store, required this.settings});

  final PaletteStore store;
  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!store.loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = <Color>{
      for (final p in store.palettes) ...p.colors.map((v) => Color(v)),
    }.toList(growable: false);

    if (colors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No swatches yet. Create a palette to see your colors here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final fmt = settings.value.colorFormat;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: colors.length,
      itemBuilder: (context, i) {
        final c = colors[i];
        final label = formatColor(c, fmt);
        final on = ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : Colors.black;
        return InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: label));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied $label')),
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tap to copy', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: on.withValues(alpha: 0.9))),
                  const Spacer(),
                  Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: on)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


import 'package:flutter/material.dart';

import '../app/settings/east_settings.dart';
import '../models/tile_catalog.dart';

class TileSketchChip extends StatelessWidget {
  const TileSketchChip({
    super.key,
    required this.id,
    required this.scale,
    required this.glyphWeight,
    this.onTap,
    this.dense = false,
  });

  final String id;
  final double scale;
  final HonorGlyphWeight glyphWeight;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final honor = TileCatalog.isHonor(id);
    final raw = TileCatalog.face(id);
    final label =
        honor && glyphWeight == HonorGlyphWeight.soft ? TileCatalog.syllable(id) : raw;

    final w = (dense ? 40.0 : 48.0) * scale;

    final child = Container(
      width: w,
      height: w + 10 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: honor
              ? <Color>[
                  cs.secondaryContainer.withValues(alpha: 0.95),
                  cs.tertiaryContainer.withValues(alpha: 0.85),
                ]
              : <Color>[
                  cs.surfaceContainerHigh,
                  cs.surfaceContainerHighest,
                ],
        ),
        borderRadius: BorderRadius.circular(9 * scale),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: Offset(0, 2 * scale),
            blurRadius: 3 * scale,
            color: Colors.black.withValues(alpha: 0.07),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 5 * scale),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: honor ? FontWeight.w800 : FontWeight.w700,
                color: honor ? cs.onSecondaryContainer : cs.onSurfaceVariant,
              ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9 * scale),
        child: child,
      ),
    );
  }
}

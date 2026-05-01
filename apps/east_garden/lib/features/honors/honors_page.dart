import 'package:flutter/material.dart';

import '../../app/settings/east_settings.dart';
import '../../models/tile_catalog.dart';
import '../../widgets/tile_sketch_chip.dart';

class HonorsPage extends StatelessWidget {
  const HonorsPage({
    super.key,
    required this.chipComfort,
    required this.glyphWeight,
  });

  final double chipComfort;
  final HonorGlyphWeight glyphWeight;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
          sliver: SliverToBoxAdapter(
            child: Text('Honor glossary', style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Dragons behave like elemental stamps. Winds behave like directional signatures. Tiles below mirror how Sketch labels them.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          sliver: SliverToBoxAdapter(child: Text('Winds', style: Theme.of(context).textTheme.titleLarge)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TileCatalog.winds.map((id) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TileSketchChip(
                      id: id,
                      scale: chipComfort,
                      glyphWeight: glyphWeight,
                      dense: false,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 90,
                      child: Text(
                        _windBlurb(id),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
          sliver: SliverToBoxAdapter(child: Text('Dragons', style: Theme.of(context).textTheme.titleLarge)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TileCatalog.dragons.map((id) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TileSketchChip(
                      id: id,
                      scale: chipComfort,
                      glyphWeight: glyphWeight,
                      dense: false,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: Text(
                        _dragonBlurb(id),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  static String _windBlurb(String id) {
    return switch (id) {
      'ew' => 'Dealer-aligned marker in compass stories.',
      'sw' => 'Left seat along the directional ring.',
      'ww' => 'Across-table seat from East narratives.',
      'nw' => 'Right seat wrapping the quartet.',
      _ => '',
    };
  }

  static String _dragonBlurb(String id) {
    return switch (id) {
      'wd' => 'Cools the board palette; favors plain shapes.',
      'gd' => 'Adds vegetal spark; stacks with bamboo motifs.',
      'rd' => 'Fiery punctuation; contrasts with muted suits.',
      _ => '',
    };
  }
}

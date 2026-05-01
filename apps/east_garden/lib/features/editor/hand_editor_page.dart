import 'package:flutter/material.dart';

import '../../app/settings/east_settings.dart';
import '../../app/settings/east_settings_controller.dart';
import '../../models/saved_hand.dart';
import '../../models/tile_catalog.dart';
import '../../services/hand_library_store.dart';
import '../../widgets/tile_sketch_chip.dart';

class HandEditorPage extends StatefulWidget {
  const HandEditorPage({
    super.key,
    required this.settings,
    required this.library,
    required this.handId,
  });

  final EastSettingsController settings;
  final HandLibraryStore library;
  final String handId;

  @override
  State<HandEditorPage> createState() => _HandEditorPageState();
}

class _HandEditorPageState extends State<HandEditorPage> with TickerProviderStateMixin {
  final TextEditingController _titleCtl = TextEditingController();

  late TabController _tab;
  List<String> _tiles = <String>[];
  bool _hydratedFromStore = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateOnce());
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _hydrateOnce() {
    if (!mounted || _hydratedFromStore) return;
    final h = widget.library.byId(widget.handId);
    if (h == null) return;
    setState(() {
      _hydratedFromStore = true;
      _titleCtl.text = h.title;
      _tiles = List<String>.from(h.tiles);
    });
  }

  static const _kMaxTiles = 14;

  void _push(String id) {
    if (_tiles.length >= _kMaxTiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sketch holds fourteen tiles tops. Remove one to continue.')),
      );
      return;
    }
    setState(() => _tiles.add(id));
  }

  Future<void> _persist() async {
    final seed = widget.library.byId(widget.handId);
    if (seed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sketch not found.')));
      }
      return;
    }
    await widget.library.upsert(
      SavedHand(
        id: seed.id,
        title: _titleCtl.text.trim().isEmpty ? seed.title : _titleCtl.text.trim(),
        tiles: List<String>.from(_tiles),
        updatedMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sketch updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.library,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: widget.settings,
          builder: (context, _) {
            if (!_hydratedFromStore && widget.library.byId(widget.handId) != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateOnce());
            }

            if (widget.library.byId(widget.handId) == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Missing sketch')),
                body: const Center(child: Text('This sketch was removed from Library.')),
              );
            }

            final cs = Theme.of(context).colorScheme;
            final gw = widget.settings.value.honorGlyphWeight;
            final sc = widget.settings.value.chipComfort;

            return Scaffold(
              appBar: AppBar(title: const Text('Edit sketch')),
              body: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                      child: TextField(
                        controller: _titleCtl,
                        decoration: const InputDecoration(labelText: 'Sketch title'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${_tiles.length} staged tiles',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Spacer(),
                          FilledButton(onPressed: _persist, child: const Text('Save')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _tiles.isEmpty
                          ? Center(
                              child: Text(
                                'Stage tiles below. Tap a chip above to peel it away.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: cs.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: _tiles.length,
                              itemBuilder: (context, i) {
                                final id = _tiles[i];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: TileSketchChip(
                                    id: id,
                                    scale: sc,
                                    glyphWeight: gw,
                                    onTap: () => setState(() => _tiles.removeAt(i)),
                                    dense: true,
                                  ),
                                );
                              },
                            ),
                    ),
                    Material(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
                      child: TabBar(
                        controller: _tab,
                        tabs: const <Tab>[
                          Tab(text: 'Characters'),
                          Tab(text: 'Dots'),
                          Tab(text: 'Bamboo'),
                          Tab(text: 'Honors'),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TabBarView(
                        controller: _tab,
                        children: <Widget>[
                          _paletteWrap(TileCatalog.man, gw, sc, _push),
                          _paletteWrap(TileCatalog.pin, gw, sc, _push),
                          _paletteWrap(TileCatalog.sou, gw, sc, _push),
                          _paletteWrap(
                            <String>[...TileCatalog.winds, ...TileCatalog.dragons],
                            gw,
                            sc,
                            _push,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _paletteWrap(List<String> ids, HonorGlyphWeight gw, double sc, void Function(String) onTap) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ids.map((id) {
            return TileSketchChip(
              id: id,
              scale: sc,
              glyphWeight: gw,
              onTap: () => onTap(id),
            );
          }).toList(),
        ),
      ],
    );
  }
}

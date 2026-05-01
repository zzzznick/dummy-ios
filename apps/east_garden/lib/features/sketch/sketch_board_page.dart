import 'package:flutter/material.dart';

import '../../app/settings/east_settings.dart';
import '../../app/settings/east_settings_controller.dart';
import '../../models/saved_hand.dart';
import '../../models/tile_catalog.dart';
import '../../services/hand_library_store.dart';
import '../../widgets/tile_sketch_chip.dart';

class SketchBoardPage extends StatefulWidget {
  const SketchBoardPage({
    super.key,
    required this.settings,
    required this.library,
  });

  final EastSettingsController settings;
  final HandLibraryStore library;

  @override
  State<SketchBoardPage> createState() => _SketchBoardPageState();
}

class _SketchBoardPageState extends State<SketchBoardPage> with TickerProviderStateMixin {
  final List<String> _tiles = <String>[];
  late TabController _tab;

  static const _kMaxTiles = 14;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _push(String id) {
    if (_tiles.length >= _kMaxTiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sketch holds fourteen tiles tops. Remove one to continue.')),
      );
      return;
    }
    setState(() => _tiles.add(id));
  }

  void _clear() {
    setState(() => _tiles.clear());
  }

  Future<void> _save() async {
    if (_tiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add tiles before saving.')));
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _SketchTitleDialog(
        initialTitle: 'Table sketch ${_tiles.length} tiles',
      ),
    );

    if (name == null || !mounted) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();

    await widget.library.upsert(
      SavedHand(
        id: id,
        title: name,
        tiles: List<String>.from(_tiles),
        updatedMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved "$name" to Library')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;
        final gw = widget.settings.value.honorGlyphWeight;
        final sc = widget.settings.value.chipComfort;

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Row(
                children: <Widget>[
                  Text('Composition (${_tiles.length}/$_kMaxTiles)', style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  TextButton(onPressed: _tiles.isEmpty ? null : _clear, child: const Text('Clear')),
                  const SizedBox(width: 6),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
            Expanded(
              child: _tiles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'Tap tiles below to stage a hypothetical hand.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
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
                  _paletteWrap(<String>[...TileCatalog.winds, ...TileCatalog.dragons], gw, sc, _push),
                ],
              ),
            ),
          ],
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
          alignment: WrapAlignment.start,
          children: ids.map((id) {
            return TileSketchChip(
              id: id,
              scale: sc,
              glyphWeight: gw,
              dense: false,
              onTap: () => onTap(id),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Owns its [TextEditingController] so it is disposed only after the route has dropped the dialog subtree.
class _SketchTitleDialog extends StatefulWidget {
  const _SketchTitleDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_SketchTitleDialog> createState() => _SketchTitleDialogState();
}

class _SketchTitleDialogState extends State<_SketchTitleDialog> {
  late final TextEditingController _titleField = TextEditingController(text: widget.initialTitle);

  @override
  void dispose() {
    _titleField.dispose();
    super.dispose();
  }

  void _confirm() {
    final v = _titleField.text.trim();
    Navigator.pop<String>(context, v.isEmpty ? 'Untitled sketch' : v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save hand sketch'),
      content: TextField(
        controller: _titleField,
        autofocus: true,
        onSubmitted: (_) => _confirm(),
        decoration: const InputDecoration(
          labelText: 'Sketch title',
          hintText: 'Evening rehearsal',
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop<String>(context), child: const Text('Cancel')),
        FilledButton(onPressed: _confirm, child: const Text('Save')),
      ],
    );
  }
}

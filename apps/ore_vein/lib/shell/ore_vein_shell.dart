import 'package:flutter/material.dart';

import '../app/settings/ore_settings_controller.dart';
import '../features/atlas/atlas_page.dart';
import '../features/editor/field_note_editor_page.dart';
import '../features/kit/field_kit_page.dart';
import '../features/mohs/mohs_lab_page.dart';
import '../features/streak/streak_board_page.dart';
import '../features/vault/vault_page.dart';
import '../services/field_note_store.dart';
import 'settings/ore_shaft_settings_page.dart';

class OreVeinShell extends StatefulWidget {
  const OreVeinShell({
    super.key,
    required this.settings,
    required this.notes,
  });

  final OreSettingsController settings;
  final FieldNoteStore notes;

  @override
  State<OreVeinShell> createState() => _OreVeinShellState();
}

class _OreVeinShellState extends State<OreVeinShell> {
  int _index = 0;

  Future<void> _openShaft() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OreShaftSettingsPage(
          settings: widget.settings,
          notes: widget.notes,
        ),
      ),
    );
  }

  void _composeVault() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FieldNoteEditorPage(store: widget.notes, noteId: null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = <String>['Atlas', 'Mohs bench', 'Streak', 'Kit', 'Vault'];

    final pages = <Widget>[
      const AtlasPage(),
      MohsLabPage(settings: widget.settings),
      const StreakBoardPage(),
      FieldKitPage(settings: widget.settings),
      VaultPage(notes: widget.notes, settings: widget.settings),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: <Widget>[
          if (_index == 4)
            IconButton(
              tooltip: 'New vault specimen',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _composeVault,
            ),
          IconButton(
            tooltip: 'Shaft controls',
            icon: const Icon(Icons.vertical_split_rounded),
            onPressed: () async => _openShaft(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Atlas'),
          NavigationDestination(icon: Icon(Icons.join_inner_rounded), label: 'Mohs'),
          NavigationDestination(icon: Icon(Icons.palette_rounded), label: 'Streak'),
          NavigationDestination(icon: Icon(Icons.hardware_rounded), label: 'Kit'),
          NavigationDestination(icon: Icon(Icons.warehouse_rounded), label: 'Vault'),
        ],
      ),
    );
  }
}

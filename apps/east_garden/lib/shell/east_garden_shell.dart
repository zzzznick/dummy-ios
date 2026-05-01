import 'package:flutter/material.dart';

import '../app/settings/east_settings_controller.dart';
import '../features/bloom/bloom_garden_page.dart';
import '../features/honors/honors_page.dart';
import '../features/library/hand_library_page.dart';
import '../features/sketch/sketch_board_page.dart';
import '../features/winds/winds_page.dart';
import '../services/hand_library_store.dart';
import 'settings/east_app_settings_page.dart';

class EastGardenShell extends StatefulWidget {
  const EastGardenShell({
    super.key,
    required this.settings,
    required this.library,
  });

  final EastSettingsController settings;
  final HandLibraryStore library;

  @override
  State<EastGardenShell> createState() => _EastGardenShellState();
}

class _EastGardenShellState extends State<EastGardenShell> {
  int _index = 0;

  Future<void> _openCourtyard() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EastAppSettingsPage(
          settings: widget.settings,
          library: widget.library,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = <String>['Winds', 'Honors', 'Sketch', 'Library', 'Bloom'];

    final pages = <Widget>[
      WindsPage(settings: widget.settings),
      ListenableBuilder(
        listenable: widget.settings,
        builder: (_, _) {
          final s = widget.settings.value;
          return HonorsPage(
            chipComfort: s.chipComfort,
            glyphWeight: s.honorGlyphWeight,
          );
        },
      ),
      SketchBoardPage(
        settings: widget.settings,
        library: widget.library,
      ),
      HandLibraryPage(
        library: widget.library,
        settings: widget.settings,
      ),
      BloomGardenPage(settings: widget.settings),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: <Widget>[
          IconButton(
            tooltip: 'Courtyard settings',
            icon: Icon(Icons.emoji_nature_rounded),
            onPressed: () async => _openCourtyard(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.explore_rounded), label: 'Winds'),
          NavigationDestination(icon: Icon(Icons.diamond_rounded), label: 'Honors'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Sketch'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.blur_on_rounded), label: 'Bloom'),
        ],
      ),
    );
  }
}

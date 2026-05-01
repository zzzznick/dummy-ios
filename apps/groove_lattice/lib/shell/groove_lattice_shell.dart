import 'package:flutter/material.dart';

import '../app/settings/app_settings_controller.dart';
import '../features/composer/composer_page.dart';
import '../features/drill/drill_page.dart';
import '../features/lab/lab_page.dart';
import '../features/library/library_page.dart';
import '../features/studio/studio_page.dart';
import '../services/groove_store.dart';
import 'settings/groove_settings_page.dart';

class GrooveLatticeShell extends StatefulWidget {
  const GrooveLatticeShell({
    super.key,
    required this.settings,
    required this.store,
  });

  final AppSettingsController settings;
  final GrooveStore store;

  @override
  State<GrooveLatticeShell> createState() => _GrooveLatticeShellState();
}

class _GrooveLatticeShellState extends State<GrooveLatticeShell> {
  int _index = 0;

  Future<void> _openSettings() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GrooveSettingsPage(
          settings: widget.settings,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Studio', 'Composer', 'Library', 'Drill', 'Lab'];

    final pages = <Widget>[
      StudioPage(store: widget.store, settings: widget.settings),
      ComposerPage(store: widget.store, settings: widget.settings),
      LibraryPage(store: widget.store, settings: widget.settings),
      const DrillPage(),
      const LabPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.graphic_eq_rounded),
            onPressed: () async => _openSettings(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.blur_on_rounded),
            label: 'Studio',
          ),
          NavigationDestination(
            icon: Icon(Icons.schema_rounded),
            label: 'Composer',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.touch_app_rounded),
            label: 'Drill',
          ),
          NavigationDestination(
            icon: Icon(Icons.scatter_plot_rounded),
            label: 'Lab',
          ),
        ],
      ),
    );
  }
}

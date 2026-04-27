import 'package:flutter/material.dart';

import '../app/settings/app_settings_controller.dart';
import '../features/contrast/contrast_page.dart';
import '../features/export/export_page.dart';
import '../features/mixer/mixer_page.dart';
import '../features/palettes/palettes_page.dart';
import '../features/swatches/swatches_page.dart';
import '../services/palette_store.dart';
import 'settings/palette_pilot_settings_page.dart';

class PalettePilotShell extends StatefulWidget {
  const PalettePilotShell({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<PalettePilotShell> createState() => _PalettePilotShellState();
}

class _PalettePilotShellState extends State<PalettePilotShell> {
  final PaletteStore _store = PaletteStore();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final pages = <Widget>[
          PalettesPage(store: _store, settings: widget.settings),
          ContrastPage(store: _store, settings: widget.settings),
          MixerPage(store: _store, settings: widget.settings),
          SwatchesPage(store: _store, settings: widget.settings),
          ExportPage(store: _store, settings: widget.settings),
        ];

        final titles = ['Palettes', 'Contrast', 'Mixer', 'Swatches', 'Export'];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_index]),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PalettePilotSettingsPage(
                        settings: widget.settings,
                        store: _store,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          body: pages[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Palettes',
              ),
              NavigationDestination(
                icon: Icon(Icons.contrast_rounded),
                label: 'Contrast',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_mosaic_rounded),
                label: 'Mixer',
              ),
              NavigationDestination(
                icon: Icon(Icons.palette_rounded),
                label: 'Swatches',
              ),
              NavigationDestination(
                icon: Icon(Icons.ios_share_rounded),
                label: 'Export',
              ),
            ],
          ),
        );
      },
    );
  }
}


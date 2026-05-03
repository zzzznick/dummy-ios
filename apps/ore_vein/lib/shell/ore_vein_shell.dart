import 'package:flutter/material.dart';

import '../app/settings/app_settings.dart';
import '../app/settings/app_settings_controller.dart';
import '../features/lists/lists_page.dart';
import '../features/swatches/swatches_page.dart';
import '../features/timer/timer_page.dart';
import '../features/tip/tip_page.dart';
import '../features/units/units_page.dart';
import '../services/ore_vein_data_store.dart';
import 'settings/ore_vein_settings_page.dart';

class OreVeinShell extends StatefulWidget {
  const OreVeinShell({super.key, required this.settings, required this.data});

  final AppSettingsController settings;
  final OreVeinDataStore data;

  @override
  State<OreVeinShell> createState() => _OreVeinShellState();
}

class _OreVeinShellState extends State<OreVeinShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TimerPage(settings: widget.settings, data: widget.data),
      UnitsPage(settings: widget.settings),
      ListsPage(settings: widget.settings, data: widget.data),
      TipPage(settings: widget.settings),
      SwatchesPage(settings: widget.settings, data: widget.data),
    ];
    const titles = <String>['Timer', 'Convert', 'Lists', 'Tip', 'Swatches'];

    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final dense = widget.settings.value.numberDensity == NumberDensity.compact;
        final scale = dense ? 0.94 : 1.0;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(titles[_index]),
                  Text(
                    'Ore Vein',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => OreVeinSettingsPage(
                          settings: widget.settings,
                          data: widget.data,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
            body: IndexedStack(index: _index, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
                NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), label: 'Convert'),
                NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Lists'),
                NavigationDestination(icon: Icon(Icons.restaurant_rounded), label: 'Tip'),
                NavigationDestination(icon: Icon(Icons.palette_outlined), label: 'Swatches'),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../features/boards/boards_page.dart';
import '../features/convert/convert_page.dart';
import '../features/grid/grid_page.dart';
import '../app/gauge_scope.dart';
import '../features/settings/gauge_settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      GridPage(),
      BoardsPage(),
      ConvertPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gauge Grid'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              final store = GaugeScope.of(context);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) {
                    // Pushed routes are siblings of MainShell, not under the
                    // root GaugeScope — re-provide the same store for Settings.
                    return GaugeScope(
                      store: store,
                      child: const GaugeSettingsPage(),
                    );
                  },
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) {
          if (!context.mounted) return;
          setState(() => _index = i);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.grid_4x4), label: 'Grid'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            label: 'Boards',
          ),
          NavigationDestination(
            icon: Icon(Icons.straighten),
            label: 'Convert',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'diary/diary_page.dart';
import 'feast/feast_page.dart';
import 'recipes/recipes_page.dart';
import '../services/feast_backup_manager.dart';

class LocalTabsPage extends StatefulWidget {
  const LocalTabsPage({super.key});

  @override
  State<LocalTabsPage> createState() => _LocalTabsPageState();
}

class _LocalTabsPageState extends State<LocalTabsPage> {
  int _index = 0;
  final FeastBackupManager _backupManager = FeastBackupManager();

  @override
  void initState() {
    super.initState();
    _backupManager.restoreIfPresent();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const FeastPage(),
      const RecipesPage(),
      const DiaryPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'My Feast',
          ),
          NavigationDestination(icon: Icon(Icons.book), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.note), label: 'Food Diary'),
        ],
      ),
    );
  }
}

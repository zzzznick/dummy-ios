import 'package:flutter/material.dart';

import '../../app/gauge_scope.dart';
import '../../data/gauge_store.dart';

class BoardsPage extends StatelessWidget {
  const BoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GaugeScope.of(context);
    if (store.boards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No saved boards yet. Build a pattern on Grid and tap Save board.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: store.boards.length,
      itemBuilder: (BuildContext c, int i) {
        final b = store.boards[store.boards.length - 1 - i];
        return Dismissible(
          key: Key(b.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(c).colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Theme.of(c).colorScheme.onErrorContainer),
          ),
          onDismissed: (_) {
            store.removeBoard(b.id);
            ScaffoldMessenger.of(
              c,
            ).showSnackBar(SnackBar(content: Text('Removed "${b.name}"')));
          },
          child: Card(
            child: ListTile(
              title: Text(b.name),
              subtitle: Text('${b.cells.length} values · ${b.gridSize}×${b.gridSize}'),
              leading: const Icon(Icons.dashboard_customize),
              onTap: () {
                _apply(context, b);
              },
            ),
          ),
        );
      },
    );
  }

  void _apply(BuildContext context, SavedBoard b) {
    final store = GaugeScope.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Load board'),
        content: Text(
          'Replace the live grid with "${b.name}"? Current unsaved cell edits are replaced.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              store.applyBoard(b);
              Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Board loaded on Grid tab')));
              }
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }
}

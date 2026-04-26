import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/gauge_scope.dart';
import '../../data/gauge_store.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GaugeScope.of(context);
    final n = store.gridSize;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Tap a cell to set a value (lengths, notes, or labels).',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext c, BoxConstraints co) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(c).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: n,
                        ),
                        itemCount: n * n,
                        itemBuilder: (BuildContext ctx, int i) {
                          final r = i ~/ n;
                          final col = i % n;
                          final v = store.cellAt(r, col);
                          return _CellTile(
                            value: v,
                            onTap: () => _editCell(context, r, col),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _confirmClear(context, store);
                },
                child: const Text('Clear all cells'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _saveBoard(context, store),
                child: const Text('Save board'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _editCell(BuildContext context, int r, int c) async {
    final store = GaugeScope.of(context);
    final current = store.cellAt(r, c) ?? '';
    final ctrl = TextEditingController(text: current);
    final v = await showDialog<String?>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Cell ($r, $c)'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Value',
              hintText: 'e.g. 12.4 or note',
            ),
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                store.setCell(r, c, null);
                Navigator.of(ctx).pop('cleared');
              },
              child: const Text('Clear cell'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (v != null && v != 'cleared') {
      final t = v.trim();
      if (t.isEmpty) {
        store.setCell(r, c, null);
      } else {
        store.setCell(r, c, t);
      }
    }
  }

  static void _confirmClear(BuildContext context, GaugeStore store) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Clear all?'),
        content: const Text('This removes every value on the live grid (saved boards are kept).'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              store.clearAllCells();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  static Future<void> _saveBoard(BuildContext context, GaugeStore store) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Save board'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Board name'),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      store.saveAsBoard(name);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved as "${name.trim()}"')));
      }
    }
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({required this.value, required this.onTap});

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = value;
    return Material(
      color: t == null
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              t == null || t.isEmpty ? '·' : t,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}

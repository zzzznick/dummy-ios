import 'package:flutter/material.dart';

import '../../app/settings/east_settings_controller.dart';
import '../../models/saved_hand.dart';
import '../../services/hand_library_store.dart';
import '../editor/hand_editor_page.dart';

class HandLibraryPage extends StatelessWidget {
  const HandLibraryPage({
    super.key,
    required this.library,
    required this.settings,
  });

  final HandLibraryStore library;
  final EastSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: library,
      builder: (context, _) {
        if (library.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.folder_open_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'No saved sketches yet',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Frame a hypothetical hand inside Sketch, tap Save, and it lands here instantly.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: library.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final SavedHand hand = library.items[index];
            return Card(
              child: ListTile(
                title: Text(hand.title),
                subtitle: Text('${hand.tiles.length} tiles · updated ${_formatTs(hand.updatedMs)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete sketch',
                  onPressed: () async {
                    await library.remove(hand.id);
                  },
                ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => HandEditorPage(
                            settings: settings,
                            library: library,
                            handId: hand.id,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static String _formatTs(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.month}/${d.day}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}

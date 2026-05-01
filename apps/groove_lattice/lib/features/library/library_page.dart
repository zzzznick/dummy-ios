import 'package:flutter/material.dart';

import '../../app/settings/app_settings_controller.dart';
import '../../features/editor/groove_editor_page.dart';
import '../../services/groove_store.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.store,
    required this.settings,
  });

  final GrooveStore store;
  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (!store.loaded) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        final items = store.items;
        if (items.isEmpty) {
          return const Center(child: Text('Nothing saved yet. Compose something first.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final g = items[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${g.steps.length}')),
                title: Text(g.name),
                subtitle: Text('${g.bpm} BPM • ${g.steps.join(' × ')}'),
                onTap: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          GrooveEditorPage(store: store, settings: settings, initial: g.copyWith()),
                    ),
                  );
                },
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await store.remove(g.id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

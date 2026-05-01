import 'package:flutter/material.dart';

import '../../app/settings/ore_settings.dart';
import '../../app/settings/ore_settings_controller.dart';
import '../../models/field_note.dart';
import '../../models/mineral_ref.dart';
import '../../services/field_note_store.dart';
import '../editor/field_note_editor_page.dart';

class VaultPage extends StatelessWidget {
  const VaultPage({super.key, required this.notes, required this.settings});

  final FieldNoteStore notes;
  final OreSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notes,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            final dense = settings.value.vaultDensity == VaultCardDensity.compact;
            if (notes.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Text('Vault is airy', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(
                        'Capture a trench-side hunch using the toolbar action—it stays offline.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 108),
              itemCount: notes.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final FieldNote n = notes.items[index];
                final MineralRef? m = MineralRef.byKey(n.mineralKey);
                return Card(
                  child: ListTile(
                    visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
                    title: Text(n.title),
                    subtitle: Text(
                      '${m?.commonName ?? n.mineralKey} · ${_guessLine(n)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => notes.remove(n.id),
                    ),
                    onTap: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => FieldNoteEditorPage(store: notes, noteId: n.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static String _guessLine(FieldNote n) {
    if (n.mohsGuess == null) return n.contextLine;
    return 'Guess ${n.mohsGuess} · ${n.contextLine}';
  }
}

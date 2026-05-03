import 'package:flutter/material.dart';

import '../../app/settings/app_settings_controller.dart';
import '../../models/checklist.dart';
import '../../services/ore_vein_data_store.dart';
import 'checklist_detail_page.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key, required this.settings, required this.data});

  final AppSettingsController settings;
  final OreVeinDataStore data;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[settings, data]),
      builder: (context, _) {
        final lists = List<Checklist>.from(data.checklists);
        if (settings.value.listsNewestFirst) {
          lists.sort((a, b) => b.id.compareTo(a.id));
        } else {
          lists.sort((a, b) => a.id.compareTo(b.id));
        }
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  onPressed: () async {
                    final id = '${DateTime.now().millisecondsSinceEpoch}';
                    final c = Checklist(id: id, title: 'New list');
                    await data.upsertChecklist(c);
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChecklistDetailPage(
                          settings: settings,
                          data: data,
                          checklistId: id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New checklist'),
                ),
              ),
            ),
            if (lists.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No lists yet. Tap New checklist.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = lists[i];
                    return ListTile(
                      title: Text(c.title.isEmpty ? 'Untitled' : c.title),
                      subtitle: Text('${c.items.where((e) => e.done).length}/${c.items.length} done'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChecklistDetailPage(
                              settings: settings,
                              data: data,
                              checklistId: c.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: lists.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

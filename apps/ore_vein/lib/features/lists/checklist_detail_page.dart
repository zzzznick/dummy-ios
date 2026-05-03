import 'package:flutter/material.dart';

import '../../app/settings/app_settings_controller.dart';
import '../../models/checklist.dart';
import '../../services/ore_vein_data_store.dart';

class ChecklistDetailPage extends StatefulWidget {
  const ChecklistDetailPage({
    super.key,
    required this.settings,
    required this.data,
    required this.checklistId,
  });

  final AppSettingsController settings;
  final OreVeinDataStore data;
  final String checklistId;

  @override
  State<ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  late final TextEditingController _title;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = _find();
      if (c != null) _title.text = c.title;
    });
  }

  Checklist? _find() {
    try {
      return widget.data.checklists.firstWhere((e) => e.id == widget.checklistId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
    final c = _find();
    if (c == null) return;
    c.title = _title.text.trim();
    await widget.data.upsertChecklist(c);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.data,
      builder: (context, _) {
        final c = _find();
        if (c == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Missing')),
            body: const Center(child: Text('This list was removed.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _title,
              decoration: const InputDecoration.collapsed(hintText: 'List title'),
              style: Theme.of(context).textTheme.titleLarge,
              onSubmitted: (_) => _saveTitle(),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Save title',
                onPressed: _saveTitle,
                icon: const Icon(Icons.save_outlined),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: c.items.length,
            itemBuilder: (context, i) {
              final it = c.items[i];
              return ListTile(
                leading: Checkbox(
                  value: it.done,
                  onChanged: (v) async {
                    it.done = v ?? false;
                    await widget.data.upsertChecklist(c);
                  },
                ),
                title: Text(it.text.isEmpty ? 'Item' : it.text),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final next = await showDialog<String>(
                      context: context,
                      builder: (ctx) => _EditLineDialog(initial: it.text),
                    );
                    if (next == null || !mounted) return;
                    it.text = next;
                    await widget.data.upsertChecklist(c);
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final text = await showDialog<String>(
                context: context,
                builder: (ctx) => const _EditLineDialog(initial: ''),
              );
              if (text == null || text.trim().isEmpty || !mounted) return;
              c.items.add(
                ChecklistItem(
                  id: '${DateTime.now().millisecondsSinceEpoch}',
                  text: text.trim(),
                ),
              );
              await widget.data.upsertChecklist(c);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add item'),
          ),
        );
      },
    );
  }
}

class _EditLineDialog extends StatefulWidget {
  const _EditLineDialog({required this.initial});

  final String initial;

  @override
  State<_EditLineDialog> createState() => _EditLineDialogState();
}

class _EditLineDialogState extends State<_EditLineDialog> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Item text'),
      content: TextField(
        controller: _c,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _c.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

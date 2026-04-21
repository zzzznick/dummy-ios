import 'package:flutter/material.dart';

import '../models/mood_entry.dart';

class MoodEditPage extends StatefulWidget {
  const MoodEditPage({super.key, this.existing});

  final MoodEntry? existing;

  @override
  State<MoodEditPage> createState() => _MoodEditPageState();
}

class _MoodEditPageState extends State<MoodEditPage> {
  final _formKey = GlobalKey<FormState>();

  late int _mood;
  late bool _pinned;
  late final TextEditingController _note;
  late final TextEditingController _tags;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _mood = e?.mood ?? 3;
    _pinned = e?.isPinned ?? false;
    _note = TextEditingController(text: e?.note ?? '');
    _tags = TextEditingController(text: e?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit entry' : 'New entry'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _MoodSelector(
              value: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _note,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'A tiny context you might appreciate later…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (optional)',
                hintText: 'work, family, sleep',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _pinned,
              onChanged: (v) => setState(() => _pinned = v),
              title: const Text('Pin this entry'),
              subtitle: const Text('Pinned entries stay on top.'),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Keep it short. Consistency beats perfection.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rawTags = _tags.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = widget.existing;
    final entry = MoodEntry(
      id: existing?.id ?? 'tmp$now',
      createdAtMs: existing?.createdAtMs ?? now,
      mood: _mood,
      note: _note.text,
      tags: rawTags,
      isPinned: _pinned,
    );
    Navigator.of(context).pop(entry);
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (1, '😞', 'Bad'),
      (2, '😕', 'Meh'),
      (3, '😐', 'Okay'),
      (4, '🙂', 'Good'),
      (5, '😄', 'Great'),
    ];

    return Column(
      children: [
        Row(
          children: items.map((i) {
            final selected = i.$1 == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(i.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(i.$2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          i.$3,
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 12),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toString(),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}


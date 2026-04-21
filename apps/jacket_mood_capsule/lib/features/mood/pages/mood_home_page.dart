import 'package:flutter/material.dart';

import '../../../app/settings/app_settings_controller.dart';
import '../controller/mood_controller.dart';
import '../models/mood_entry.dart';
import 'mood_edit_page.dart';
import 'mood_settings_page.dart';

class MoodHomePage extends StatefulWidget {
  const MoodHomePage({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<MoodHomePage> createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
  final MoodController _controller = MoodController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final entries = _controller.entries;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mood Capsule'),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MoodSettingsPage(
                        settings: widget.settings,
                        controller: _controller,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _SummaryCard(entries: entries)),
              if (entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverList.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    return Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context),
                      onDismissed: (_) => _controller.remove(e.id),
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                      child: ListTile(
                        leading: _MoodIcon(score: e.mood, pinned: e.isPinned),
                        title: Text(_titleFor(e)),
                        subtitle: Text(_subtitleFor(e)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final updated = await Navigator.of(context).push<MoodEntry>(
                            MaterialPageRoute(
                              builder: (_) => MoodEditPage(existing: e),
                            ),
                          );
                          if (updated != null) {
                            await _controller.update(e.id, updated);
                          }
                        },
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New entry'),
            onPressed: () async {
              final created = await Navigator.of(context).push<MoodEntry>(
                MaterialPageRoute(builder: (_) => const MoodEditPage()),
              );
              if (created != null) {
                await _controller.add(
                  mood: created.mood,
                  note: created.note,
                  tags: created.tags,
                  isPinned: created.isPinned,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved.')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _titleFor(MoodEntry e) {
    final d = e.createdAt;
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$mm/$dd $hh:$min';
  }

  String _subtitleFor(MoodEntry e) {
    final note = e.note.trim().isEmpty ? 'No notes' : e.note.trim();
    final tags = e.tags.isEmpty ? '' : ' • ${e.tags.map((t) => '#$t').join(' ')}';
    return '$note$tags';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final last7 = _lastDays(entries, 7);
    final avg = last7.isEmpty
        ? null
        : last7.map((e) => e.mood).reduce((a, b) => a + b) / last7.length;
    final pinned = entries.where((e) => e.isPinned).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 days',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      avg == null ? 'No entries yet' : 'Average mood: ${avg.toStringAsFixed(1)}/5',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: '${entries.length} total'),
                        _Chip(text: '$pinned pinned'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _MoodMeter(value: avg),
            ],
          ),
        ),
      ),
    );
  }

  List<MoodEntry> _lastDays(List<MoodEntry> all, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    return all.where((e) => e.createdAtMs >= cutoff).toList(growable: false);
  }
}

class _MoodMeter extends StatelessWidget {
  const _MoodMeter({required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = value;
    final pct = v == null ? 0.0 : (v / 5.0).clamp(0.0, 1.0);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 10,
            backgroundColor: cs.surfaceContainerHigh,
          ),
          Center(
            child: Text(
              v == null ? '—' : v.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _MoodIcon extends StatelessWidget {
  const _MoodIcon({required this.score, required this.pinned});

  final int score;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (score) {
      1 => '😞',
      2 => '😕',
      3 => '😐',
      4 => '🙂',
      _ => '😄',
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 18,
          child: Text(emoji),
        ),
        if (pinned)
          const Positioned(
            right: -6,
            bottom: -6,
            child: Icon(Icons.push_pin, size: 16),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Start your first capsule',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Log a quick mood check-in and keep a tiny note for your future self.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


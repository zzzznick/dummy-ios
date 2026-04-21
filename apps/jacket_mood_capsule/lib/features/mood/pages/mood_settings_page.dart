import 'package:flutter/material.dart';

import '../../../app/settings/app_settings_controller.dart';
import '../controller/mood_controller.dart';

class MoodSettingsPage extends StatelessWidget {
  const MoodSettingsPage({
    super.key,
    required this.settings,
    required this.controller,
  });

  final AppSettingsController settings;
  final MoodController controller;

  @override
  Widget build(BuildContext context) {
    final seeds = <(String, Color)>[
      ('Indigo', const Color(0xFF5B5BD6)),
      ('Mint', const Color(0xFF2A9D8F)),
      ('Sunset', const Color(0xFFE76F51)),
      ('Berry', const Color(0xFF9B5DE5)),
      ('Graphite', const Color(0xFF2B2D42)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: settings,
            builder: (context, _) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in seeds)
                    ChoiceChip(
                      label: Text(s.$1),
                      selected: settings.seedColor.value == s.$2.value,
                      onSelected: (_) => settings.setSeedColor(s.$2),
                      avatar: CircleAvatar(backgroundColor: s.$2),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text('Data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.ios_share_outlined),
            title: const Text('Export data'),
            subtitle: const Text('Copy your entries as JSON.'),
            onTap: () => _export(context),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear all entries'),
            subtitle: const Text('This cannot be undone.'),
            onTap: () => _clearAll(context),
          ),
          const SizedBox(height: 28),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text(
            'Mood Capsule is a tiny daily check-in journal. '
            'It stores everything locally on your device.',
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final json = controller.exportJson();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export JSON'),
        content: SelectableText(
          json,
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear everything?'),
        content: const Text('This will permanently delete all entries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await controller.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All entries cleared.')),
        );
      }
    }
  }
}


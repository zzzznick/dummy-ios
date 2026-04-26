import 'package:flutter/material.dart';

import '../../app/gauge_scope.dart';
import '../../data/gauge_store.dart';

class GaugeSettingsPage extends StatefulWidget {
  const GaugeSettingsPage({super.key});

  @override
  State<GaugeSettingsPage> createState() => _GaugeSettingsPageState();
}

class _GaugeSettingsPageState extends State<GaugeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final store = GaugeScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Grid & units', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Grid size (rows · columns)'),
            subtitle: Slider(
              value: store.gridSize.toDouble(),
              min: 4,
              max: 12,
              divisions: 8,
              label: '${store.gridSize}×${store.gridSize}',
              onChanged: (double v) {
                store.gridSize = v.round();
                setState(() {});
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Default length unit (Convert tab)'),
            subtitle: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<String>>[
                ButtonSegment<String>(value: 'mm', label: Text('mm')),
                ButtonSegment<String>(value: 'cm', label: Text('cm')),
                ButtonSegment<String>(value: 'in', label: Text('in')),
              ],
              selected: <String>{store.defaultLengthUnit},
              onSelectionChanged: (Set<String> s) {
                if (s.isEmpty) return;
                store.defaultLengthUnit = s.first;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('Decimal places (conversion display)'),
            subtitle: Slider(
              value: store.decimalPlaces.toDouble(),
              min: 0,
              max: 3,
              divisions: 3,
              label: '${store.decimalPlaces}',
              onChanged: (double v) {
                store.decimalPlaces = v.round();
                setState(() {});
              },
            ),
          ),
          const Divider(),
          FilledButton.tonal(
            onPressed: () {
              _confirmPurge(context, store);
            },
            child: const Text('Erase all saved data'),
          ),
          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Gauge Grid stores your boards on device only. Remote config (remote_url) can steer shell routing when you host JSON on your endpoint.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _confirmPurge(BuildContext c, GaugeStore store) {
    showDialog<void>(
      context: c,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Erase all data?'),
        content: const Text('Live grid, saved boards, and settings in this app are removed.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              store.eraseAllLocalData();
              Navigator.of(ctx).pop();
              if (c.mounted) {
                Navigator.of(c).pop();
                ScaffoldMessenger.of(
                  c,
                ).showSnackBar(const SnackBar(content: Text('All local data erased')));
              }
            },
            child: const Text('Erase'),
          ),
        ],
      ),
    );
  }
}

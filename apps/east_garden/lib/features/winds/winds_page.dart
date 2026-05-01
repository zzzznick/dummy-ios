import 'package:flutter/material.dart';

import '../../app/settings/east_settings.dart';
import '../../app/settings/east_settings_controller.dart';

class WindsPage extends StatelessWidget {
  const WindsPage({super.key, required this.settings});

  final EastSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = settings.value;
        final seatEn = _defaultSeatEnglish(s.defaultSeatWind);
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: <Widget>[
            if (s.showSeatWindRibbon) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.flag_rounded, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Seat compass',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your default seat is $seatEn. Use it as a mental anchor when reading wind cards.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text('Round winds', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Round wind is the story of the table. Seat wind is where you sit. Both matter when you reason about discards.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _windCard(
              context,
              title: 'East · dealer seat',
              body:
                  'East holds the first draw privilege in most rule sets. When you mirror East in sketches, you are marking who opened the wall.',
            ),
            _windCard(
              context,
              title: 'South · left neighbor',
              body:
                  'South sits left of East in compass order. Use it to rehearse passing tension across the table.',
            ),
            _windCard(
              context,
              title: 'West · across',
              body:
                  'West faces East head-on. Great for visualizing two-way threats when you plan safe exits.',
            ),
            _windCard(
              context,
              title: 'North · right neighbor',
              body:
                  'North completes the ring. Pair it with seat ribbons to remember who just picked from the wall.',
            ),
          ],
        );
      },
    );
  }

  String _defaultSeatEnglish(DefaultSeatWind w) {
    return switch (w) {
      DefaultSeatWind.east => 'East',
      DefaultSeatWind.south => 'South',
      DefaultSeatWind.west => 'West',
      DefaultSeatWind.north => 'North',
    };
  }

  Widget _windCard(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

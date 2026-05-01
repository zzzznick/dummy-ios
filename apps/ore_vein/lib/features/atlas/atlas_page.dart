import 'package:flutter/material.dart';

import '../../models/mineral_ref.dart';

class AtlasPage extends StatefulWidget {
  const AtlasPage({super.key});

  @override
  State<AtlasPage> createState() => _AtlasPageState();
}

class _AtlasPageState extends State<AtlasPage> {
  final TextEditingController _q = TextEditingController();
  String _strip = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = MineralRef.catalog
        .where(
          (m) =>
              _strip.isEmpty ||
              m.commonName.toLowerCase().contains(_strip) ||
              m.key.contains(_strip),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _q,
            onChanged: (v) => setState(() => _strip = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              labelText: 'Filter atlas',
              hintText: 'Try quartz or pyrite',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'Nothing matches that string yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = list[i];
                    return Card(
                      child: ListTile(
                        title: Text(m.commonName),
                        subtitle: Text(
                          'Mohs ${m.mohs} · ${_shortStreak(m.streakDescription)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: CircleAvatar(backgroundColor: Color(m.hexSample)),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(m.commonName, style: Theme.of(context).textTheme.titleLarge),
                                  const SizedBox(height: 12),
                                  Text(m.quickFact),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Streak: ${m.streakDescription}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static String _shortStreak(String s) {
    final t = s.split('/').first.trim();
    return t.length > 28 ? '${t.substring(0, 25)}…' : t;
  }
}

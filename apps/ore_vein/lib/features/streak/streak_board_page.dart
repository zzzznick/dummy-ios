import 'package:flutter/material.dart';

import '../../models/mineral_ref.dart';

class StreakBoardPage extends StatelessWidget {
  const StreakBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MineralRef.catalog;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 128,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Color(m.hexSample),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      m.commonName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            shadows: <Shadow>[
                              const Shadow(blurRadius: 6, color: Colors.black54),
                            ],
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Text(
                    'Streak: ${m.streakDescription}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

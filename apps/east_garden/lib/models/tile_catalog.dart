abstract final class TileCatalog {
  static const List<String> man = <String>[
    'm1', 'm2', 'm3', 'm4', 'm5', 'm6', 'm7', 'm8', 'm9',
  ];
  static const List<String> pin = <String>[
    'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9',
  ];
  static const List<String> sou = <String>[
    's1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9',
  ];
  static const List<String> winds = <String>['ew', 'sw', 'ww', 'nw'];
  static const List<String> dragons = <String>['wd', 'gd', 'rd'];

  static List<String> get all => <String>[...man, ...pin, ...sou, ...winds, ...dragons];

  static String face(String id) {
    if (id.startsWith('m')) return '${id.substring(1)}m';
    if (id.startsWith('p')) return '${id.substring(1)}p';
    if (id.startsWith('s')) return '${id.substring(1)}s';
    return switch (id) {
      'ew' => 'East',
      'sw' => 'South',
      'ww' => 'West',
      'nw' => 'North',
      'wd' => 'White',
      'gd' => 'Green',
      'rd' => 'Red',
      _ => id,
    };
  }

  /// Short roman syllable for cramped chips when honors use soft weight.
  static String syllable(String id) {
    return switch (id) {
      'ew' => 'Ea',
      'sw' => 'So',
      'ww' => 'We',
      'nw' => 'No',
      'wd' => 'Wh',
      'gd' => 'Gr',
      'rd' => 'Re',
      _ => face(id),
    };
  }

  static bool isHonor(String id) => winds.contains(id) || dragons.contains(id);
}

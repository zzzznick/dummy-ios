class MineralRef {
  const MineralRef({
    required this.key,
    required this.commonName,
    required this.mohs,
    required this.streakDescription,
    required this.hexSample,
    required this.quickFact,
  });

  final String key;
  final String commonName;

  /// Mohs hardness 1–10 scale reference.
  final double mohs;
  final String streakDescription;

  /// Approximate swatch for UI (not spectroscopy-grade).
  final int hexSample;
  final String quickFact;

  static List<MineralRef> get catalog => List<MineralRef>.unmodifiable(_all);

  static MineralRef? byKey(String key) {
    for (final m in _all) {
      if (m.key == key) return m;
    }
    return null;
  }
}

/// Curated textbook-style entries for rehearsal only (not assay reports).
const List<MineralRef> _all = <MineralRef>[
  MineralRef(
    key: 'quartz',
    commonName: 'Quartz',
    mohs: 7,
    streakDescription: 'White / none visually',
    hexSample: 0xFFD7CCC8,
    quickFact: 'Scratches glass and leaves a brittle conchoidal snap when broken.',
  ),
  MineralRef(
    key: 'calcite',
    commonName: 'Calcite',
    mohs: 3,
    streakDescription: 'White',
    hexSample: 0xFFFFF8E7,
    quickFact: 'Reacts vividly with mild acid in the field.',
  ),
  MineralRef(
    key: 'pyrite',
    commonName: 'Pyrite',
    mohs: 6.5,
    streakDescription: 'Green-black',
    hexSample: 0xFF757575,
    quickFact: '"Fool\'s gold" flashes brassy but streak is darker.',
  ),
  MineralRef(
    key: 'hematite',
    commonName: 'Hematite',
    mohs: 5.5,
    streakDescription: 'Red-brown',
    hexSample: 0xFFA1887F,
    quickFact: 'Streak separates it from softer micas at a glance.',
  ),
  MineralRef(
    key: 'feldspar',
    commonName: 'Orthoclase feldspar',
    mohs: 6,
    streakDescription: 'White',
    hexSample: 0xFFFFF59D,
    quickFact: 'Two-direction cleavage gives tile-like breakage.',
  ),
  MineralRef(
    key: 'talc',
    commonName: 'Talc',
    mohs: 1,
    streakDescription: 'White / greasy sheen',
    hexSample: 0xFFFFFDE7,
    quickFact: 'Softest baseline on the ordinal scale.',
  ),
  MineralRef(
    key: 'corundum',
    commonName: 'Corundum',
    mohs: 9,
    streakDescription: 'White',
    hexSample: 0xFFB0BEC5,
    quickFact: 'Sapphire/ruby families share this lattice toughness.',
  ),
  MineralRef(
    key: 'galena',
    commonName: 'Galena',
    mohs: 2.5,
    streakDescription: 'Lead gray',
    hexSample: 0xFF9E9E9E,
    quickFact: 'Cubic cleavage snaps into little boxes.',
  ),
];

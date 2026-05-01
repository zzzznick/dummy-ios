import 'dart:ui';

/// How the studio lattice emphasizes motion.
enum LatticeVisualMode {
  crossings,
  layers,
}

/// Default musical grid when adding a groove from settings flow.
enum StarterGridFlavor {
  fourThree,
  threeTwo,
  euclideanSeven,
}

class AppSettings {
  const AppSettings({
    required this.seedColor,
    required this.visualMode,
    required this.defaultBpmForNewGroove,
    required this.layerCountDefault,
    required this.gridFlavor,
    required this.showBeatGlow,
  });

  final Color seedColor;
  final LatticeVisualMode visualMode;
  final int defaultBpmForNewGroove;
  /// Number of rhythmic voices when spawning a sketch (3–6).
  final int layerCountDefault;
  final StarterGridFlavor gridFlavor;
  final bool showBeatGlow;

  static const AppSettings defaults = AppSettings(
    seedColor: Color(0xFF0F766E),
    visualMode: LatticeVisualMode.crossings,
    defaultBpmForNewGroove: 116,
    layerCountDefault: 4,
    gridFlavor: StarterGridFlavor.fourThree,
    showBeatGlow: true,
  );

  AppSettings copyWith({
    Color? seedColor,
    LatticeVisualMode? visualMode,
    int? defaultBpmForNewGroove,
    int? layerCountDefault,
    StarterGridFlavor? gridFlavor,
    bool? showBeatGlow,
  }) {
    return AppSettings(
      seedColor: seedColor ?? this.seedColor,
      visualMode: visualMode ?? this.visualMode,
      defaultBpmForNewGroove: defaultBpmForNewGroove ?? this.defaultBpmForNewGroove,
      layerCountDefault: layerCountDefault ?? this.layerCountDefault,
      gridFlavor: gridFlavor ?? this.gridFlavor,
      showBeatGlow: showBeatGlow ?? this.showBeatGlow,
    );
  }
}

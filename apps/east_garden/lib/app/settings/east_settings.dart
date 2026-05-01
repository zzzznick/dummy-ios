import 'dart:ui';

/// Compass seat markers used when spawning table sketches from settings.
enum DefaultSeatWind { east, south, west, north }

/// How oversized honor glyphs feel on sketch chips.
enum HonorGlyphWeight { soft, vivid }

class EastSettings {
  const EastSettings({
    required this.seedColor,
    required this.defaultSeatWind,
    required this.chipComfort,
    required this.bloomPresetMinutes,
    required this.showSeatWindRibbon,
    required this.honorGlyphWeight,
  });

  final Color seedColor;
  final DefaultSeatWind defaultSeatWind;

  /// 0.82–1.12 tile chip scale multiplier in sketch surfaces.
  final double chipComfort;
  final int bloomPresetMinutes;
  final bool showSeatWindRibbon;
  final HonorGlyphWeight honorGlyphWeight;

  static const EastSettings defaults = EastSettings(
    seedColor: Color(0xFFEC407A),
    defaultSeatWind: DefaultSeatWind.east,
    chipComfort: 0.98,
    bloomPresetMinutes: 8,
    showSeatWindRibbon: true,
    honorGlyphWeight: HonorGlyphWeight.soft,
  );

  EastSettings copyWith({
    Color? seedColor,
    DefaultSeatWind? defaultSeatWind,
    double? chipComfort,
    int? bloomPresetMinutes,
    bool? showSeatWindRibbon,
    HonorGlyphWeight? honorGlyphWeight,
  }) {
    return EastSettings(
      seedColor: seedColor ?? this.seedColor,
      defaultSeatWind: defaultSeatWind ?? this.defaultSeatWind,
      chipComfort: chipComfort ?? this.chipComfort,
      bloomPresetMinutes: bloomPresetMinutes ?? this.bloomPresetMinutes,
      showSeatWindRibbon: showSeatWindRibbon ?? this.showSeatWindRibbon,
      honorGlyphWeight: honorGlyphWeight ?? this.honorGlyphWeight,
    );
  }
}

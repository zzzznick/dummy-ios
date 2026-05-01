import 'dart:ui';

enum VaultCardDensity { relaxed, compact }

class OreSettings {
  const OreSettings({
    required this.seedColor,
    required this.fieldPingsEnabled,
    required this.mohsCoachBias,
    required this.vaultDensity,
    required this.kitHandLens,
    required this.kitStreakPlate,
    required this.kitMagnet,
    required this.kitScale,
    required this.kitGoggles,
  });

  final Color seedColor;
  final bool fieldPingsEnabled;

  /// 0 = sparse hints, 1 = verbose coaching copy on Mohs tab.
  final double mohsCoachBias;
  final VaultCardDensity vaultDensity;

  final bool kitHandLens;
  final bool kitStreakPlate;
  final bool kitMagnet;
  final bool kitScale;
  final bool kitGoggles;

  static const OreSettings defaults = OreSettings(
    seedColor: Color(0xFF00695C),
    fieldPingsEnabled: true,
    mohsCoachBias: 0.55,
    vaultDensity: VaultCardDensity.relaxed,
    kitHandLens: true,
    kitStreakPlate: true,
    kitMagnet: false,
    kitScale: false,
    kitGoggles: true,
  );

  OreSettings copyWith({
    Color? seedColor,
    bool? fieldPingsEnabled,
    double? mohsCoachBias,
    VaultCardDensity? vaultDensity,
    bool? kitHandLens,
    bool? kitStreakPlate,
    bool? kitMagnet,
    bool? kitScale,
    bool? kitGoggles,
  }) {
    return OreSettings(
      seedColor: seedColor ?? this.seedColor,
      fieldPingsEnabled: fieldPingsEnabled ?? this.fieldPingsEnabled,
      mohsCoachBias: mohsCoachBias ?? this.mohsCoachBias,
      vaultDensity: vaultDensity ?? this.vaultDensity,
      kitHandLens: kitHandLens ?? this.kitHandLens,
      kitStreakPlate: kitStreakPlate ?? this.kitStreakPlate,
      kitMagnet: kitMagnet ?? this.kitMagnet,
      kitScale: kitScale ?? this.kitScale,
      kitGoggles: kitGoggles ?? this.kitGoggles,
    );
  }
}

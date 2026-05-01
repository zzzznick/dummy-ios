import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'ore_settings.dart';

class OreSettingsStore {
  static const _kSeed = 'ov_seed';
  static const _kPing = 'ov_ping';
  static const _kCoach = 'ov_coach';
  static const _kVault = 'ov_vault_density';
  static const _kKL = 'ov_kit_lens';
  static const _kKS = 'ov_kit_streak';
  static const _kKM = 'ov_kit_mag';
  static const _kKSc = 'ov_kit_scale';
  static const _kKG = 'ov_kit_goggles';

  Future<OreSettings> read() async {
    final p = await SharedPreferences.getInstance();
    final seed = p.getInt(_kSeed);
    final ping = p.getBool(_kPing);
    final coach = p.getDouble(_kCoach);
    final vd = p.getInt(_kVault);

    final d0 = OreSettings.defaults;
    VaultCardDensity dens = d0.vaultDensity;
    if (vd != null && vd >= 0 && vd < VaultCardDensity.values.length) {
      dens = VaultCardDensity.values[vd];
    }

    return d0.copyWith(
      seedColor: seed == null ? null : Color(seed),
      fieldPingsEnabled: ping ?? d0.fieldPingsEnabled,
      mohsCoachBias: coach ?? d0.mohsCoachBias,
      vaultDensity: dens,
      kitHandLens: p.getBool(_kKL) ?? d0.kitHandLens,
      kitStreakPlate: p.getBool(_kKS) ?? d0.kitStreakPlate,
      kitMagnet: p.getBool(_kKM) ?? d0.kitMagnet,
      kitScale: p.getBool(_kKSc) ?? d0.kitScale,
      kitGoggles: p.getBool(_kKG) ?? d0.kitGoggles,
    );
  }

  Future<void> write(OreSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSeed, s.seedColor.toARGB32());
    await p.setBool(_kPing, s.fieldPingsEnabled);
    await p.setDouble(_kCoach, s.mohsCoachBias.clamp(0.0, 1.0));
    await p.setInt(_kVault, s.vaultDensity.index);
    await p.setBool(_kKL, s.kitHandLens);
    await p.setBool(_kKS, s.kitStreakPlate);
    await p.setBool(_kKM, s.kitMagnet);
    await p.setBool(_kKSc, s.kitScale);
    await p.setBool(_kKG, s.kitGoggles);
  }
}

class FieldDeskPersistence {
  static const _kNotes = 'ov_field_notes';

  Future<List<Map<String, dynamic>>> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotes);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final d = jsonDecode(raw);
      if (d is List) return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<void> saveRaw(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNotes, jsonEncode(rows));
  }
}

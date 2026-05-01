import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'east_settings.dart';

class EastSettingsStore {
  static const _kSeed = 'eg_seed';
  static const _kSeat = 'eg_seat_wind';
  static const _kChip = 'eg_chip_scale';
  static const _kBloom = 'eg_bloom_min';
  static const _kRibbon = 'eg_seat_ribbon';
  static const _kHonor = 'eg_honor_weight';

  Future<EastSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    final seedInt = prefs.getInt(_kSeed);
    final seat = prefs.getInt(_kSeat);
    final chip = prefs.getDouble(_kChip);
    final bloom = prefs.getInt(_kBloom);
    final ribbon = prefs.getBool(_kRibbon);
    final honor = prefs.getInt(_kHonor);

    final seatWind = (seat == null || seat < 0 || seat >= DefaultSeatWind.values.length)
        ? null
        : DefaultSeatWind.values[seat];

    final honorW =
        (honor == null || honor < 0 || honor >= HonorGlyphWeight.values.length)
            ? null
            : HonorGlyphWeight.values[honor];

    return EastSettings.defaults.copyWith(
      seedColor: seedInt == null ? null : Color(seedInt),
      defaultSeatWind: seatWind,
      chipComfort: chip,
      bloomPresetMinutes: bloom,
      showSeatWindRibbon: ribbon,
      honorGlyphWeight: honorW,
    );
  }

  Future<void> write(EastSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeed, s.seedColor.toARGB32());
    await prefs.setInt(_kSeat, s.defaultSeatWind.index);
    await prefs.setDouble(_kChip, s.chipComfort.clamp(0.82, 1.14));
    await prefs.setInt(_kBloom, s.bloomPresetMinutes.clamp(3, 25));
    await prefs.setBool(_kRibbon, s.showSeatWindRibbon);
    await prefs.setInt(_kHonor, s.honorGlyphWeight.index);
  }
}

class HandLibraryPersistence {
  static const _k = 'eg_hand_manifest';

  Future<List<Map<String, dynamic>>> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final d = jsonDecode(raw);
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  Future<void> saveRaw(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k, jsonEncode(rows));
  }
}

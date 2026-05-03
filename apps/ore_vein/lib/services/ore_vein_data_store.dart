import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/checklist.dart';
import '../models/saved_swatch.dart';

class OreVeinDataStore extends ChangeNotifier {
  static const _k = 'ore_vein_data_v1';

  final List<Checklist> checklists = <Checklist>[];
  final List<SavedSwatch> swatches = <SavedSwatch>[];
  int lastTimerSeconds = 300;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.isEmpty) {
      notifyListeners();
      return;
    }
    try {
      final d = jsonDecode(raw);
      if (d is Map<String, dynamic>) {
        lastTimerSeconds = (d['timer'] is int) ? d['timer'] as int : 300;
        checklists
          ..clear()
          ..addAll(
            (d['lists'] is List)
                ? (d['lists'] as List<dynamic>)
                    .whereType<Map>()
                    .map((e) => Checklist.fromJson(e.cast<String, dynamic>()))
                    .toList()
                : <Checklist>[],
          );
        swatches
          ..clear()
          ..addAll(
            (d['sw'] is List)
                ? (d['sw'] as List<dynamic>)
                    .whereType<Map>()
                    .map((e) => SavedSwatch.fromJson(e.cast<String, dynamic>()))
                    .toList()
                : <SavedSwatch>[],
          );
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'timer': lastTimerSeconds,
      'lists': checklists.map((e) => e.toJson()).toList(),
      'sw': swatches.map((e) => e.toJson()).toList(),
    };
    await p.setString(_k, jsonEncode(payload));
    notifyListeners();
  }

  Future<void> setLastTimerSeconds(int s) async {
    lastTimerSeconds = s.clamp(15, 3600);
    await _persist();
  }

  Future<void> upsertChecklist(Checklist c) async {
    final i = checklists.indexWhere((e) => e.id == c.id);
    if (i < 0) {
      checklists.add(c);
    } else {
      checklists[i] = c;
    }
    await _persist();
  }

  Future<void> removeChecklist(String id) async {
    checklists.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> addSwatch(SavedSwatch s) async {
    swatches.insert(0, s);
    await _persist();
  }

  Future<void> updateSwatch(SavedSwatch s) async {
    final i = swatches.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      swatches[i] = s;
      await _persist();
    }
  }

  Future<void> removeSwatch(String id) async {
    swatches.removeWhere((e) => e.id == id);
    await _persist();
  }
}

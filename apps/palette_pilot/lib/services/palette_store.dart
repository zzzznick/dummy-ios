import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/palette.dart';

class PaletteStore extends ChangeNotifier {
  static const _kPalettes = 'pp_palettes_v1';

  final Random _random = Random();

  bool _loaded = false;
  bool get loaded => _loaded;

  final List<Palette> _palettes = [];
  List<Palette> get palettes => List.unmodifiable(_palettes);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPalettes);
    if (raw != null && raw.trim().isNotEmpty) {
      _palettes
        ..clear()
        ..addAll(decodePalettes(raw));
      _palettes.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    } else {
      _palettes
        ..clear()
        ..addAll(_seedData());
    }
    _loaded = true;
    notifyListeners();
    await _save();
  }

  Palette? byId(String id) {
    for (final p in _palettes) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> add(Palette palette) async {
    _palettes.insert(0, palette);
    notifyListeners();
    await _save();
  }

  Future<void> update(Palette palette) async {
    final idx = _palettes.indexWhere((p) => p.id == palette.id);
    if (idx < 0) return;
    _palettes[idx] = palette;
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _palettes.removeWhere((p) => p.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> reset() async {
    _palettes
      ..clear()
      ..addAll(_seedData());
    notifyListeners();
    await _save();
  }

  List<Palette> _seedData() {
    return [
      Palette.seed('Neon Dusk', random: _random),
      Palette.seed('Soft Clay', random: _random),
      Palette.seed('Ocean Glass', random: _random),
    ];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPalettes, encodePalettes(_palettes));
  }
}


import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/groove_pattern.dart';

class GrooveStore extends ChangeNotifier {
  static const _kKey = 'gl_grooves_v1';

  final List<GroovePattern> _items = <GroovePattern>[];
  String? _activeId;
  bool _loaded = false;

  List<GroovePattern> get items => List<GroovePattern>.unmodifiable(_items);
  bool get loaded => _loaded;
  GroovePattern? get active {
    for (final g in _items) {
      if (g.id == _activeId) return g;
    }
    return _items.isEmpty ? null : _items.first;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    _items.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw);
        if (list is List) {
          for (final e in list) {
            if (e is Map) {
              _items.add(GroovePattern.fromJson(e.cast<String, dynamic>()));
            }
          }
        }
      } catch (_) {}
    }
    if (_items.isEmpty) {
      _seedDefaults();
    }
    _activeId ??= _items.first.id;
    _loaded = true;
    notifyListeners();
  }

  void _seedDefaults() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _items.addAll(<GroovePattern>[
      GroovePattern(
        id: 'g-${now}a',
        name: 'Crossing 3 × 4',
        bpm: 108,
        steps: <int>[3, 4],
        updatedMillis: now,
      ),
      GroovePattern(
        id: 'g-${now}b',
        name: 'Five over four',
        bpm: 92,
        steps: <int>[5, 4],
        updatedMillis: now + 1,
      ),
    ]);
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, enc);
  }

  void setActive(String id) {
    _activeId = id;
    notifyListeners();
  }

  Future<void> upsert(GroovePattern g) async {
    final idx = _items.indexWhere((e) => e.id == g.id);
    if (idx >= 0) {
      _items[idx] = g;
    } else {
      _items.add(g);
    }
    _activeId = g.id;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    if (_activeId == id) {
      _activeId = _items.isEmpty ? null : _items.first.id;
    }
    notifyListeners();
    await _persist();
  }
}

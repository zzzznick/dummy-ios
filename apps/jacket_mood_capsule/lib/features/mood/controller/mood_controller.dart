import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/mood_entry.dart';
import '../storage/mood_store.dart';

class MoodController extends ChangeNotifier {
  MoodController({MoodStore? store}) : _store = store ?? MoodStore();

  final MoodStore _store;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  final List<MoodEntry> _entries = <MoodEntry>[];
  List<MoodEntry> get entries => List<MoodEntry>.unmodifiable(_entries);

  Future<void> load() async {
    if (_loaded) return;
    final loaded = await _store.load();
    _entries
      ..clear()
      ..addAll(loaded);
    _sort();
    _loaded = true;
    notifyListeners();
  }

  Future<void> add({
    required int mood,
    required String note,
    required List<String> tags,
    required bool isPinned,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _makeId(now);
    _entries.add(
      MoodEntry(
        id: id,
        createdAtMs: now,
        mood: mood,
        note: note,
        tags: tags,
        isPinned: isPinned,
      ),
    );
    _sort();
    notifyListeners();
    await _store.save(_entries);
  }

  Future<void> update(String id, MoodEntry updated) async {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    _entries[idx] = updated;
    _sort();
    notifyListeners();
    await _store.save(_entries);
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _store.save(_entries);
  }

  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    await _store.clear();
  }

  void _sort() {
    _entries.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.createdAtMs.compareTo(a.createdAtMs);
    });
  }

  String exportJson() {
    return jsonEncode(_entries.map((e) => e.toJson()).toList(growable: false));
  }

  String _makeId(int seed) {
    final r = Random(seed);
    final suffix = List<int>.generate(6, (_) => r.nextInt(36))
        .map((n) => n.toRadixString(36))
        .join();
    return 'm$seed$suffix';
  }

  // Export format is stable JSON array (UTF-8 safe).
}


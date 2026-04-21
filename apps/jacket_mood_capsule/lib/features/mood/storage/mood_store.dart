import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

class MoodStore {
  static const _kEntries = 'mood.entries.v1';

  Future<List<MoodEntry>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kEntries);
    if (raw == null || raw.trim().isEmpty) return <MoodEntry>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <MoodEntry>[];
      final out = <MoodEntry>[];
      for (final v in decoded) {
        if (v is Map) {
          out.add(MoodEntry.fromJson(Map<String, dynamic>.from(v)));
        }
      }
      return out;
    } catch (_) {
      return <MoodEntry>[];
    }
  }

  Future<void> save(List<MoodEntry> entries) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList(growable: false));
    await sp.setString(_kEntries, raw);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kEntries);
  }
}


import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class AppSettingsStore {
  static const _k = 'ore_vein_settings_v1';

  Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.isEmpty) return AppSettings.defaults;
    try {
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic>) {
        return AppSettings.fromJson(m);
      }
    } catch (_) {}
    return AppSettings.defaults;
  }

  Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(s.toJson()));
  }
}

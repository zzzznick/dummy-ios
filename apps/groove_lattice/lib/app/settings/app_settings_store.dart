import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class AppSettingsStore {
  static const _kSeed = 'gl_seed_color';
  static const _kVisualMode = 'gl_visual_mode';
  static const _kDefBpm = 'gl_default_bpm';
  static const _kLayers = 'gl_layer_default';
  static const _kGridFlavor = 'gl_grid_flavor';
  static const _kGlow = 'gl_show_beat_glow';

  Future<AppSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    final seedInt = prefs.getInt(_kSeed);
    final visualIdx = prefs.getInt(_kVisualMode);
    final bpm = prefs.getInt(_kDefBpm);
    final layers = prefs.getInt(_kLayers);
    final gridIdx = prefs.getInt(_kGridFlavor);
    final glow = prefs.getBool(_kGlow);

    return AppSettings.defaults.copyWith(
      seedColor: seedInt == null ? null : Color(seedInt),
      visualMode: (visualIdx == null ||
              visualIdx < 0 ||
              visualIdx >= LatticeVisualMode.values.length)
          ? null
          : LatticeVisualMode.values[visualIdx],
      defaultBpmForNewGroove: bpm,
      layerCountDefault: layers,
      gridFlavor: (gridIdx == null || gridIdx < 0 || gridIdx >= StarterGridFlavor.values.length)
          ? null
          : StarterGridFlavor.values[gridIdx],
      showBeatGlow: glow,
    );
  }

  Future<void> write(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeed, settings.seedColor.toARGB32());
    await prefs.setInt(_kVisualMode, settings.visualMode.index);
    await prefs.setInt(_kDefBpm, settings.defaultBpmForNewGroove.clamp(40, 220));
    await prefs.setInt(_kLayers, settings.layerCountDefault.clamp(3, 6));
    await prefs.setInt(_kGridFlavor, settings.gridFlavor.index);
    await prefs.setBool(_kGlow, settings.showBeatGlow);
  }
}

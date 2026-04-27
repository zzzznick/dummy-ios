import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

class AppSettingsStore {
  static const _kSeed = 'pp_seed_color';
  static const _kFormat = 'pp_color_format';
  static const _kContrast = 'pp_contrast_target';
  static const _kPadding = 'pp_export_padding';

  Future<AppSettings> read() async {
    final prefs = await SharedPreferences.getInstance();
    final seedInt = prefs.getInt(_kSeed);
    final formatIdx = prefs.getInt(_kFormat);
    final contrastIdx = prefs.getInt(_kContrast);
    final padding = prefs.getInt(_kPadding);

    return AppSettings.defaults.copyWith(
      seedColor: seedInt == null ? null : Color(seedInt),
      colorFormat: (formatIdx == null || formatIdx < 0 || formatIdx >= ColorFormat.values.length)
          ? null
          : ColorFormat.values[formatIdx],
      contrastTarget:
          (contrastIdx == null || contrastIdx < 0 || contrastIdx >= ContrastTarget.values.length)
              ? null
              : ContrastTarget.values[contrastIdx],
      exportPadding: padding,
    );
  }

  Future<void> write(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSeed, settings.seedColor.value);
    await prefs.setInt(_kFormat, settings.colorFormat.index);
    await prefs.setInt(_kContrast, settings.contrastTarget.index);
    await prefs.setInt(_kPadding, settings.exportPadding);
  }
}


import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

abstract final class OreVeinTheme {
  static ThemeData build({required AppSettings settings}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: settings.seedColor, brightness: Brightness.light),
    );
    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: base.colorScheme.primaryContainer,
      ),
    );
  }
}

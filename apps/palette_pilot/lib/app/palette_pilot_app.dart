import 'package:flutter/material.dart';
import 'package:app_common/app_common.dart';

import '../boot/boot_page.dart';
import 'settings/app_settings_controller.dart';
import 'settings/app_settings_store.dart';
import 'theme/palette_theme.dart';

class PalettePilotApp extends StatefulWidget {
  const PalettePilotApp({super.key});

  @override
  State<PalettePilotApp> createState() => _PalettePilotAppState();
}

class _PalettePilotAppState extends State<PalettePilotApp> with WidgetsBindingObserver {
  late final AppSettingsController _settings;
  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings = AppSettingsController(AppSettingsStore())..load();
    _att.requestIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _att.requestIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final theme = PaletteTheme.build(seed: _settings.value.seedColor);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Palette Pilot',
          theme: theme,
          home: BootPage(settings: _settings),
        );
      },
    );
  }
}


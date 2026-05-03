import 'package:flutter/material.dart';

import '../_qkzmt/_qkzmt.dart';
import '../services/ore_vein_data_store.dart';
import '../shell/ore_vein_shell.dart';
import 'att_service.dart';
import 'settings/app_settings_controller.dart';
import 'settings/app_settings_store.dart';
import 'theme/ore_vein_theme.dart';

class OreVeinApp extends StatefulWidget {
  const OreVeinApp({super.key});

  @override
  State<OreVeinApp> createState() => _OreVeinAppState();
}

class _OreVeinAppState extends State<OreVeinApp> with WidgetsBindingObserver {
  late final AppSettingsController _settings;
  late final OreVeinDataStore _data;
  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings = AppSettingsController(AppSettingsStore())..load();
    _data = OreVeinDataStore()..load();
    _att.requestIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    _data.dispose();
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ore Vein',
          theme: OreVeinTheme.build(settings: _settings.value),
          home: Qkzmt0(
            a: (_) => OreVeinShell(settings: _settings, data: _data),
          ),
        );
      },
    );
  }
}

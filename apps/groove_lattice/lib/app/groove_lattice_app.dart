import 'dart:async';

import 'package:flutter/material.dart';

import '../_krmwt/_krmwt.dart';
import '../services/groove_store.dart';
import '../shell/groove_lattice_shell.dart';
import 'att_service.dart';
import 'settings/app_settings_controller.dart';
import 'settings/app_settings_store.dart';
import 'theme/groove_theme.dart';

class GrooveLatticeApp extends StatefulWidget {
  const GrooveLatticeApp({super.key});

  @override
  State<GrooveLatticeApp> createState() => _GrooveLatticeAppState();
}

class _GrooveLatticeAppState extends State<GrooveLatticeApp> with WidgetsBindingObserver {
  final AppSettingsStore _settingsStore = AppSettingsStore();
  late final AppSettingsController _settings = AppSettingsController(_settingsStore);
  final GrooveStore _grooves = GrooveStore();
  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_settings.load());
    unawaited(_grooves.load());
    unawaited(_att.requestIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    _grooves.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_att.requestIfNeeded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final theme = GrooveTheme.build(seed: _settings.value.seedColor);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Groove Lattice',
          theme: theme,
          home: Krmwt0(
            a: (_) => GrooveLatticeShell(
              settings: _settings,
              store: _grooves,
            ),
          ),
        );
      },
    );
  }
}

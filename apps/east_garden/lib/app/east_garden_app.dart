import 'dart:async';

import 'package:flutter/material.dart';

import '../_xvhrt/_xvhrt.dart';
import '../services/hand_library_store.dart';
import '../shell/east_garden_shell.dart';
import 'att_service.dart';
import 'settings/east_settings_controller.dart';
import 'settings/east_settings_store.dart';
import 'theme/east_garden_theme.dart';

class EastGardenApp extends StatefulWidget {
  const EastGardenApp({super.key});

  @override
  State<EastGardenApp> createState() => _EastGardenAppState();
}

class _EastGardenAppState extends State<EastGardenApp> with WidgetsBindingObserver {
  final EastSettingsStore _settingsStore = EastSettingsStore();
  final HandLibraryPersistence _handPersistence = HandLibraryPersistence();

  late final EastSettingsController _settings = EastSettingsController(_settingsStore);
  late final HandLibraryStore _library = HandLibraryStore(_handPersistence);

  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_settings.load());
    unawaited(_library.load());
    unawaited(_att.requestIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    _library.dispose();
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
        final theme = EastGardenTheme.build(snapshot: _settings.value);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'East Garden',
          theme: theme,
          home: Xvhrt0(
            a: (_) => EastGardenShell(
              settings: _settings,
              library: _library,
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../_qkzmt/_qkzmt.dart';
import '../services/field_note_store.dart';
import '../shell/ore_vein_shell.dart';
import 'att_service.dart';
import 'settings/ore_settings_controller.dart';
import 'settings/ore_settings_store.dart';
import 'theme/ore_vein_theme.dart';

class OreVeinApp extends StatefulWidget {
  const OreVeinApp({super.key});

  @override
  State<OreVeinApp> createState() => _OreVeinAppState();
}

class _OreVeinAppState extends State<OreVeinApp> with WidgetsBindingObserver {
  final OreSettingsStore _oreStore = OreSettingsStore();
  final FieldDeskPersistence _deskPersistence = FieldDeskPersistence();

  late final OreSettingsController _settings = OreSettingsController(_oreStore);
  late final FieldNoteStore _notes = FieldNoteStore(_deskPersistence);

  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_settings.load());
    unawaited(_notes.load());
    unawaited(_att.requestIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.dispose();
    _notes.dispose();
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ore Vein',
          theme: OreVeinTheme.build(snapshot: _settings.value),
          home: Qkzmt0(
            a: (_) => OreVeinShell(
              settings: _settings,
              notes: _notes,
            ),
          ),
        );
      },
    );
  }
}

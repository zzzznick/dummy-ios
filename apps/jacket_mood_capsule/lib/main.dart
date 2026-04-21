import 'package:flutter/material.dart';

import 'app/settings/app_settings_controller.dart';
import 'boot/boot_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JacketMoodCapsuleApp());
}

class JacketMoodCapsuleApp extends StatelessWidget {
  const JacketMoodCapsuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppBootstrap();
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final AppSettingsController _settings;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _settings = AppSettingsController();
    _init();
  }

  Future<void> _init() async {
    await _settings.load();
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        final theme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: _settings.seedColor),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mood Capsule',
          theme: theme,
          home: BootPage(
            settings: _settings,
          ),
        );
      },
    );
  }
}

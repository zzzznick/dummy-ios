import 'package:flutter/material.dart';
import 'package:food_app_common/food_app_common.dart';

import '../app/settings/app_settings_controller.dart';
import '../features/mood/pages/mood_home_page.dart';
import 'remote_config_endpoint.dart';
import 'remote_config_keys.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  late final BootCoordinator _coordinator = BootCoordinator(
    remoteConfigClient: RemoteConfigClient(
      endpoint: remoteConfigEndpoint,
      keys: remoteConfigKeys,
    ),
    localHomeBuilder: (_) => MoodHomePage(settings: widget.settings),
    debugLog: (m) => debugPrint(m),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _coordinator.start(context);
    });
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Booting...')));
  }
}


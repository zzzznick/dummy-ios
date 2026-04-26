import 'package:flutter/material.dart';
import 'package:app_common/app_common.dart';

import '../local_tabs/local_tabs_page.dart';
import 'remote_config_keys.dart';

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  static const String _remoteConfigEndpoint =
      'https://69e1e92fb1cb62b9f31779a9.mockapi.io/api1';

  late final BootCoordinator _coordinator = BootCoordinator(
    remoteConfigClient: RemoteConfigClient(
      endpoint: _remoteConfigEndpoint,
      keys: remoteConfigKeys,
    ),
    localHomeBuilder: (_) => const LocalTabsPage(),
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

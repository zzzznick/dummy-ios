import 'package:app_common/app_common.dart';
import 'package:flutter/material.dart';

import 'boot/boot_page.dart';

class GaugeGridApp extends StatefulWidget {
  const GaugeGridApp({super.key});

  @override
  State<GaugeGridApp> createState() => _GaugeGridAppState();
}

class _GaugeGridAppState extends State<GaugeGridApp> with WidgetsBindingObserver {
  final AttService _att = AttService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _att.requestIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D9488),
        brightness: Brightness.light,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gauge Grid',
      theme: theme,
      home: const BootPage(),
    );
  }
}

import 'package:flutter/material.dart';

import 'boot/boot_page.dart';
import 'services/att_service.dart';

class FoodApp extends StatefulWidget {
  const FoodApp({super.key});

  @override
  State<FoodApp> createState() => _FoodAppState();
}

class _FoodAppState extends State<FoodApp> with WidgetsBindingObserver {
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
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    );

    return MaterialApp(
      title: 'ABiteOfMouthFeastBook',
      theme: theme,
      home: const BootPage(),
    );
  }
}

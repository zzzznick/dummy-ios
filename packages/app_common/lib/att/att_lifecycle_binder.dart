import 'package:flutter/widgets.dart';

import 'att_service.dart';

class AttLifecycleBinder with WidgetsBindingObserver {
  AttLifecycleBinder({AttService? attService})
    : _attService = attService ?? AttService();

  final AttService _attService;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _attService.requestIfNeeded();
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _attService.requestIfNeeded();
    }
  }
}


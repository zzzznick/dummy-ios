import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../analytics/analytics_bridge.dart';
import '../local_tabs/local_tabs_page.dart';
import '../models/remote_config.dart';
import '../routing/external_navigator.dart';
import '../services/remote_config_service.dart';
import '../shells/web_shell_one_page.dart';
import '../shells/web_shell_two_page.dart';
import 'boot_decision.dart';

class BootCoordinator {
  BootCoordinator({
    RemoteConfigService? remoteConfigService,
    Connectivity? connectivity,
    ExternalNavigator? externalNavigator,
    AnalyticsBridge? analyticsBridge,
  }) : _remoteConfigService = remoteConfigService ?? RemoteConfigService(),
       _connectivity = connectivity ?? Connectivity(),
       _externalNavigator = externalNavigator ?? const ExternalNavigator(),
       _analyticsBridge = analyticsBridge ?? AnalyticsBridge();

  final RemoteConfigService _remoteConfigService;
  final Connectivity _connectivity;
  final ExternalNavigator _externalNavigator;
  final AnalyticsBridge _analyticsBridge;

  bool _hasEvaluated = false;
  bool _inFlight = false;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  Future<void> start(BuildContext context) async {
    if (_hasEvaluated) return;

    _connSub ??= _connectivity.onConnectivityChanged.listen((_) {
      if (_hasEvaluated) return;
      _tryEvaluate(context);
    });

    await _tryEvaluate(context);
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _connSub = null;
  }

  Future<void> _tryEvaluate(BuildContext context) async {
    if (_hasEvaluated || _inFlight) return;
    _inFlight = true;
    try {
      final item = await _fetchWithBackoff();
      if (!context.mounted) return;

      await _route(context, item);
      _hasEvaluated = true;
      await dispose();
    } finally {
      _inFlight = false;
    }
  }

  Future<RemoteConfigItem?> _fetchWithBackoff() async {
    var delayMs = 500;
    while (true) {
      try {
        return await _remoteConfigService.fetchFirstItem();
      } catch (_) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs = (delayMs * 2).clamp(500, 8000);
      }
    }
  }

  Future<void> _route(BuildContext context, RemoteConfigItem? item) async {
    final decision = BootDecision.decide(item);
    if (decision.type == BootDestinationType.localTabs) {
      _replace(context, const LocalTabsPage());
      return;
    }

    if (item != null) {
      await _analyticsBridge.configure(item);
    }

    switch (decision.type) {
      case BootDestinationType.webShellOne:
        _replace(
          context,
          WebShellOnePage(
            initialUrl: decision.url!,
            config: item!,
            analytics: _analyticsBridge,
            externalNavigator: _externalNavigator,
          ),
        );
        return;
      case BootDestinationType.webShellTwo:
        _replace(
          context,
          WebShellTwoPage(
            initialUrl: decision.url!,
            config: item!,
            analytics: _analyticsBridge,
            externalNavigator: _externalNavigator,
          ),
        );
        return;
      case BootDestinationType.external:
        await _externalNavigator.openExternal(decision.url!);
        _replace(
          context,
          const Scaffold(body: Center(child: Text('Opened externally'))),
        );
        return;
      case BootDestinationType.localTabs:
        _replace(context, const LocalTabsPage());
        return;
    }
  }

  void _replace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }
}

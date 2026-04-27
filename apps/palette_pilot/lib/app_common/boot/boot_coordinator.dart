import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../analytics/analytics_bridge.dart';
import '../remote_config/remote_config.dart';
import '../remote_config/remote_config_client.dart';
import '../routing/external_navigator.dart';
import '../web_shells/web_shell_one_page.dart';
import '../web_shells/web_shell_two_page.dart';
import 'boot_decision.dart';

class BootCoordinator {
  BootCoordinator({
    required RemoteConfigClient remoteConfigClient,
    required WidgetBuilder localHomeBuilder,
    Connectivity? connectivity,
    ExternalNavigator? externalNavigator,
    AnalyticsBridge? analyticsBridge,
    BootDecisionStrategy? decisionStrategy,
    void Function(String message)? debugLog,
  }) : _remoteConfigClient = remoteConfigClient,
       _localHomeBuilder = localHomeBuilder,
       _connectivity = connectivity ?? Connectivity(),
       _externalNavigator = externalNavigator ?? const ExternalNavigator(),
       _analyticsBridge = analyticsBridge ?? AnalyticsBridge(),
       _decisionStrategy = decisionStrategy ?? const DefaultBootDecisionStrategy(),
       _debugLog = debugLog;

  final RemoteConfigClient _remoteConfigClient;
  final WidgetBuilder _localHomeBuilder;
  final Connectivity _connectivity;
  final ExternalNavigator _externalNavigator;
  final AnalyticsBridge _analyticsBridge;
  final BootDecisionStrategy _decisionStrategy;
  final void Function(String message)? _debugLog;

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
        return await _remoteConfigClient.fetchFirstItem();
      } catch (_) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        delayMs = (delayMs * 2).clamp(500, 8000);
      }
    }
  }

  Future<void> _route(BuildContext context, RemoteConfigItem? item) async {
    final decision = _decisionStrategy.decide(item);
    _debugLog?.call(
      '[BootCoordinator] item.url=${item?.url} item.platform=${item?.platform} '
      'item.hasUrl=${item?.hasUrl} decision.type=${decision.type} decision.url=${decision.url}',
    );
    if (decision.type == BootDestinationType.local) {
      _replace(context, _localHomeBuilder(context));
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
      case BootDestinationType.local:
        _replace(context, _localHomeBuilder(context));
        return;
    }
  }

  void _replace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }
}


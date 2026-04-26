import 'dart:convert';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:logger/logger.dart';

import '../remote_config/remote_config.dart';

typedef AnalyticsEventFilter = bool Function(String name, Map<String, dynamic> payload);

class AnalyticsBridge {
  AnalyticsBridge({
    Logger? logger,
    AdjustEnvironment adjustEnvironment = AdjustEnvironment.production,
    Map<String, String>? builtInAdjustTokenMap,
    AnalyticsEventFilter? eventFilter,
  }) : _log = logger ?? Logger(),
       _adjustEnvironment = adjustEnvironment,
       _builtInAdjustTokenMap =
           builtInAdjustTokenMap ??
           const <String, String>{
             // Keep a built-in default map for parity with iOS demo code.
             'test': '{REGISTER_EVENT_TOKEN}',
             'test1': '{REGISTER_EVENT_TOKEN}',
           },
       _eventFilter = eventFilter;

  final Logger _log;
  final AdjustEnvironment _adjustEnvironment;
  final Map<String, String> _builtInAdjustTokenMap;
  final AnalyticsEventFilter? _eventFilter;

  String _eventType = '';
  bool _configured = false;

  AppsflyerSdk? _appsFlyer;
  Map<String, String> _adjustTokenMap = <String, String>{};

  Future<void> configure(RemoteConfigItem config) async {
    if (_configured) return;

    _eventType = config.eventType;
    try {
      if (_eventType == 'af') {
        await _configureAppsFlyer(config);
      } else if (_eventType == 'ad') {
        await _configureAdjust(config);
      }
      _configured = true;
    } catch (e, st) {
      _log.w('Analytics configure failed', error: e, stackTrace: st);
    }
  }

  Future<void> trackEvent(String name, Map<String, dynamic> payload) async {
    if (!_configured) return;
    if (_eventFilter != null && !_eventFilter(name, payload)) return;

    try {
      if (_eventType == 'af') {
        await _trackAppsFlyer(name, payload);
      } else if (_eventType == 'ad') {
        await _trackAdjust(name, payload);
      }
    } catch (e, st) {
      _log.w('trackEvent failed: $name', error: e, stackTrace: st);
    }
  }

  Future<void> _configureAppsFlyer(RemoteConfigItem config) async {
    final options = AppsFlyerOptions(
      afDevKey: config.afKey,
      appId: config.appId,
      showDebug: false,
    );
    final sdk = AppsflyerSdk(options);
    await sdk.initSdk(
      registerConversionDataCallback: false,
      registerOnAppOpenAttributionCallback: false,
      registerOnDeepLinkingCallback: false,
    );
    _appsFlyer = sdk;
    _log.i('AppsFlyer configured');
  }

  Future<void> _configureAdjust(RemoteConfigItem config) async {
    _adjustTokenMap = _buildAdjustTokenMap(config.adEventListRaw);

    final adjustConfig = AdjustConfig(config.adKey, _adjustEnvironment);
    Adjust.initSdk(adjustConfig);
    _log.i('Adjust configured');
  }

  Map<String, String> _buildAdjustTokenMap(String adEventListRaw) {
    final map = <String, String>{..._builtInAdjustTokenMap};

    if (adEventListRaw.trim().isEmpty) return map;
    try {
      final decoded = jsonDecode(adEventListRaw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          final k = entry.key.toString();
          final v = entry.value?.toString() ?? '';
          if (v.isNotEmpty) map[k] = v;
        }
      }
    } catch (_) {
      // Keep defaults if invalid JSON.
    }
    return map;
  }

  Future<void> _trackAppsFlyer(String name, Map<String, dynamic> payload) async {
    final sdk = _appsFlyer;
    if (sdk == null) return;

    // Revenue events follow iOS demo rules.
    if (name == 'firstrecharge' ||
        name == 'recharge' ||
        name == 'withdrawOrderSuccess') {
      final amount = _numFrom(payload['amount'] ?? payload['af_revenue']);
      final currency = (payload['currency'] ?? '').toString();
      if (amount != null && currency.isNotEmpty) {
        final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
        await sdk.logEvent(name, <String, dynamic>{
          'af_revenue': revenue,
          'af_currency': currency,
        });
        return;
      }
    }

    await sdk.logEvent(name, payload);
  }

  Future<void> _trackAdjust(String name, Map<String, dynamic> payload) async {
    final token = _adjustTokenMap[name];
    if (token == null || token.isEmpty) return;

    final event = AdjustEvent(token);

    if (name == 'firstrecharge' ||
        name == 'recharge' ||
        name == 'withdrawOrderSuccess') {
      final amount = _numFrom(payload['amount'] ?? payload['af_revenue']);
      final currency = (payload['currency'] ?? '').toString();
      if (amount != null && currency.isNotEmpty) {
        final revenue = (name == 'withdrawOrderSuccess') ? -amount : amount;
        event.setRevenue(revenue.toDouble(), currency);
      }
    }

    Adjust.trackEvent(event);
  }

  num? _numFrom(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }
}


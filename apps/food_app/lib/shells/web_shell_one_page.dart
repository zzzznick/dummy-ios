import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../analytics/analytics_bridge.dart';
import '../models/remote_config.dart';
import '../routing/external_navigator.dart';
import 'js_message.dart';

class WebShellOnePage extends StatefulWidget {
  const WebShellOnePage({
    super.key,
    required this.initialUrl,
    required this.config,
    required this.analytics,
    required this.externalNavigator,
  });

  final String initialUrl;
  final RemoteConfigItem config;
  final AnalyticsBridge analytics;
  final ExternalNavigator externalNavigator;

  @override
  State<WebShellOnePage> createState() => _WebShellOnePageState();
}

class _WebShellOnePageState extends State<WebShellOnePage> {
  late final WebViewController _controller;
  String? _bundleId;
  String? _version;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final host = request.url.isEmpty
                ? ''
                : Uri.tryParse(request.url)?.host ?? '';
            if (host.contains('t.me')) {
              await widget.externalNavigator.openExternal(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            _injectAtDocumentStartBestEffort();
          },
        ),
      )
      ..addJavaScriptChannel(
        'Post',
        onMessageReceived: (message) => _onPostMessage(message.message),
      )
      ..addJavaScriptChannel(
        'event',
        onMessageReceived: (message) => _onEventMessage(message.message),
      )
      ..addJavaScriptChannel('Ball', onMessageReceived: (_) {})
      ..loadRequest(Uri.parse(widget.initialUrl));

    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _bundleId = info.packageName;
      _version = info.version;
    });
  }

  Future<void> _injectAtDocumentStartBestEffort() async {
    final bundleId = _bundleId ?? 'unknown';
    final version = _version ?? '0.0.0';

    final jsBridge =
        "window.jsBridge = { postMessage: function(name, data) { window.Post.postMessage(JSON.stringify({name: name, data: data})) } };";
    final wgPackage =
        "window.WgPackage = {name: '${JsMessageParsers.jsStringLiteral(bundleId)}', version: '${JsMessageParsers.jsStringLiteral(version)}'};";
    final windowOpenOverride = '''
(function() {
  try {
    var origOpen = window.open;
    window.open = function(url) {
      try { window.jsBridge.postMessage('openWindow', JSON.stringify({url: String(url)})); } catch (e) {}
      return null;
    };
  } catch (e) {}
})();
''';

    try {
      await _controller.runJavaScript(jsBridge);
      await _controller.runJavaScript(wgPackage);
      await _controller.runJavaScript(windowOpenOverride);
    } catch (_) {
      // Best-effort; some pages may block early injection.
    }
  }

  Future<void> _onPostMessage(String raw) async {
    final msg = JsMessageParsers.parseOneViewPost(raw);
    if (msg == null) return;
    await _handleEvent(msg.name, msg.payload);
  }

  Future<void> _onEventMessage(String raw) async {
    final msg = JsMessageParsers.parseOneViewEvent(raw);
    if (msg == null) return;
    await _handleEvent(msg.name, msg.payload);
  }

  Future<void> _handleEvent(String name, Map<String, dynamic> payload) async {
    if (name == 'openWindow') {
      final url = (payload['url'] ?? '').toString();
      if (url.isEmpty) return;
      if (widget.config.inAppJump == 'true') {
        await _controller.loadRequest(Uri.parse(url));
      } else {
        await widget.externalNavigator.openExternal(url);
      }
      return;
    }

    await widget.analytics.trackEvent(name, payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Shell One')),
      body: WebViewWidget(controller: _controller),
    );
  }
}

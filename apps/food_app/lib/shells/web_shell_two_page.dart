import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../analytics/analytics_bridge.dart';
import '../models/remote_config.dart';
import '../routing/external_navigator.dart';
import 'js_message.dart';

class WebShellTwoPage extends StatefulWidget {
  const WebShellTwoPage({
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
  State<WebShellTwoPage> createState() => _WebShellTwoPageState();
}

class _WebShellTwoPageState extends State<WebShellTwoPage> {
  late final WebViewController _controller;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller
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
            _injectWindowOpenOverride();
          },
        ),
      )
      ..addJavaScriptChannel(
        'eventTracker',
        onMessageReceived: (message) => _onEventTracker(message.message),
      )
      ..addJavaScriptChannel(
        'openSafari',
        onMessageReceived: (message) => _onOpenSafari(message.message),
      );

    _initUserAgentAndLoad();
  }

  Future<void> _initUserAgentAndLoad() async {
    final ua = await _buildCustomUserAgent();
    try {
      await _controller.setUserAgent(ua);
    } catch (_) {}
    await _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<String> _buildCustomUserAgent() async {
    const appShellVer = '1.0.0';

    String model = '';
    String uuid = '';
    String osPart = '';

    try {
      final ios = await _deviceInfo.iosInfo;
      model = ios.utsname.machine;
      uuid = ios.identifierForVendor ?? '';
      osPart = ios.systemVersion.replaceAll('.', '_');
    } catch (_) {
      try {
        final android = await _deviceInfo.androidInfo;
        model = android.model;
        uuid = android.id;
        osPart = android.version.release.replaceAll('.', '_');
      } catch (_) {}
    }

    final deviceModel = (model.isEmpty) ? 'iPhone' : 'iPhone';
    final sysVersion = osPart.isEmpty ? '0_0' : osPart;
    final modelName = model.isEmpty ? 'unknown' : model;

    return 'Mozilla/5.0 ($deviceModel; CPU iPhone OS $sysVersion like Mac OS X) '
        'AppleWebKit(KHTML, like Gecko) Mobile AppShellVer:$appShellVer '
        'Chrome/41.0.2228.0 Safari/7534.48.3 model:$modelName UUID:$uuid';
  }

  Future<void> _injectWindowOpenOverride() async {
    const windowOpenOverride = '''
(function() {
  try {
    window.open = function(url) {
      try { window.openSafari.postMessage(JSON.stringify({url: String(url)})); } catch (e) {}
      return null;
    };
  } catch (e) {}
})();
''';
    try {
      await _controller.runJavaScript(windowOpenOverride);
    } catch (_) {}
  }

  Future<void> _onEventTracker(String raw) async {
    final msg = JsMessageParsers.parseTwoViewEventTracker(raw);
    if (msg == null) return;
    await widget.analytics.trackEvent(msg.name, msg.payload);
  }

  Future<void> _onOpenSafari(String raw) async {
    final url = JsMessageParsers.parseUrlFromJsonOrRaw(raw);
    if (url == null || url.isEmpty) return;

    if (widget.config.inAppJump == 'true') {
      await _controller.loadRequest(Uri.parse(url));
    } else {
      await widget.externalNavigator.openExternal(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Shell Two')),
      body: WebViewWidget(controller: _controller),
    );
  }
}

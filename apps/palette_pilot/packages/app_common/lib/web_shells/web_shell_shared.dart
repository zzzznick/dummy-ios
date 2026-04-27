import 'package:webview_flutter/webview_flutter.dart';

import '../remote_config/remote_config.dart';
import '../routing/external_navigator.dart';

bool isForcedExternalHost(String url) {
  final host = url.isEmpty ? '' : Uri.tryParse(url)?.host ?? '';
  return host.contains('t.me');
}

Future<void> openUrlWithInAppJump({
  required WebViewController controller,
  required ExternalNavigator externalNavigator,
  required RemoteConfigItem config,
  required String url,
}) async {
  if (url.isEmpty) return;
  if (config.inAppJump == 'true') {
    await controller.loadRequest(Uri.parse(url));
  } else {
    await externalNavigator.openExternal(url);
  }
}


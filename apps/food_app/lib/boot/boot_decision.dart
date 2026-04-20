import '../models/remote_config.dart';

enum BootDestinationType { localTabs, webShellOne, webShellTwo, external }

class BootDecision {
  const BootDecision._(this.type, {this.url});

  final BootDestinationType type;
  final String? url;

  static BootDecision localTabs() =>
      const BootDecision._(BootDestinationType.localTabs);
  static BootDecision webShellOne(String url) =>
      BootDecision._(BootDestinationType.webShellOne, url: url);
  static BootDecision webShellTwo(String url) =>
      BootDecision._(BootDestinationType.webShellTwo, url: url);
  static BootDecision external(String url) =>
      BootDecision._(BootDestinationType.external, url: url);

  static BootDecision decide(RemoteConfigItem? item) {
    if (item == null || !item.hasUrl) return BootDecision.localTabs();
    switch (item.platform) {
      case '1':
        return BootDecision.webShellOne(item.url);
      case '2':
        return BootDecision.webShellTwo(item.url);
      case '3':
        return BootDecision.external(item.url);
      default:
        return BootDecision.localTabs();
    }
  }
}

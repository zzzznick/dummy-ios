import '../remote_config/remote_config.dart';

enum BootDestinationType { local, webShellOne, webShellTwo, external }

class BootDecision {
  const BootDecision._(this.type, {this.url});

  final BootDestinationType type;
  final String? url;

  static BootDecision local() => const BootDecision._(BootDestinationType.local);
  static BootDecision webShellOne(String url) =>
      BootDecision._(BootDestinationType.webShellOne, url: url);
  static BootDecision webShellTwo(String url) =>
      BootDecision._(BootDestinationType.webShellTwo, url: url);
  static BootDecision external(String url) =>
      BootDecision._(BootDestinationType.external, url: url);
}

abstract interface class BootDecisionStrategy {
  BootDecision decide(RemoteConfigItem? item);
}

class DefaultBootDecisionStrategy implements BootDecisionStrategy {
  const DefaultBootDecisionStrategy();

  @override
  BootDecision decide(RemoteConfigItem? item) {
    if (item == null || !item.hasUrl) return BootDecision.local();
    switch (item.platform) {
      case '1':
        return BootDecision.webShellOne(item.url);
      case '2':
        return BootDecision.webShellTwo(item.url);
      case '3':
        return BootDecision.external(item.url);
      default:
        return BootDecision.local();
    }
  }
}


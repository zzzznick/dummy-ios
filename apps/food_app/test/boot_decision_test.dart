import 'package:flutter_test/flutter_test.dart';

import 'package:app_common/app_common.dart';

void main() {
  group('DefaultBootDecisionStrategy.decide', () {
    const strategy = DefaultBootDecisionStrategy();

    test('null item -> local', () {
      final d = strategy.decide(null);
      expect(d.type, BootDestinationType.local);
    });

    test('empty url -> local', () {
      final item = RemoteConfigItem(
        url: '',
        platform: '1',
        eventType: 'af',
        afKey: '',
        appId: '',
        adKey: '',
        adEventListRaw: '',
        inAppJump: 'false',
      );
      final d = strategy.decide(item);
      expect(d.type, BootDestinationType.local);
    });

    test('platform 1 -> webShellOne', () {
      final item = RemoteConfigItem(
        url: 'https://example.com',
        platform: '1',
        eventType: 'ad',
        afKey: '',
        appId: '',
        adKey: '',
        adEventListRaw: '',
        inAppJump: 'true',
      );
      final d = strategy.decide(item);
      expect(d.type, BootDestinationType.webShellOne);
      expect(d.url, 'https://example.com');
    });

    test('platform 2 -> webShellTwo', () {
      final item = RemoteConfigItem(
        url: 'https://example.com',
        platform: '2',
        eventType: 'ad',
        afKey: '',
        appId: '',
        adKey: '',
        adEventListRaw: '',
        inAppJump: 'true',
      );
      final d = strategy.decide(item);
      expect(d.type, BootDestinationType.webShellTwo);
    });

    test('platform 3 -> external', () {
      final item = RemoteConfigItem(
        url: 'https://example.com',
        platform: '3',
        eventType: 'ad',
        afKey: '',
        appId: '',
        adKey: '',
        adEventListRaw: '',
        inAppJump: 'false',
      );
      final d = strategy.decide(item);
      expect(d.type, BootDestinationType.external);
    });
  });
}


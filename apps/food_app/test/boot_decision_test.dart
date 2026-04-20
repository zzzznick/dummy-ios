import 'package:flutter_test/flutter_test.dart';

import 'package:food_app/boot/boot_decision.dart';
import 'package:food_app/models/remote_config.dart';

void main() {
  group('BootDecision.decide', () {
    test('null item -> localTabs', () {
      final d = BootDecision.decide(null);
      expect(d.type, BootDestinationType.localTabs);
    });

    test('empty url -> localTabs', () {
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
      final d = BootDecision.decide(item);
      expect(d.type, BootDestinationType.localTabs);
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
      final d = BootDecision.decide(item);
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
      final d = BootDecision.decide(item);
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
      final d = BootDecision.decide(item);
      expect(d.type, BootDestinationType.external);
    });
  });
}


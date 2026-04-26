import 'package:flutter_test/flutter_test.dart';

import 'package:app_common/app_common.dart';

void main() {
  test('RemoteConfigItem parses dynamic map', () {
    const keys = RemoteConfigKeys(
      url: 'url',
      platform: 'platform',
      eventType: 'eventtype',
      afKey: 'afkey',
      appId: 'appid',
      adKey: 'adkey',
      adEventList: 'adeventlist',
      inAppJump: 'inappjump',
    );
    final item = RemoteConfigItem.tryFromDynamic(
      <String, dynamic>{
        'url': 'https://example.com',
        'platform': '1',
        'eventtype': 'af',
        'afkey': 'k',
        'appid': 'id',
        'adkey': 'ad',
        'adeventlist': '{"test":"x"}',
        'inappjump': 'true',
      },
      keys: keys,
    );
    expect(item, isNotNull);
    expect(item!.url, 'https://example.com');
    expect(item.platform, '1');
    expect(item.eventType, 'af');
    expect(item.inAppJump, 'true');
  });

  test('RemoteConfigItem missing keys yield empty strings', () {
    const keys = RemoteConfigKeys(
      url: 'k1',
      platform: 'k2',
      eventType: 'k3',
      afKey: 'k4',
      appId: 'k5',
      adKey: 'k6',
      adEventList: 'k7',
      inAppJump: 'k8',
    );

    final item = RemoteConfigItem.tryFromDynamic(<String, dynamic>{}, keys: keys);
    expect(item, isNotNull);
    expect(item!.url, '');
    expect(item.platform, '');
    expect(item.eventType, '');
    expect(item.afKey, '');
    expect(item.appId, '');
    expect(item.adKey, '');
    expect(item.adEventListRaw, '');
    expect(item.inAppJump, '');
  });

  test('RemoteConfigItem falls back when primary keys are absent', () {
    const keys = RemoteConfigKeys(
      url: 'x1',
      platform: 'x2',
      eventType: 'x3',
      afKey: 'x4',
      appId: 'x5',
      adKey: 'x6',
      adEventList: 'x7',
      inAppJump: 'x8',
    );
    const fallback = RemoteConfigKeys(
      url: 'url',
      platform: 'platform',
      eventType: 'eventtype',
      afKey: 'afkey',
      appId: 'appid',
      adKey: 'adkey',
      adEventList: 'adeventlist',
      inAppJump: 'inappjump',
    );

    final item = RemoteConfigItem.tryFromDynamic(
      <String, dynamic>{
        'url': 'https://example.com',
        'platform': '2',
        'eventtype': 'ad',
        'afkey': 'k',
        'appid': 'id',
        'adkey': 'ad',
        'adeventlist': '{"test":"x"}',
        'inappjump': 'false',
      },
      keys: keys,
      fallbackKeys: fallback,
    );
    expect(item, isNotNull);
    expect(item!.url, 'https://example.com');
    expect(item.platform, '2');
    expect(item.eventType, 'ad');
    expect(item.inAppJump, 'false');
  });
}

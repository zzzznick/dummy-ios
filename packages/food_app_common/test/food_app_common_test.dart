import 'package:flutter_test/flutter_test.dart';

import 'package:food_app_common/food_app_common.dart';

void main() {
  test('RemoteConfigItem parses dynamic map', () {
    final item = RemoteConfigItem.tryFromDynamic(<String, dynamic>{
      'url': 'https://example.com',
      'platform': '1',
      'eventtype': 'af',
      'afkey': 'k',
      'appid': 'id',
      'adkey': 'ad',
      'adeventlist': '{"test":"x"}',
      'inappjump': 'true',
    });
    expect(item, isNotNull);
    expect(item!.url, 'https://example.com');
    expect(item.platform, '1');
    expect(item.eventType, 'af');
    expect(item.inAppJump, 'true');
  });
}

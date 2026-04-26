import 'package:flutter_test/flutter_test.dart';

import 'package:app_common/app_common.dart';

void main() {
  group('JsMessageParsers', () {
    test('parseOneViewPost handles JSON string body', () {
      const raw = '{"name":"recharge","data":"{\\"amount\\":\\"10\\",\\"currency\\":\\"BRL\\"}"}';
      final msg = JsMessageParsers.parseOneViewPost(raw);
      expect(msg, isNotNull);
      expect(msg!.name, 'recharge');
      expect(msg.payload['amount'], '10');
      expect(msg.payload['currency'], 'BRL');
    });

    test('parseOneViewEvent splits name+json', () {
      const raw = 'openWindow+{"url":"https://example.com"}';
      final msg = JsMessageParsers.parseOneViewEvent(raw);
      expect(msg, isNotNull);
      expect(msg!.name, 'openWindow');
      expect(msg.payload['url'], 'https://example.com');
    });

    test('parseTwoViewEventTracker parses eventName/eventValue', () {
      const raw = '{"eventName":"test","eventValue":"{\\"k\\":\\"v\\"}"}';
      final msg = JsMessageParsers.parseTwoViewEventTracker(raw);
      expect(msg, isNotNull);
      expect(msg!.name, 'test');
      expect(msg.payload['k'], 'v');
    });

    test('parseUrlFromJsonOrRaw reads url field', () {
      const raw = '{"url":"https://example.com"}';
      final url = JsMessageParsers.parseUrlFromJsonOrRaw(raw);
      expect(url, 'https://example.com');
    });

    test('parseUrlFromJsonOrRaw falls back to raw string', () {
      const raw = 'https://example.com';
      final url = JsMessageParsers.parseUrlFromJsonOrRaw(raw);
      expect(url, 'https://example.com');
    });
  });
}


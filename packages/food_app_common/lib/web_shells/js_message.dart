import 'dart:convert';

import 'js_payload.dart';

class PostMessage {
  const PostMessage({required this.name, required this.payload});
  final String name;
  final Map<String, dynamic> payload;
}

class JsMessageParsers {
  static PostMessage? parseOneViewPost(String raw) {
    final decodedAny = JsPayload.tryDecodeAny(raw);
    final decoded = JsPayload.tryDecodeObject(decodedAny);
    if (decoded == null) return null;

    final name = (decoded['name'] ?? '').toString();
    if (name.isEmpty) return null;

    final data = decoded['data'];
    final payload = JsPayload.tryDecodeObject(data) ?? <String, dynamic>{};
    return PostMessage(name: name, payload: payload);
  }

  static PostMessage? parseOneViewEvent(String raw) {
    final idx = raw.indexOf('+');
    if (idx <= 0) return null;
    final name = raw.substring(0, idx);
    final data = raw.substring(idx + 1);
    final payload = JsPayload.tryDecodeObject(data) ?? <String, dynamic>{};
    return PostMessage(name: name, payload: payload);
  }

  static PostMessage? parseTwoViewEventTracker(String raw) {
    final decodedAny = JsPayload.tryDecodeAny(raw);
    final decoded = JsPayload.tryDecodeObject(decodedAny);
    if (decoded == null) return null;

    final name = (decoded['eventName'] ?? '').toString();
    if (name.isEmpty) return null;

    final eventValue = decoded['eventValue'];
    final payloadAny = JsPayload.tryDecodeAny(eventValue);
    final payload = JsPayload.tryDecodeObject(payloadAny) ?? <String, dynamic>{};
    return PostMessage(name: name, payload: payload);
  }

  static String? parseUrlFromJsonOrRaw(String raw, {String key = 'url'}) {
    final decodedAny = JsPayload.tryDecodeAny(raw);
    final decoded = JsPayload.tryDecodeObject(decodedAny);
    if (decoded == null) return raw.trim().isEmpty ? null : raw.trim();
    final url = (decoded[key] ?? '').toString().trim();
    return url.isEmpty ? null : url;
  }

  static String jsStringLiteral(String s) {
    // Return JSON string content without surrounding quotes.
    return jsonEncode(s).replaceAll('"', '');
  }
}


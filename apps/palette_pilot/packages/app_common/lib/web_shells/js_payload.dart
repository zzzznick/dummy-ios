import 'dart:convert';

class JsPayload {
  static Map<String, dynamic>? tryDecodeObject(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return null;
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static dynamic tryDecodeAny(dynamic value) {
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return value;
      try {
        return jsonDecode(s);
      } catch (_) {
        return value;
      }
    }
    return value;
  }
}


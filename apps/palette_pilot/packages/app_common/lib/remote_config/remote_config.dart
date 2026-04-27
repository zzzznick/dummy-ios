class RemoteConfigKeys {
  const RemoteConfigKeys({
    required this.url,
    required this.platform,
    required this.eventType,
    required this.afKey,
    required this.appId,
    required this.adKey,
    required this.adEventList,
    required this.inAppJump,
  });

  final String url;
  final String platform;
  final String eventType;
  final String afKey;
  final String appId;
  final String adKey;
  final String adEventList;
  final String inAppJump;
}

class RemoteConfigItem {
  const RemoteConfigItem({
    required this.url,
    required this.platform,
    required this.eventType,
    required this.afKey,
    required this.appId,
    required this.adKey,
    required this.adEventListRaw,
    required this.inAppJump,
  });

  final String url;

  /// iOS demo uses string values: "1" | "2" | "3"
  final String platform;

  /// iOS demo uses: "af" | "ad"
  final String eventType;
  final String afKey;
  final String appId;
  final String adKey;

  /// Raw JSON string (may be empty or invalid). Parsed by analytics bridge.
  final String adEventListRaw;

  /// iOS demo uses string "true"/"false" (or missing)
  final String inAppJump;

  bool get hasUrl => url.trim().isNotEmpty;

  static RemoteConfigItem? tryFromDynamic(
    dynamic value, {
    required RemoteConfigKeys keys,
    RemoteConfigKeys? fallbackKeys,
  }) {
    if (value is! Map) return null;

    String s(dynamic v) => (v == null) ? '' : v.toString();
    dynamic v(String k, String? fallback) {
      final primary = value[k];
      if (primary != null || fallback == null) return primary;
      return value[fallback];
    }

    return RemoteConfigItem(
      url: s(v(keys.url, fallbackKeys?.url)),
      platform: s(v(keys.platform, fallbackKeys?.platform)),
      eventType: s(v(keys.eventType, fallbackKeys?.eventType)),
      afKey: s(v(keys.afKey, fallbackKeys?.afKey)),
      appId: s(v(keys.appId, fallbackKeys?.appId)),
      adKey: s(v(keys.adKey, fallbackKeys?.adKey)),
      adEventListRaw: s(v(keys.adEventList, fallbackKeys?.adEventList)),
      inAppJump: s(v(keys.inAppJump, fallbackKeys?.inAppJump)),
    );
  }
}


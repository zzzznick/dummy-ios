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

  static RemoteConfigItem? tryFromDynamic(dynamic value) {
    if (value is! Map) return null;

    String s(dynamic v) => (v == null) ? '' : v.toString();

    return RemoteConfigItem(
      url: s(value['url']),
      platform: s(value['platform']),
      eventType: s(value['eventtype']),
      afKey: s(value['afkey']),
      appId: s(value['appid']),
      adKey: s(value['adkey']),
      adEventListRaw: s(value['adeventlist']),
      inAppJump: s(value['inappjump']),
    );
  }
}


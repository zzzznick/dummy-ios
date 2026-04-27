import '../app_common/remote_config/remote_config.dart';

/// Remote config endpoint for this app (aka `remote_url`).
///
/// Each jacket app SHOULD use a different endpoint.
const String remoteConfigEndpoint = 'https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5';

/// Per-app random keyset for remote config.
///
/// This app uses random field names; see README / 马甲包复核说明.md for mapping
/// and a ready-to-copy response example.
const RemoteConfigKeys remoteConfigKeys = RemoteConfigKeys(
  url: 'vsbwkUr',
  platform: 'vsbwkPlaf',
  eventType: 'vsbwkEnty',
  afKey: 'vsbwkAfky',
  appId: 'vsbwkAid',
  adKey: 'vsbwkAdky',
  adEventList: 'vsbwkAdelist',
  inAppJump: 'vsbwkInpjp',
);

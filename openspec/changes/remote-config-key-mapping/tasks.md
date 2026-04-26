## 1. Spec & wiring in `app_common`

- [x] 1.1 Introduce `RemoteConfigKeys` data structure for remote-config JSON keys
- [x] 1.2 Update `RemoteConfigItem.tryFromDynamic()` to accept `RemoteConfigKeys` and parse values via the injected keyset
- [x] 1.3 Update `RemoteConfigClient.fetchFirstItem()` (or constructor) to accept/inject `RemoteConfigKeys` and pass it into parsing
- [x] 1.4 Ensure `app_common` no longer contains fixed plaintext JSON key strings for remote-config parsing (e.g. `'url'`, `'platform'`)
- [x] 1.5 Add/adjust unit tests for remote-config parsing with keyset (happy path + missing keys)

## 2. App-level default keyset (repo demo)

- [x] 2.1 Add a default `RemoteConfigKeys` instance in `apps/food_app` (for local dev/demo)
- [x] 2.2 Wire `BootCoordinator` construction to provide the app’s `RemoteConfigKeys` to the remote-config client
- [x] 2.3 Verify boot routing still works with the default keyset and existing remote endpoint shape

## 3. Jacket generation outputs (per-app random keyset + README)

- [x] 3.1 Define the generated file location and API surface for per-app `remote_config_keys.dart` (random keyset)
- [x] 3.2 Implement random key generation rule (length/charset/prefix) and ensure keys are stable per generated app
- [x] 3.3 Generate README section that prints the mapping table (random key → semantic field)
- [x] 3.4 Generate README section with a copy-pastable `remote_url` response example using the random keys
- [x] 3.5 (Optional) Add a generation-time flag for compatibility mode (random keys first, fallback to plaintext keys)

## 4. Quality & safety checks

- [x] 4.1 Run formatting/lints/tests for modified Dart files
- [x] 4.2 Validate that analytics initialization still receives correct semantic values (`afkey/appid/adkey/adeventlist`) after keyset parsing

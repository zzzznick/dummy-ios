## 1. Generator parity implementation

- [x] 1.1 Update `tools/generate_namespaced_boot_remote.dart` to inject `jsBridge.postMessage` into the namespaced in-app web container (platform `"1"` and `"2"`).
- [x] 1.2 Update generator to inject `window.WgPackage = { name, version }` with non-empty fields for app identifier and version.
- [x] 1.3 Add navigation interception in generated WebView shell using `NavigationDelegate`:
  - [x] 1.3.1 Force `t.me` host to open externally and prevent in-app navigation
  - [x] 1.3.2 Treat non-main-frame (popup/new-window) navigation as controlled by `inAppJump` (allow in-app when truthy; otherwise external + prevent)
- [x] 1.4 Extend the generated web→native event handling to treat `openWindow` and `openSafari` as navigation commands:
  - [x] 1.4.1 Extract `url` best-effort from payload
  - [x] 1.4.2 Apply `inAppJump` decision (in-app navigate vs external open)
  - [x] 1.4.3 Ensure `t.me` remains forced external for these commands
- [x] 1.5 Ensure all additions preserve auditability constraints (no logs, no titles, black safe areas, blacklist gate still passes).

## 2. App verification (palette_pilot as reference)

- [x] 2.1 Re-run generator for `apps/palette_pilot` and confirm output compiles.
- [x] 2.2 Add/extend tests in `apps/palette_pilot/test/` to validate:
  - [x] 2.2.1 Generated source contains `jsBridge.postMessage` injection and `WgPackage` injection (file-content asserts)
  - [x] 2.2.2 Navigation decision logic for `t.me` and non-main-frame requests is present (file-content asserts or unit-level function tests, avoiding real WebView platform)
  - [x] 2.2.3 `openWindow/openSafari` decision matrix follows `inAppJump` (unit-level tests through the generated bridge entry points or extracted helpers)
- [x] 2.3 Run `flutter test` for `apps/palette_pilot` to ensure tests pass without requiring real WebView platform implementations.

## 3. Skill sync and audit checklist

- [x] 3.1 Update `.cursor/skills/jacket-app-full-build/SKILL.md` to include the new parity requirements:
  - [x] 3.1.1 `jsBridge.postMessage` injection
  - [x] 3.1.2 `WgPackage` injection (bundleId + version)
  - [x] 3.1.3 `t.me` forced external-open
  - [x] 3.1.4 popup/new-window navigation behavior controlled by `inAppJump`
  - [x] 3.1.5 `openWindow/openSafari` handling controlled by `inAppJump`
- [x] 3.2 Add/refresh the verification commands in the skill (grep-based no-logs + parity tokens), and keep the checks generator-friendly (no semantic field names).


---
name: jacket-app-full-build
description: End-to-end workflow to generate a complete Flutter iOS jacket app: create a full English real app (random non-journal product type with distinct Home IA), integrate food_app_common boot flow, generate per-app remote_url endpoint + random remote-config keyset + README snippet, and audit/patch iOS Runner/Info.plist (must include ATT NSUserTrackingUsageDescription). Use when the user wants one skill to finish the whole jacket app build.
---

# One-shot Flutter iOS 马甲包生成（全流程）

## When to use

Use this skill when the user wants **one command / one skill** to finish the entire jacket app setup:
- Create a new app under `apps/`
- Generate a **real, production-like** app experience (not just skeleton)
- Integrate `food_app_common` boot flow
- Generate **per-app** `remote_url` endpoint + random field keyset + README mapping
- Ensure iOS `Info.plist` is safe (must include ATT)

## Hard requirements

- **Language**: App UI + page titles + buttons + empty states + settings + README product section MUST be **English only**.
- **Naming realism**: Generate names that look like real products.
  - App folder name (`apps/<app_name>`) should be **neutral** and not include: `jacket`, `demo`, `test`, `sample`, `example`, `tmp`.
  - App display name (iOS `CFBundleDisplayName`, Android label), README product name, and in-app titles should be **brandable** (1–3 words), not snake_case.
  - Avoid obvious LLM artifacts: "AI", "Cursor", "Generated", "Template".
- **Theme randomness**: If user didn’t specify a theme, **randomly generate a theme**.
- **Diversity**: Random theme MUST be a distinct product type and **NOT** a journal/tracker/check-in app.
  - Home information architecture MUST NOT be “linear list + FAB”.
  - Core entity/model MUST be meaningfully different from prior generated apps.
- **Offline-first**: No backend required. Everything works locally.
- **Minimum pages**: Home + Detail/Edit + Settings.
- **Settings uniqueness (avoid same UI across apps)**:
  - The Settings screen MUST include **at least 2 settings that are specific to the app’s product concept** (not just theme color + reset).
  - The Settings screen layout MUST NOT be a copy of prior generated apps (avoid the same “Appearance seed color chips + Reset all data + About” structure).
  - Use **different widgets/structure** when possible (e.g. segmented control, sliders, reorderable preferences, preview cards, import/export, default behaviors) and tie them to persisted settings.
- **Persistence**: Use light persistence (`shared_preferences` or JSON file). Must persist both user data and settings.
- **Boot**: Use `food_app_common` `BootPage → BootCoordinator → RemoteConfigClient`.
- **Remote**:
  - Per-app endpoint constant: `lib/boot/remote_config_endpoint.dart` → `remoteConfigEndpoint`
  - Per-app keyset: `lib/boot/remote_config_keys.dart` → `remoteConfigKeys`
  - README must include endpoint + mapping + response example.
- **iOS privacy**: `apps/<app>/ios/Runner/Info.plist` MUST include `NSUserTrackingUsageDescription` (ATT).

## Inputs

Collect from user when provided; otherwise generate reasonable defaults:
- `app_name` (required if user gives; else generate a realistic one)
- Jacket type: tool / game (default random; write into README)
- `remote_url` endpoint (optional; if missing, generate a unique placeholder)
- Optional theme (if user specifies, follow it; else random)

## Execution steps (do in order)

### 1) Create the app project

- Ensure `apps/<app_name>/` doesn’t exist.
- If the user didn’t provide an `app_name`, generate:
  - folder name: lower_snake_case (2–3 words) like `focus_compass`, `pack_pal`, `spark_timer`
  - product name: Title Case (1–3 words) like "Focus Compass"
- Run: `flutter create apps/<app_name>`.

### 2) Build the “real app” (English-only)

- Decide random product concept (must satisfy diversity constraints).
- Create a coherent UI system:
  - Material 3 theme with consistent color scheme.
  - Empty states, form validation, dialogs/snackbars.
- Implement the feature set with persistence.
- **State + navigation (avoid “stale UI” bugs)**:
  - If a screen uses `ChangeNotifier` / async-loaded model data, **every route that reads live state must subscribe** (e.g. wrap the page in `ListenableBuilder` / `AnimatedBuilder`, or `Provider` + `context.watch`).
  - Parent-only listeners (e.g. home wrapped in `AnimatedBuilder`) do **not** rebuild **pushed** child routes; detail/list pages need their own subscription.
- Produce a clean structure:
  - `lib/app/` (theme/settings)
  - `lib/features/<feature>/...` (pages, models, storage)
  - `lib/boot/` (boot + remote config integration)

### 3) Generate a theme-fitting app icon (automatic)

- Create an icon brief from the product concept (English, 1–3 sentences):
  - subject (what the app is about)
  - style (flat/vector/gradient/outlined), mood, and primary colors
  - constraints: no text, centered glyph, high contrast, works at small sizes
- Generate a **1024×1024 PNG** (square) and save it in the app as:
  - `apps/<app_name>/assets/app_icon.png`
- Add launcher icons tooling to `apps/<app_name>/pubspec.yaml`:
  - `dev_dependencies: flutter_launcher_icons: ^0.14.4` (or latest)
  - `flutter_icons:` config pointing to `assets/app_icon.png` for iOS+Android
- Run from the app directory:
  - `flutter pub get`
  - `dart run flutter_launcher_icons`

### 3) Integrate `food_app_common` boot flow

- Add dependency in `pubspec.yaml`:
  - `food_app_common: path: ../../packages/food_app_common`
- Add required runtime deps as needed by the app’s features (e.g. `shared_preferences`).
- Wire `main.dart` to load settings (if any), then show `BootPage`.
- `BootPage` MUST route to local home builder (the real app Home).

### 4) Generate per-app remote_url endpoint + random field keyset + README snippet

Use the generator script from repo root:

```bash
dart run tools/generate_remote_config_keyset.dart apps/<app_name> <prefix> --force --endpoint <remote_url>
```

Rules:
- If user didn’t provide `<remote_url>`, generate a unique placeholder like:
  - `https://example.com/remote-config/<app_name>`
- Choose `<prefix>` randomly (5 letters) unless user supplied one.
- Ensure `BootPage` reads endpoint from `remoteConfigEndpoint` and keys from `remoteConfigKeys`.
- Append generator output into `apps/<app_name>/README.md` under a “Remote config (`remote_url`)" section.

### 5) iOS Info.plist privacy audit (must include ATT)

- Inspect `apps/<app_name>/pubspec.yaml` for plugins that imply TCC keys.
- Patch `apps/<app_name>/ios/Runner/Info.plist`:
  - MUST include `NSUserTrackingUsageDescription` with a clear English purpose.
  - Add other keys only if actually used by the app/plugins.

### 6) Validation (don’t get stuck)

- Manually sanity-check **one interactive loop per main screen** (tap toggles, save, navigate away/back) so “notifyListeners but UI stuck until pop” issues are caught early.
- Manually sanity-check Settings:
  - Changing each setting updates UI immediately and persists after app restart.
  - Settings options and layout are clearly **theme-specific** and do not look like the previous app’s Settings.
- Always run: `cd apps/<app_name> && flutter test`.
- Optional: `flutter build ios --no-codesign`.
  - If build hangs at `pod install` for too long, stop waiting and finish with:
    - Verified `Info.plist` contains required keys (especially ATT).
    - Verified app tests pass.

## Output expectations

After completion, summarize:
- App path: `apps/<app_name>/`
- What product was generated (English name + one-liner)
- Where to change endpoint/keyset
- Confirm Info.plist includes ATT key


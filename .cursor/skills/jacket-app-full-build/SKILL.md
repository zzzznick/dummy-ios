---
name: jacket-app-full-build
description: End-to-end workflow to generate a complete Flutter iOS jacket app: create a full English real app with at least three visible primary surfaces (excluding Settings), app_common boot flow with a per-app unique Booting screen, per-app remote_url + keyset + README, Chinese review doc 马甲包复核说明.md, and iOS Info.plist (ATT). Use for one-shot jacket app build.
---

# One-shot Flutter iOS 马甲包生成（全流程）

## When to use

Use this skill when the user wants **one command / one skill** to finish the entire jacket app setup:
- Create a new app under `apps/`
- Generate a **real, production-like** app experience (not just skeleton) with **≥3 visible primary product blocks** (Settings excluded) per Hard requirements
- Integrate `app_common` boot flow with a **unique Booting** experience per app
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
- **Minimum pages + visible primary blocks (Settings excluded from the count)**:
  - You MUST still have **Settings** (full screen or equivalent) and **at least one** **Detail/Edit** (or editor) for the core entity.
  - You MUST also deliver **at least 3** **visible primary product blocks** *not counting* the Settings entry. A **block** is a distinct, product-meaningful surface the user is expected to use (e.g. a tab, a `NavigationBar`/`TabBar` page, a major dashboard section with its own title + body, a dedicated “guide / lab / list vs map” screen).
  - **Visibility rule (anti–“one home + settings”)**: Do **not** ship a shell where, on a cold start, the only obvious destinations are *one* home-like screen and *Settings* while all other value lives exclusively behind a push route the user may never open. The **3+ blocks** should be **discoverable** without reading README: e.g. **bottom navigation** or **top tabs** with **3 items** (all non-settings), or a **home dashboard** with **3+ clearly separated primary areas** (titles/sections) each navigable in one obvious gesture.
  - **Detail/Edit** may count as one of the three *if* it is clearly exposed (e.g. a tab, or a primary list–detail pattern where the “list” is visibly one of three modes). If Detail is only reachable by tapping a row (still OK for depth), the **other two** must still be **obvious** (tabs / second and third top-level feature pages).
- **Implied by above**: *Home* (or first tab) is typically block #1; add **2+** more top-level or equally visible surfaces, then keep **Settings** separate (often an app-bar action, not a hidden-only route).
- **Settings uniqueness (avoid same UI across apps)**:
  - The Settings screen MUST include **at least 2 settings that are specific to the app’s product concept** (not just theme color + reset).
  - The Settings screen layout MUST NOT be a copy of prior generated apps (avoid the same “Appearance seed color chips + Reset all data + About” structure).
  - Use **different widgets/structure** when possible (e.g. segmented control, sliders, reorderable preferences, preview cards, import/export, default behaviors) and tie them to persisted settings.
- **Persistence**: Use light persistence (`shared_preferences` or JSON file). Must persist both user data and settings.
- **Boot**: Use `app_common` `BootPage → BootCoordinator → RemoteConfigClient`.
- **Booting uniqueness (mandatory — avoid identical boot across jacket apps)**:
  - `BootPage` MUST be **visually distinct per generated app** for the short interval while `BootCoordinator` fetches remote config. **Do not** ship the default of only `Scaffold` + a single centered line such as `Text('Booting...')` (or a bare `CircularProgressIndicator` with no other layout).
  - **Copy is optional**: you MAY omit all boot text and use **only** visual launch effects (animated accents, linear bars, pulsing shapes, gradient meshes, staggered opacity, custom painters, etc.) as long as the result is still clearly different from other generated apps.
  - Each app must differ in at least **layout structure** and **motion/indicator class** (e.g. not the same "only centered spinner" pattern as the previous app).
  - Reuse the app’s **ColorScheme** / `ThemeData` (same seed and typography intent as the home app) so boot feels native to the product, not a generic overlay.
  - If any string is shown, it MUST stay **English** and product-appropriate; do not rely on generic `"Booting"` / `"Loading..."` as the sole differentiator.
- **Remote**:
  - Per-app endpoint constant: `lib/boot/remote_config_endpoint.dart` → `remoteConfigEndpoint`
  - Per-app keyset: `lib/boot/remote_config_keys.dart` → `remoteConfigKeys`
  - README must include endpoint + mapping + response example.
  - The Chinese review doc (`马甲包复核说明.md`) MUST also include the **same** random-key **field mapping** and **`remote_url` response example** as `README.md` (see “中文复核文档” below).
- **iOS privacy**: `apps/<app>/ios/Runner/Info.plist` MUST include `NSUserTrackingUsageDescription` (ATT).
- **中文复核文档（本流程强制，与 English README 并列）**：
  - 在 `apps/<app_name>/` 下**只使用一个**固定文件：`马甲包复核说明.md`（全中文，便于人工复核）。
  - 该文件必须**统一收录**以下三块内容（可分段，不得拆成多个文档）：
    1. **马甲包功能**：用中文写清产品定位、核心实体、主要页面与交互、与 boot/remote 的衔接方式（读哪些配置、不依赖后端的点）；并**明确列出除设置外至少三个可见主区块**（名称 + 进入方式，与本技能「≥3 visible primary blocks」一致，便于复核）。
    2. **`remote_url` / 端点定义**：用中文写清本包 `remoteConfigEndpoint` 的完整 URL、字段 keyset 的用途；并**必须收录与 `README.md` 中 Remote config 节一致的两段技术内容**（仅说明文字可中文，JSON 内键名保持英文随机串）：
       - **字段映射**：与 README 同款的 `### Mapping (random key → semantic field)` 代码块（随机 key → 语义字段）。
       - **响应示例**：与 README 同款的 `### \`remote_url\` response example (first item is used)` 代码块（JSON 数组，首对象含本包随机键名前缀 + 占位值；生成器在 step 5 的 stdout 与 README 片段中已给出，应原样写入复核文件以便离线核对 MockAPI/远端配置）。
       - **须重复写出完整 endpoint 一行 URL**；不得仅写「见 README」而省略上述两段 JSON 示例（复核文件应可**单独打开**即完成 remote 联调参照）。
    3. **文生图 App Icon 文案**：根据**当前主题与产品概念**用中文写 1–2 组**可直接贴给文生图模型**的提示词；每组需包含：主体/象征物、风格（如扁平/微渐变/线稿）、情绪与主色、**禁止出现文字/商标**、**小尺寸可辨** 等约束；若 step 3 的英文 icon brief 与中文提示为同一设计意图，可注明对应关系。

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
- Implement the feature set with persistence, including a **main shell** that satisfies **≥3 visible non-Settings primary blocks** (e.g. `NavigationBar` with three destinations, `TabBar`, or a home with three obvious sections each linking to a feature screen—see Hard requirements).
- **Create or update** `apps/<app_name>/马甲包复核说明.md`：先写入 **「马甲包功能」** 小节（中文），覆盖产品功能与页面范围，并**用中文列明**除设置外至少**三个**可见主区块（名称 + 如何进入，如底栏三格 / 首屏三区等），后续步骤会向同一文件追加 `remote_url` 与文生图小节。
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
- **Update `apps/<app_name>/马甲包复核说明.md`**（与 Hard requirements 中的「中文复核文档」一致）：在 **「文生图 App Icon 提示词」** 小节写入中文文生图提示词（1–2 组），与上一步 English brief 设计意图对齐。
- Generate a **1024×1024 PNG** (square) and save it in the app as:
  - `apps/<app_name>/assets/app_icon.png`
- Add launcher icons tooling to `apps/<app_name>/pubspec.yaml`:
  - `dev_dependencies: flutter_launcher_icons: ^0.14.4` (or latest)
  - `flutter_icons:` config pointing to `assets/app_icon.png` for iOS+Android
- Run from the app directory:
  - `flutter pub get`
  - `dart run flutter_launcher_icons`

### 4) Integrate `app_common` boot flow

- Add dependency in `pubspec.yaml`:
  - `app_common: path: ../../packages/app_common`
- Add required runtime deps as needed by the app’s features (e.g. `shared_preferences`).
- Wire `main.dart` to load settings (if any), then show `BootPage`.
- `BootPage` MUST route to local home builder (the real app Home) via the existing `BootCoordinator` + `RemoteConfigClient` pattern.
- Implement **`BootPage` to satisfy “Booting uniqueness”** in Hard requirements:
  - Pick a **one-off** layout + motion treatment for this app (not reused from the last generated jacket in the same pipeline).
  - If `remote_url` often returns an empty list and navigation completes almost immediately, add a **short minimum delay and/or** clear English product lines on the boot screen so the layout is not a **single-frame** flash (optional but recommended; document in README if used).
  - Keep boot duration realistic: the coordinator may finish quickly; avoid UI that *requires* a long load to look correct.
  - If helpful for audits, add a one-line note in `README.md` (English) under product description: e.g. “Boot: gradient + top-aligned progress” (optional, not a substitute for actual variance in code).

### 5) Generate per-app remote_url endpoint + random field keyset + README snippet

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
- **Update `apps/<app_name>/马甲包复核说明.md`**：在 **「`remote_url` / 端点定义」** 小节写中文说明，并**粘贴**与 README 相同的**两段 fenced JSON**（随机字段映射 + `remote_url` 响应示例，首项对象）；该内容与生成器在终端打印的 **README snippet 一致，可直接从 step 5 的 stdout 复制**（须含完整 endpoint 字符串；不得依赖“仅见 README”省略示例）。

### 6) iOS Info.plist privacy audit (must include ATT)

- Inspect `apps/<app_name>/pubspec.yaml` for plugins that imply TCC keys.
- Patch `apps/<app_name>/ios/Runner/Info.plist`:
  - MUST include `NSUserTrackingUsageDescription` with a clear English purpose.
  - Add other keys only if actually used by the app/plugins.

### 7) Validation (don’t get stuck)

- **中文复核文件**：打开 `apps/<app_name>/马甲包复核说明.md`，确认三节齐全且为中文：**马甲包功能**（含**除设置外 ≥3 个主区块**说明）、**`remote_url` / 端点定义**（含完整 endpoint 字符串、与 README **同款**的**随机字段映射**与**响应示例 JSON**）、**文生图 App Icon 提示词**。
- **Primary blocks (non-Settings)**: After a cold launch, confirm **at least three** product surfaces are obvious (tabs/sections/destinations), not only one home + Settings.
- **Booting**: Open the app once and confirm the boot screen is **not** a generic single-line `Booting` / bare centered spinner only; it should be clearly different from a template `BootPage` and aligned with the app theme.
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
- **Chinese review doc path**: `apps/<app_name>/马甲包复核说明.md`（确认已含：功能含 ≥3 主区块、`remote_url` 含 endpoint+映射+与 README 一致的**随机响应示例**、文生图 Icon 提示词）
- Confirm **≥3 visible primary product blocks** (excluding Settings) are implemented and documented
- Briefly describe the **Booting** look (layout + motion), or state that it is text-free visual-only
- Where to change endpoint/keyset
- Confirm Info.plist includes ATT key


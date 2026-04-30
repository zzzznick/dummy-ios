---
name: jacket-app-full-build
description: End-to-end workflow to generate a complete Flutter iOS jacket app: create a full English real app with at least five visible primary surfaces (excluding Settings), app_common boot flow with a per-app unique Booting screen, per-app remote_url endpoint (direct string edit; no random key mapping), Chinese review doc 马甲包复核说明.md, iOS Info.plist (ATT), and app icon rules (1:1/满框, cartoon-leaning; app icon MUST use an animal mascot—default random one of 虎牛兔鼠龙). Use for one-shot jacket app build.
---

# One-shot Flutter iOS 马甲包生成（全流程）

## When to use

Use this skill when the user wants **one command / one skill** to finish the entire jacket app setup:
- Create a new app under `apps/`
- Generate a **real, production-like** app experience (not just skeleton) with **≥5 visible primary product blocks** (Settings excluded) per Hard requirements
- Integrate `app_common` boot flow with a **unique Booting** experience per app
- Generate **per-app** `remote_url` endpoint + random field keyset + mapping + response example (**docs are source of truth**; code is **namespaced** under `lib/_<ns>/_<ns>.dart` and MUST NOT contain semantic mapping)
- Ensure iOS `Info.plist` is safe (must include ATT)

## Hard requirements

- **Language**: App UI + page titles + buttons + empty states + settings + README product section MUST be **English only**.
- **Disable Debug banner (mandatory)**:
  - The app MUST set `debugShowCheckedModeBanner: false` on the root `MaterialApp` / `CupertinoApp` so `flutter run` on simulator/device never shows the top-right DEBUG banner.
- **No `remote_url` copy in App UI (mandatory)**:
  - The shipped app UI MUST NOT contain any user-facing copy that mentions: `remote_url`, "remote config", "endpoint", "MockAPI", or displays the endpoint URL.
  - Allowed locations for `remote_url` / endpoint text are **documentation only**: `README.md` and `马甲包复核说明.md`, plus code constants/files under `lib/boot/`.
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
  - You MUST also deliver **at least 5** **visible primary product blocks** *not counting* the Settings entry. A **block** is a distinct, product-meaningful surface the user is expected to use (e.g. a tab, a `NavigationBar`/`TabBar` page, a major dashboard section with its own title + body, a dedicated “guide / lab / list vs map” screen).
  - **Visibility rule (anti–“one home + settings”)**: Do **not** ship a shell where, on a cold start, the only obvious destinations are *one* home-like screen and *Settings* while all other value lives exclusively behind a push route the user may never open. The **5+ blocks** should be **discoverable** without reading README: e.g. **bottom navigation** or **top tabs** with **5 items** (all non-settings), or a **home dashboard** with **5+ clearly separated primary areas** (titles/sections) each navigable in one obvious gesture.
  - **Detail/Edit** may count as one of the five *if* it is clearly exposed (e.g. a tab, or a primary list–detail pattern where the “list” is visibly one of five modes). If Detail is only reachable by tapping a row (still OK for depth), the **other four** must still be **obvious** (tabs / other top-level feature pages).
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
  - **Namespaced code (mandatory)**: `lib/_<ns>/_<ns>.dart`
    - Per-app namespace `<ns>` MUST be **5 lowercase letters** (reuse the remote key prefix).
    - The file MUST NOT contain semantic-field mapping or forbidden tokens (see step 5 blacklist gate).
  - README must include endpoint + **field mapping** + `remote_url` response example (**random keys**; first item is used).
  - The Chinese review doc (`马甲包复核说明.md`) MUST also include the same endpoint + mapping + response example as `README.md` (see “中文复核文档” below).
- **iOS privacy**: `apps/<app>/ios/Runner/Info.plist` MUST include `NSUserTrackingUsageDescription` (ATT).
- **App icon（文生图规范，与 step 3 一致）**：
  - **强制**：launcher / `app_icon` **必须**以**动物**为视觉主体（纯几何、无生命的物体、无动物形象的抽象 logo **不可**作为唯一主体）。
  - 优先 **1:1 方图** 素材、**「满框」**（约 80%+ 画幅、少留白、**完整动物**在景别内、无字无商标），风格 **偏卡通**（3D chibi / 软萌矢量均可，非写实照片堆边）。
  - 若用户/流程**未**指定用哪一种动物，**须从** **虎 / 牛 / 兔 / 鼠 / 龙** 中 **随机恰选一种**作吉祥物；英文 brief 与 `马甲包复核说明.md` 的提示词**必须写出本包选定的动物**及卡通要求。**同一 icon 内只使用一种**动物，不拼五种。
  - 若产品为工具/乐器等，可让动物**与道具互动**（如兔持吉他、龙扶调色盘），但**不得**用非动物形象**替代**动物主体；动物仍须占主视觉。
  - 横版出图落地：**最大内接正方居中裁** 至 1024²；**禁止**大 letterbox 上下条—详见 step 3 的 `sips` 流程。
- **中文复核文档（本流程强制，与 English README 并列）**：
  - 在 `apps/<app_name>/` 下**只使用一个**固定文件：`马甲包复核说明.md`（全中文，便于人工复核）。
  - 该文件必须**统一收录**以下三块内容（可分段，不得拆成多个文档）：
    1. **马甲包功能**：用中文写清产品定位、核心实体、主要页面与交互、与 boot/remote 的衔接方式（读哪些配置、不依赖后端的点）；并**明确列出除设置外至少五个可见主区块**（名称 + 进入方式，与本技能「≥5 visible primary blocks」一致，便于复核）。
   2. **`remote_url` / 端点定义**：用中文写清本包 `remoteConfigEndpoint` 的完整 URL、随机字段 keyset 的用途；并**必须收录与 `README.md` 中 Remote config 节一致的两段技术内容**（仅说明文字可中文，JSON 内键名保持随机串英文）：
      - **字段映射**：与 README 同款的 `### Mapping (random key → semantic field)` 代码块（随机 key → 语义字段）。
      - **响应示例**：与 README 同款的 `### \`remote_url\` response example (first item is used)` 代码块（JSON 数组，首对象含本包随机键名前缀 + 占位值；用于离线核对远端配置）。
      - **须重复写出完整 endpoint 一行 URL**；不得仅写「见 README」而省略上述两段 JSON 示例（复核文件应可**单独打开**即完成 remote 联调参照）。
    3. **文生图 App Icon 文案**：**必须**写动物吉祥物（本包所选**虎/牛/兔/鼠/龙**之一，或 step 3 中明确的单一种动物）+ **偏卡通、满框/1:1 方图**、无字无商标、小尺寸可辨；可与产品道具组合，但**动物为主**。并注明**横图**时**内接方裁、勿大 letterbox**；与 step 3 的英文 icon brief 一致。

## Inputs

Collect from user when provided; otherwise generate reasonable defaults:
- `app_name` (required if user gives; else generate a realistic one)
- Jacket type: tool / game (default random; write into README)
- `remote_url` endpoint (optional; if missing, give a unique placeholder)
- Optional theme (if user specifies, follow it; else random)
- Optional **app icon** preference: user may name **one** of **虎/牛/兔/鼠/龙** (or one specific animal) as mascot; if unspecified, use Hard requirements (**random one of the five** zodiac). Icon **always** features an **animal** (no non-animal-only icons).

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
- Implement the feature set with persistence, including a **main shell** that satisfies **≥5 visible non-Settings primary blocks** (e.g. `NavigationBar` with five destinations, `TabBar`, or a home with five obvious sections each linking to a feature screen—see Hard requirements).
- **Create or update** `apps/<app_name>/马甲包复核说明.md`：先写入 **「马甲包功能」** 小节（中文），覆盖产品功能与页面范围，并**用中文列明**除设置外至少**五个**可见主区块（名称 + 如何进入，如底栏五格 / 首屏五区等），后续步骤会向同一文件追加 `remote_url` 与文生图小节。
- **State + navigation (avoid “stale UI” bugs)**:
  - If a screen uses `ChangeNotifier` / async-loaded model data, **every route that reads live state must subscribe** (e.g. wrap the page in `ListenableBuilder` / `AnimatedBuilder`, or `Provider` + `context.watch`).
  - Parent-only listeners (e.g. home wrapped in `AnimatedBuilder`) do **not** rebuild **pushed** child routes; detail/list pages need their own subscription.
- Produce a clean structure:
  - `lib/app/` (theme/settings)
  - `lib/features/<feature>/...` (pages, models, storage)
  - `lib/boot/` (boot + remote config integration)

### 3) Generate a theme-fitting app icon (automatic)

- **Mascot (required)**: the app icon **must** depict an **animal** as the main subject. **No** “logo-only” or object-only icon without a visible animal.
- **Which animal**:
  1. If the user (Inputs) **named** one of **虎/牛/兔/鼠/龙** or one specific animal, use that **single** species.
  2. Otherwise, **randomly pick exactly one** of **Tiger, Ox, Rabbit, Rat, Dragon** (虎 / 牛 / 兔 / 鼠 / 龙).
  3. You **may** add product-themed props the animal holds or wears (e.g. guitar pick, color drops), but the **animal remains the primary focal subject**.
- State the chosen animal in both the **English** icon brief and the **Chinese** prompts in `马甲包复核说明.md`.
- Create an **English icon brief** (1–3 sentences) and embed these **image-generation rules** in both the brief and the Chinese prompts you write to `马甲包复核说明.md`:
  - **Style**: **Cute 3D chibi** (soft stylized 3D; not photoreal). Optional small props (e.g. product-relevant item in paws) are OK; keep legible at small size.
  - **Output shape**: Request **1:1 square** and **tight “full-bleed” / 满框 composition** (the **animal** + props **fill most of the frame**—e.g. ~80%+ area; **entire** animal **in frame** where possible—ears/tail/limb tips inside the square **unless** a deliberate tighter crop; **minimal** background / soft bokeh in corners only; “app store icon, no letterboxing bands”).
  - **Constraints**: no text, no logo, high contrast, legible at ~64px, edge-safe for iOS squircle (avoid mock phone frames, avoid critical detail only in the extreme corners).
- **Update `apps/<app_name>/马甲包复核说明.md`**: add **「文生图 App Icon 提示词」** with 1–2 copy-pastable **Chinese** prompts: **动物主体**、**本包选定的** **虎/牛/兔/鼠/龙**（或本包指定的一种动物）、**卡通感、1:1、主体满框、少留白、无字无商标**; optional line on pairing with a product prop. Add one line: widescreen exports use **center square crop**, not top/bottom padding (see below).
- **Generate** the art (model/tool may ignore aspect ratio), then **normalize to a 1024×1024 master** at `apps/<app_name>/assets/app_icon.png`:

  1. **Check dimensions** (macOS): `sips -g pixelWidth -g pixelHeight <path>`.
  2. **If already square** (width = height): `sips -z 1024 1024 <source.png> -o apps/<app_name>/assets/app_icon.png` (or your preferred sharp resize).
  3. **If widescreen** (e.g. **1376×768** is common from some image models): do **not** “letterbox to square” with large top/bottom bars—that produces a **thin horizontal band** on the iOS home screen. Instead use the **largest axis-aligned centered square** that fits inside the bitmap—typically **the full height and cropped sides**:
     - For **W×H** with **W > H**: crop **H×H** with **vertical offset 0** and **horizontal offset (W−H)/2**:
       - `sips -c <H> <H> --cropOffset 0 <(W-H)/2> <source.png> -o /tmp/sq.png`
     - For **H > W**, swap the logic (full width, crop top/bottom); offset order follows `sips` on the host.
     - Then: `sips -z 1024 1024 /tmp/sq.png -o apps/<app_name>/assets/app_icon.png`
  4. **Optional**: save the raw wide export as `assets/app_icon_source_wide.png` in the app folder (not required in `pubspec` assets) so the same crop can be re-run without losing the original.
  5. **Tighter crops** (more zoom, less background) **clip** the subject—use only if the product owner explicitly wants to drop edge bokeh; default pipeline above keeps the **full character** in frame.

- **pubspec**:
  - `dev_dependencies: flutter_launcher_icons: ^0.14.3` (or `^0.14.4`)
  - `flutter_launcher_icons:` in `pubspec.yaml`: `image_path: assets/app_icon.png`, iOS+Android; for Android **adaptive** set a **solid** `adaptive_icon_background` (e.g. `#ECEFF1` or a warm tone matching the art) and the same `app_icon` as `adaptive_icon_foreground` if you do not use a split foreground layer.
- Run: `cd apps/<app_name> && flutter pub get && dart run flutter_launcher_icons`

- **README (English)**: one short “App icon” note—**animal mascot required** (default one of the five zodiac or as specified in step 3), square 1024² master, **widescreen = center-crop to square, not letterbox**, then `flutter_launcher_icons` (and optional wide source path, if saved).

### 4) Integrate `app_common` boot flow

- Do NOT reference the repo-level shared module via `../../packages/app_common`.
- Instead, **absorb** `app_common` into the app’s `lib/` so `apps/<app_name>` remains a clean, standalone Flutter project:
  - Create `apps/<app_name>/lib/app_common/` (if missing)
  - Copy **only** `packages/app_common/lib/**` into `apps/<app_name>/lib/app_common/`
- Add required runtime deps as needed by the app’s features (e.g. `shared_preferences`).
- Wire `main.dart` to load settings (if any), then show `BootPage`.
- `BootPage` MUST route to local home builder (the real app Home) via the existing `BootCoordinator` + `RemoteConfigClient` pattern.
- Implement **`BootPage` to satisfy “Booting uniqueness”** in Hard requirements:
  - Pick a **one-off** layout + motion treatment for this app (not reused from the last generated jacket in the same pipeline).
  - If `remote_url` often returns an empty list and navigation completes almost immediately, add a **short minimum delay and/or** clear English product lines on the boot screen so the layout is not a **single-frame** flash (optional but recommended; document in README if used).
  - Keep boot duration realistic: the coordinator may finish quickly; avoid UI that *requires* a long load to look correct.
  - If helpful for audits, add a one-line note in `README.md` (English) under product description: e.g. “Boot: gradient + top-aligned progress” (optional, not a substitute for actual variance in code).

### 5) Generate per-app namespaced boot+remote file + README snippet (with blacklist gate)

Use the generator script from repo root:

```bash
dart run tools/generate_namespaced_boot_remote.dart apps/<app_name> <ns> --force --endpoint <remote_url>
```

Rules:
- **Endpoint is source-of-truth (mandatory)**:
  - The `<remote_url>` passed to `--endpoint` MUST match what you write into `apps/<app_name>/README.md` and `apps/<app_name>/马甲包复核说明.md`.
  - If you regenerate the namespaced file later, you MUST re-run the generator with the **same** `--endpoint` value; otherwise the generated constant will silently point to a placeholder and remote routing will appear “broken”.
- If user didn’t provide `<remote_url>`, generate a unique placeholder like:
  - `https://example.com/remote-config/<app_name>`
- Choose `<ns>` randomly (5 lowercase letters) unless user supplied one. Reuse the same `<ns>` as the remote JSON random-key prefix.
- Generator writes **namespaced** code: `apps/<app_name>/lib/_<ns>/_<ns>.dart` and enforces a **lib/** blacklist gate (must pass).
- Ensure app startup uses the generated entry widget/builder from `lib/_<ns>/_<ns>.dart` (instead of `BootPage → BootCoordinator → RemoteConfigClient` naming).
- Append generator output into `apps/<app_name>/README.md` under a “Remote config (`remote_url`)" section.
- **Update `apps/<app_name>/马甲包复核说明.md`**：在 **「`remote_url` / 端点定义」** 小节写中文说明，并**粘贴**与 README 相同的**两段 fenced JSON**（随机字段映射 + `remote_url` 响应示例，首项对象）；该内容与生成器在终端打印的 **README snippet 一致，可直接从 step 5 的 stdout 复制**（须含完整 endpoint 字符串；不得依赖“仅见 README”省略示例）。

Remote routing parity (must keep behavior consistent with legacy chain):
- `remote_url` response MUST be a JSON array; the **first** object is used.
- If the first object indicates platform:
  - `"1"` → open the **type-1** in-app web container
  - `"2"` → open the **type-2** in-app web container
  - `"3"` → open the target in an **external** browser/app
  - otherwise / missing / empty → stay on **local** shell
- Startup network switching tolerance (mandatory):
  - The generated entry MUST implement **Rule A** network behavior:
    - On cold start, if there is **no network** (`none`), it MUST route to the local shell immediately.
    - After routing to local, it MUST listen for connectivity changes and, on the **first** transition from `none` → available (wifi/mobile/ethernet), it MUST request `remote_url` and apply the platform routing decision (type-1/type-2/external/local).
    - The local-shell listener MUST be one-shot (avoid repeated remote opens on flapping networks).
  - This MUST be implemented without logs and without leaking subscriptions (cancel on dispose).

Attribution bridge (dual JS protocols):
- When the in-app web container is used, the app MUST accept web→native event messages and forward them to attribution SDKs (best-effort, no crashes, no logs).
- Protocol selection MUST follow platform:
  - platform `"1"` (type-1 container): oneview protocol
    - JSON: `{ "name": "<event>", "data": { ... } }`
    - OR raw: `<event>+<payload-json>`
  - platform `"2"` (type-2 container): eventTracker protocol
    - JSON: `{ "eventName": "<event>", "eventValue": { ... } }` (or `eventValue` as a JSON string)
 - Revenue handling (mandatory):
   - The bridge MUST NOT rely on a fixed event-name whitelist for revenue.
   - If payload contains any of `amount`, `af_revenue`, or `price` AND contains a non-empty `currency`, it MUST treat the event as a revenue event:
     - AppsFlyer: MUST log with `af_revenue` and `af_currency` (merge into event payload).
     - Adjust: MUST set revenue via `setRevenue(amount, currency)`.
   - `withdrawOrderSuccess` MUST use negative revenue; other events MUST use positive revenue.

Remote shell parity (demo-aligned, mandatory):
- The in-app web container MUST inject:
  - `window.jsBridge.postMessage(name, data)` that forwards into the namespaced JS channel (best-effort, no crashes).
    - It MUST be compatible with both message entry styles used by legacy WKWebView setups (a structured `{name,data}` payload and a raw `name+json` payload).
  - `window.WgPackage = { name, version }` where both fields are non-empty (name=bundleId/packageName, version=app version).
- Navigation interception MUST match demo intent:
  - `t.me` links MUST be forced to open externally (and prevented from in-app navigation).
  - Popup/new-window navigations (non-main-frame) MUST follow `inAppJump`:
    - `inAppJump == true` → allow in-app navigation
    - otherwise → open externally and prevent in-app navigation
- Web-triggered commands MUST be supported:
  - `openWindow` and `openSafari` MUST be treated as navigation commands and follow the same `inAppJump` decision matrix.
  - `openWindow/openSafari` MUST be handled as navigation commands first (and MUST NOT crash). They SHOULD NOT be forwarded to attribution tracking as normal events.

Remote shell UI (mandatory):
- The in-app web container MUST NOT show any title text in the navigation bar / AppBar (no fixed strings like "Workspace", "Browse", etc.).
- Prefer **no `AppBar`**. If an `AppBar` is necessary, it MUST be titleless (e.g. `title: SizedBox.shrink()`).
- The in-app web container MUST render the top and bottom safe areas with a **black** background using **container-only** widget structure (e.g. `Scaffold(backgroundColor: Colors.black)` + `ColoredBox(color: Colors.black)` + `SafeArea`).
- Do NOT rely on `SystemChrome` / `SystemUiOverlayStyle` as the default approach for this constraint.

No logs in lib/ (mandatory):
- `apps/<app_name>/lib/**.dart` MUST NOT contain any print/log calls or logging libraries usage.
- Forbidden tokens (minimum set): `print(`, `debugPrint(`, `developer.log(`, `Logger(`.
- Also avoid logger method patterns when used for output: `.i(`, `.w(`, `.e(`.

### 6) iOS Info.plist privacy audit (must include ATT)

- Inspect `apps/<app_name>/pubspec.yaml` for plugins that imply TCC keys.
- Patch `apps/<app_name>/ios/Runner/Info.plist`:
  - MUST include `NSUserTrackingUsageDescription` with a clear English purpose.
  - Add other keys only if actually used by the app/plugins.

### 7) Validation (don’t get stuck)

- **中文复核文件**：打开 `apps/<app_name>/马甲包复核说明.md`，确认三节齐全且为中文：**马甲包功能**（含**除设置外 ≥5 个主区块**说明）、**`remote_url` / 端点定义**（含完整 endpoint 字符串、与 README **同款**的**随机字段映射**与**响应示例 JSON**）、**文生图 App Icon 提示词**（**必须为动物**、标明**虎/牛/兔/鼠/龙**中本包选用的一种或指定动物、**可爱 3D chibi**+**满框/1:1**、**横图内接方裁、勿大 letterbox**；与 step 3 一致）。
- **App icon 文件**：`sips -g pixelWidth -g pixelHeight apps/<app_name>/assets/app_icon.png` 应为 **1024×1024**；若用横版母图，确认未用上下条带 letterbox 生成该文件。
- **Primary blocks (non-Settings)**: After a cold launch, confirm **at least five** product surfaces are obvious (tabs/sections/destinations), not only one home + Settings.
- **Booting**: Open the app once and confirm the boot screen is **not** a generic single-line `Booting` / bare centered spinner only; it should be clearly different from a template `BootPage` and aligned with the app theme.
- Manually sanity-check **one interactive loop per main screen** (tap toggles, save, navigate away/back) so “notifyListeners but UI stuck until pop” issues are caught early.
- Manually sanity-check Settings:
  - Changing each setting updates UI immediately and persists after app restart.
  - Settings options and layout are clearly **theme-specific** and do not look like the previous app’s Settings.
- Always run: `cd apps/<app_name> && flutter test`.
- Remote routing sanity-check (if remote is configured):
  - Set MockAPI first item to `{ "<ns>Plaf": "1", "<ns>Ur": "https://example.com" }` and confirm the app routes into the in-app container.
- Attribution bridge sanity-check (if remote is configured):
  - For platform `"1"` container, send oneview messages from web and confirm native receives them (no logs in code; use functional behavior checks).
  - For platform `"2"` container, send eventTracker messages from web and confirm native receives them (no logs in code; use functional behavior checks).
  - Revenue sanity-check:
    - Ensure the generated namespaced file derives revenue from payload keys (not only event-name whitelist):
      - `rg -n \"payload\\['amount'\\] \\?\\? payload\\['af_revenue'\\] \\?\\? payload\\['price'\\]\" apps/<app_name>/lib/_<ns>/_<ns>.dart`
    - Ensure negative revenue handling remains for withdrawals:
      - `rg -n \"withdrawOrderSuccess\\'\\) \\? -\" apps/<app_name>/lib/_<ns>/_<ns>.dart`
- No-logs sanity-check (mandatory):
  - Run from repo root: `rg -n \"print\\(|debugPrint\\(|developer\\.log\\(|Logger\\(\" apps/<app_name>/lib`
- Remote shell parity sanity-check (mandatory):
  - From repo root, ensure generated namespaced file contains required tokens (no semantic mapping involved):
    - `rg -n \"window\\.jsBridge|jsBridge\\.postMessage|window\\.WgPackage|onNavigationRequest|isMainFrame|openWindow|openSafari|t\\.me\" apps/<app_name>/lib/_<ns>/_<ns>.dart`
  - Ensure `openWindow/openSafari` are treated as commands (not only attribution events):
    - `rg -n \"openWindow|openSafari\" apps/<app_name>/lib/_<ns>/_<ns>.dart`
- Endpoint sanity-check (mandatory):
  - Ensure the generated constant endpoint matches docs (avoid placeholder override):
    - `rg -n \"^const String <ns>0 = 'https?://\" apps/<app_name>/lib/_<ns>/_<ns>.dart`
    - Compare with the endpoint line in `apps/<app_name>/README.md` and `apps/<app_name>/马甲包复核说明.md` (they MUST match exactly).
- Optional: `flutter build ios --no-codesign`.
  - If build hangs at `pod install` for too long, stop waiting and finish with:
    - Verified `Info.plist` contains required keys (especially ATT).
    - Verified app tests pass.

## Output expectations

After completion, summarize:
- App path: `apps/<app_name>/`
- What product was generated (English name + one-liner)
- **Chinese review doc path**: `apps/<app_name>/马甲包复核说明.md`（确认已含：功能含 ≥5 主区块、`remote_url` 含 endpoint+映射+与 README 一致的**响应示例**、文生图 Icon **动物吉祥物**+**虎牛兔鼠龙择一**或指定动物+**可爱 3D chibi**+**满框/1:1**）
- Confirm **≥5 visible primary product blocks** (excluding Settings) are implemented and documented
- Briefly describe the **Booting** look (layout + motion), or state that it is text-free visual-only
- Where to change endpoint
- Confirm Info.plist includes ATT key


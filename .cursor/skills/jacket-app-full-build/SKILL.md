---
name: jacket-app-full-build
description: End-to-end workflow to generate a complete Flutter iOS jacket app: create a full English real app with three to five visible primary surfaces (excluding Settings), app_common boot flow with a per-app unique Booting screen, per-app remote_url endpoint + namespaced keys, Chinese review doc 马甲包复核说明.md, iOS Info.plist (ATT), app icon rules, and mandatory manual verification that every shipped feature path runs without runtime errors before handoff. Random themes must be mainstream and self-explanatory (name + tabs), not opaque metaphors. Use for one-shot jacket app build.
---

# One-shot Flutter iOS 马甲包生成（全流程）

## When to use

Use this skill when the user wants **one command / one skill** to finish the entire jacket app setup:
- Create a new app under `apps/`
- Generate a **real, production-like** app experience (not just skeleton) with **3–5 visible primary product blocks** (Settings excluded; exact count within that range per Hard requirements)
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
- **Mainstream clarity (random themes — mandatory when user did not specify a theme)**:
  - Random products MUST be **immediately understandable** to a general App Store user: within **~3 seconds**, the **display name + bottom-nav labels (or first-screen section titles)** should make the **job-to-be-done** obvious **without** reading README.
  - Prefer **plain English** category words users already search for: e.g. *Timer*, *Converter*, *Checklist*, *Kitchen*, *Colors*, *Noise*, *Packing*, *Tips*, *Calculator*, *Flashcards*, *Quotes*, *Breathing*, *Metronome*, *Ruler*, *Budget* (subject to other constraints), *Plants* (care, not mood journaling), etc.
  - **Discourage** opaque or poetic codenames, niche hobby jargon, or metaphor-only brands when no user theme is given (examples of what to **avoid** for random generation: names that read like lore titles, geology/mining metaphors, or invented compound words where the category is unclear—e.g. a random user cannot tell *Ore Vein* is a mineral desk from the name alone).
  - If a slightly distinctive brand is desired, pair it with **clear category anchoring** in the **first visible UI** (e.g. subtitle on home, section headers, or tab labels that spell out the use case in common vocabulary—not internal codenames).
- **Theme randomness**: If user didn’t specify a theme, **randomly generate a theme** that satisfies **Mainstream clarity** above (not only “unique”).
- **Diversity**: Random theme MUST be a distinct product type and **NOT** a journal/tracker/check-in app.
  - Home information architecture MUST NOT be “linear list + FAB”.
  - Core entity/model MUST be meaningfully different from prior generated apps.
- **Offline-first**: No backend required. Everything works locally.
- **Minimum pages + visible primary blocks (Settings excluded from the count)**:
  - You MUST still have **Settings** (full screen or equivalent) and **at least one** **Detail/Edit** (or editor) for the core entity when the product has a natural list–detail or editor flow.
  - You MUST deliver **between 3 and 5** (**inclusive**) **visible primary product blocks** *not counting* the Settings entry. A **block** is a distinct, product-meaningful surface the user is expected to use (e.g. a tab, a `NavigationBar`/`TabBar` page, a major dashboard section with its own title + body, a dedicated “guide / lab / list vs map” screen). **Prefer 5** when the concept clearly supports five distinct jobs; **3–4** is allowed when fewer tabs/sections would stay clearer—**never fewer than 3**, **never more than 5**.
  - **Visibility rule (anti–“one home + settings”)**: Do **not** ship a shell where, on a cold start, the only obvious destinations are *one* home-like screen and *Settings* while all other value lives exclusively behind a push route the user may never open. The **3–5 blocks** should be **discoverable** without reading README: e.g. **bottom navigation** or **top tabs** with **3–5 items** (all non-settings), or a **home dashboard** with **3–5 clearly separated primary areas** (titles/sections) each navigable in one obvious gesture.
  - **Detail/Edit** may count toward the **3–5** *if* it is clearly exposed (e.g. a tab, or a primary list–detail pattern where the “list” is visibly one of the primary modes). If Detail is only behind a row tap (still OK for depth), **top-level** discoverable blocks (tabs / dashboard sections) alone must still number **3–5**; the pushed editor does **not** substitute for missing top-level destinations.
- **Implied by above**: *Home* (or first tab) is typically block #1; add **enough** top-level or equally visible surfaces to reach **at least 3 and at most 5** non-settings primary blocks, then keep **Settings** separate (often an app-bar action, not a hidden-only route).
- **Settings uniqueness (avoid same UI across apps)**:
  - The Settings screen MUST include **at least 2 settings that are specific to the app’s product concept** (not just theme color + reset).
  - The Settings screen layout MUST NOT be a copy of prior generated apps (avoid the same “Appearance seed color chips + Reset all data + About” structure).
  - Use **different widgets/structure** when possible (e.g. segmented control, sliders, reorderable preferences, preview cards, import/export, default behaviors) and tie them to persisted settings.
- **Persistence**: Use light persistence (`shared_preferences` or JSON file). Must persist both user data and settings.
- **Feature verification (mandatory — 全功能可跑通)**:
  - Delivery is **not complete** until **every user-visible product capability** shipped in this app has been **verified working** end-to-end: **no uncaught exceptions**, no red Flutter error screen, and no broken primary action (button/save/dialog/navigation) on the happy path.
  - **Minimum scope (must all pass)**:
    - **Cold start → Boot gate → local shell** (or remote container if you intentionally test that branch).
    - **Each of the 3–5 primary blocks** shipped for this app (excluding Settings): open, perform **one real interaction loop** appropriate to that screen (e.g. toggle, add item, navigate sub-route, timer start/stop).
    - **Settings / equivalent**: change **every** persisted control at least once; **kill and relaunch** the app once and confirm values **stick** (`shared_preferences`/JSON parity).
    - **Detail / Editor** (if present): open from its intended entry, edit/save/back; confirm list or parent reflects updates without stale UI (subscribe where needed — Execution step §2「State + navigation」).
    - **Any dialogs / sheets** tied to core data (rename, confirm delete, permission-adjacent flows): open, confirm **and** dismiss without controller/dispose crashes.
  - **Anti-pattern**: Treating **`flutter test` + rg checks** alone as “done” **without** at least **one simulator or device run** covering the bullets above when the toolchain allows (`flutter run`). If you truly cannot run the UI (headless blocker), say so explicitly in the handoff and still fix any reproducible crashes from logs the user sends.
  - **Handoff**: The completion summary MUST state that **functional verification passed** for the above scope, **or** list **remaining defects** plus what was fixed before close.
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
- **App icon（与 step 3 一致；供图或自动生成二选一主干）**：
  - **供图优先**：若 Inputs 提供 **`icon_image_path`（或同义：`app_icon_source_path`、`launcher_icon_image`）** — 指向可用的 **PNG / JPEG / WebP / HEIC（若宿主可转）** 文件（工作区内相对路径或绝对路径），则 **不进行文生图/模型出图**：以该文件为唯一母本，经 step 3 的尺寸检查与 **`sips` 裁切缩放** 落盘为 **`apps/<app_name>/assets/app_icon.png`**（1024²），并将 **原始拷贝**保存为 **`assets/app_icon_source_master.png`**（或保留用户原始文件名记入文档）。须在 README 与 **`马甲包复核说明` 第三节** 标明 **Provided / 产品方供图** 及相对仓库的路径或文件名；**目视核对**吉祥物仍符合 **虎/牛/兔/鼠/龙** 五项硬规范且动物为主画面；若不满足须拒绝使用该图或与用户澄清后更换。**供图模式下画风轮盘**在文档中可标为 **`User-provided artwork`**（或一句中文「供图，非流程内文生图」），不必伪造文生图提示词。
  - **自动生成**：未供图时沿用下文文生图、画风轮盘与五项物种规则。
  - **强制**：最终 launcher / `app_icon` **必须**以**动物**为视觉主体（纯几何、无生命的物体、无动物形象的抽象 logo **不可**作为唯一主体）。
  - 优先 **1:1 方图** 素材、**「满框」**（约 80%+ 画幅、少留白、**完整动物**在景别内、无字无商标）。整体须 **图标可读**：高对比轮廓、避开极端圆角盲区；**非**主推写实野生动物摄影。
  - **风格多样化（Mandatory）**：**每个马甲包须单独选定一种画风预设**，与 README、`马甲包复核说明.md` 写清（可用英文 style label + 中文一句解释）。**禁止**让「可爱 3D chibi」成为所有包的**唯一/默认套用**话术；也不得连续多包重复使用**完全相同**的文生图风格描述。**须从下文「画风轮盘」中选且仅选一种**，除非用户在 Inputs 里**明确点名**某一种画风（则服从用户）。
  - **吉祥物物种（硬规范，不得放宽）**：**必须且只能从** **虎 / 牛 / 兔 / 鼠 / 龙** 中 **选出恰好一种** 作为 icon 的动物主体（对应英文 Tiger / Ox / Rabbit / Rat / Dragon；龙为神话龙形象）。  
    - 若用户未命名：从文生图流程角度 **随机** 选一。  
    - 若用户在 Inputs 中点名物种：**仍须**隶属于上述五项之一（不可用猫、狐狸、猫头鹰等非列表物种）。  
    - **严禁**「扩展动物池」「任意物种」写法覆盖本硬规范。**同一 icon 内只使用一种**动物主体。
  - 若产品为工具/乐器等，可让动物**与道具互动**（如兔持鼓槌、龙扶调色盘），但**不得**用非动物形象**替代**动物主体；动物仍须占主视觉。
  - 横版出图落地：**最大内接正方居中裁** 至 1024²；**禁止**大 letterbox 上下条—详见 step 3 的 `sips` 流程。
  - **画风轮盘（Wheel — 每包选 1）**：生成时从文生图可用的下列预设中挑一种（可随机，但须落文档；与上一生成的马甲包尽量不撞同一预设）：
    1. **Soft 3D / chibi resin** · 软化 3D 搪胶玩偶感  
    2. **Bold flat vector / sticker** · 粗线扁平矢量贴纸风  
    3. **Pastel squish 2.5D** · 圆润粉彩轻体积插画  
    4. **Gouache storybook wash** · 水粉绘本质感（块面清晰勿糊成照片）  
    5. **Geometric mascot** · 简练几何拼图式动物（仍须一眼可读为动物）  
    6. **Linocut / limited-palette stamp** · 版画刻痕 + 限量色  
    **不推荐**：超长毛写实摄影主体、细线密集仅在角标才看得清的纹理。
- **中文复核文档（本流程强制，与 English README 并列）**：
  - 在 `apps/<app_name>/` 下**只使用一个**固定文件：`马甲包复核说明.md`。**主体复核文字使用中文**；其中 **第四块「App Store 提交用英文文案」必须整段英文**（仅此块英文，便于直接粘贴 App Store Connect），不得夹中文释义污染可粘贴段落。
  - 该文件必须**统一收录**以下**四**块内容（可分段编号，不得拆成多个文档）：
    1. **马甲包功能**：用中文写清产品定位、核心实体、主要页面与交互、与 boot/remote 的衔接方式（读哪些配置、不依赖后端的点）；并**明确列出除设置外三至五个可见主区块**（名称 + 进入方式，与本技能「3–5 visible primary blocks」一致，便于复核）。
   2. **`remote_url` / 端点定义**：用中文写清本包 `remoteConfigEndpoint` 的完整 URL、随机字段 keyset 的用途；并**必须收录与 `README.md` 中 Remote config 节一致的两段技术内容**（仅说明文字可中文，JSON 内键名保持随机串英文）：
      - **字段映射**：与 README 同款的 `### Mapping (random key → semantic field)` 代码块（随机 key → 语义字段）。
      - **响应示例**：与 README 同款的 `### \`remote_url\` response example (first item is used)` 代码块（JSON 数组，首对象含本包随机键名前缀 + 占位值；用于离线核对远端配置）。
      - **须重复写出完整 endpoint 一行 URL**；不得仅写「见 README」而省略上述两段 JSON 示例（复核文件应可**单独打开**即完成 remote 联调参照）。
    3. **App Icon 文案**：**自动生成时**：视同 **「文生图 App Icon」** — **必须**写 **(a)** 五项吉祥物中之哪一类、**(b)** **画风轮盘** 条目；并写 **满框/1:1**、无字无商标等；可加 1–2 条可复制中文提示。**产品方供图时**：免写虚构文生图提示；**必须**写 **(a)** 确认的物种 **(虎/牛/兔/鼠/龙)**、**(b)** 图源标识（供图 / 路径或文件名）、**(c)** 实际画面简述（中英文 brief 中与 README 一致）；仍须备注横图落地的 **内接方裁** 规则。
    4. **App Store 提交用英文文案（必选，整块英文）**：为便于 App Store Connect 提交，单列一小节（建议标题：`## App Store listing (English—copy-ready)`），**本节内不出现中文** （节前可用一行中文标注用途，如「以下供 App Store Connect 粘贴」）；须包含可复制粘贴的占位已填好的以下内容（英文撰写，贴合本包真实功能，禁用 `remote_url` / MockAPI / 未实现能力）：
      - **Promotional Text**：对应 ASC 字段 *Promotional Text*；**至多 170 字符**（含空格与标点），可换行但以提交框内连续文本形式给出。
      - **Description**：对应 *Description*；**至多约 4000 字符**，分段落说明产品价值与主要特性（与 app 内真实页面对齐）。
      - **Keywords**：对应 *Keywords*；**至多 100 字符**，逗号分隔英文关键词词条，无多余空格为佳，禁用竞争对手名称与无关词堆砌。
      - **Copyright**：对应 *Copyright*；一行版权声明，形如 `© 2026 Developer or Company Name`（若未知主体可写占位 `© 2026 Rights Holder`，并在中文说明中备注上线前替换为真实权利人）。

## Inputs

Collect from user when provided; otherwise generate reasonable defaults:
- `app_name` (required if user gives; else generate a realistic one)
- Jacket type: tool / game (default random; write into README)
- `remote_url` endpoint (optional; if missing, give a unique placeholder)
- Optional theme (if user specifies, follow it; else random)
- Optional **`icon_image_path`** (also accept aliases **`app_icon_source_path`**, **`launcher_icon_image`**): filesystem path to a **raster image** to use **as-is** after normalization (square crop + resize) for **`assets/app_icon.png`**. When set, **do not run text-to-image** for the icon branch; validate visually that subject matches **Tiger / Ox / Rabbit / Rat / Dragon** only. Preserve original as **`assets/app_icon_source_master.png`** (or equivalent) and cite path in README + `马甲包复核说明`.
- Optional **app icon** preference (when **not** supplying `icon_image_path`): user may name **one** of **虎/牛/兔/鼠/龙** (or its English counterpart) **and/or** **one style wheel preset** (1–6 or its English label); if species unspecified, use Hard requirements (**random one of those five animals + random wheel preset**, avoiding repeating the exact same preset as the immediately prior jacket in this repo when practical). Icon **always** depicts **exactly one** mascot from **only** **Tiger, Ox, Rabbit, Rat, Dragon** (hard rule—no cats, foxes, etc.).

## Execution steps (do in order)

### 1) Create the app project

- Ensure `apps/<app_name>/` doesn’t exist.
- If the user didn’t provide an `app_name`, generate:
  - folder name: lower_snake_case (2–3 words) like `kitchen_convert`, `pack_pal`, `hue_studio` (prefer **category-evident** roots over abstract metaphors).
  - product name: Title Case (1–3 words) that a stranger can map to a store category, e.g. "Kitchen Convert", "Pack Pal", "Hue Studio" (see Hard requirements **Mainstream clarity**).
- Run: `flutter create apps/<app_name>`.

### 2) Build the “real app” (English-only)

- Decide random product concept (must satisfy diversity constraints **and** Hard requirements **Mainstream clarity**). When the user did not supply a theme, **pick from familiar “utility / hobby desk” categories** (cooking math, intervals, color tools, packing/travel lists, study sounds, tip calculators, offline reference decks, metronome/tuner-adjacent tools, etc.)—**not** niche subcultures that need domain knowledge to interpret the title.
- **Self-test before building UI**: ask “Would my non-expert relative guess what this app does from **name + primary navigation labels (about 3–5)** alone?” If **no**, revise the name and/or tab labels until **yes**, without violating the anti–journal/tracker/check-in rule.
- Create a coherent UI system:
  - Material 3 theme with consistent color scheme.
  - Empty states, form validation, dialogs/snackbars.
- Implement the feature set with persistence, including a **main shell** that satisfies **3–5 visible non-Settings primary blocks** (e.g. `NavigationBar` with three to five destinations, `TabBar`, or a home dashboard with three to five obvious sections each linking to a feature screen—see Hard requirements).
- **Create or update** `apps/<app_name>/马甲包复核说明.md`：先写入 **「马甲包功能」** 小节（中文），覆盖产品功能与页面范围，并**用中文列明**除设置外**三至五个**可见主区块（名称 + 如何进入，如底栏三至五格 / 首屏三至五区等），后续步骤会向同一文件追加 **`remote_url`、App Icon 小节**（文生图或供图说明），并在收尾追加 **整块英文** 的 **App Store Promotional Text / Description / Keywords / Copyright**（见 Hard requirements 第四块与 §7）。
- **State + navigation (avoid “stale UI” bugs)**:
  - If a screen uses `ChangeNotifier` / async-loaded model data, **every route that reads live state must subscribe** (e.g. wrap the page in `ListenableBuilder` / `AnimatedBuilder`, or `Provider` + `context.watch`).
  - Parent-only listeners (e.g. home wrapped in `AnimatedBuilder`) do **not** rebuild **pushed** child routes; detail/list pages need their own subscription.
- Produce a clean structure:
  - `lib/app/` (theme/settings)
  - `lib/features/<feature>/...` (pages, models, storage)
  - `lib/boot/` (boot + remote config integration)

### 3) App icon — **import user image** OR **generate** (automatic)

#### 3a) If **`icon_image_path`** (or accepted alias) is provided in Inputs

- **Resolve path** (workspace-relative or absolute); verify file exists and is readable.
- **Optional format note**: Prefer **PNG or JPEG**. If tooling cannot read exotic formats on the host, convert once to PNG before resizing (no quality loss beyond source).
- **Copy original** into the app folder as **`assets/app_icon_source_master.png`** whenever possible (overwrite if re-run); if keeping another extension, write the canonical name README uses.
- **Normalize** exactly as in **§3b steps 1–5** (`sips` dimension check → center square crop when non-square → **`sips -z 1024 1024`** → output **`assets/app_icon.png`**). **Never** satisfy square by adding large letterbox bands on top/bottom.
- **Launcher assets**: after `assets/app_icon.png` is finalized, apply **pubspec** `flutter_launcher_icons` stanza below and run `cd apps/<app_name> && flutter pub get && dart run flutter_launcher_icons`.
- **Docs**: README “App icon” + **`马甲包复核说明` 第三节** — state **provided asset**, repo-relative path, confirmed **five-species** mascot, **`User-provided artwork`** for style preset; omit fake **text-to-image** prompts unless you need internal audit stubs (prefer honest “不适用” + 实拍描述).

#### 3b) If **no** `icon_image_path` — generated artwork path

- **Mascot (required)**: the app icon **must** depict an **animal** as the main subject. **No** “logo-only” or object-only icon without a visible animal.
- **Which animal（hard gate）**:
  1. Mascot **must** be **exactly one** of **Tiger, Ox, Rabbit, Rat, Dragon** (虎 / 牛 / 兔 / 鼠 / 龙). No other species.
  2. If the user (Inputs) **named** one of those five → use that mascot only (reject requests for any other creature).
  3. Otherwise, **randomly pick exactly one** of the five.
  4. You **may** add product-themed props the animal holds or wears (e.g. drumsticks, color drops), but the **animal remains the primary focal subject**.
- **Which art style**: pick **exactly one** **style wheel preset** per app (Hard requirements): state it in **English README** + **`马甲包复核说明.md`** (preset name + short Chinese gloss). Prefer **not** cloning the prior jacket app’s preset in this workspace when generating back-to-back, unless user asked for parity.
- State the chosen **animal** and **style preset** in both the **English** icon brief and the **Chinese** prompts in `马甲包复核说明.md`.
- Create an **English icon brief** (2–4 sentences) that ties **animal + preset + product prop** together, and mirror the constraints below in **`马甲包复核说明.md`**:
  - **Style execution**: Describe the **chosen wheel preset explicitly** (e.g. “bold flat sticker vector…” / “limited-palette linocut…”); **avoid** vague copy-paste of “generic cute 3D” unless preset (1) is intentionally selected.
  - **Output shape**: Request **1:1 square** and **tight “full-bleed” / 满框 composition** (the **animal** + props **fill most of the frame**—e.g. ~80%+ area; **entire** animal **in frame** where possible—ears/tail/limb tips inside the square **unless** a deliberate tighter crop; **minimal** background / soft bokeh in corners only; “app store icon, no letterboxing bands”).
  - **Constraints**: no text, no logo, high contrast, legible at ~64px, edge-safe for iOS squircle (avoid mock phone frames, avoid critical detail only in the extreme corners).
- **Update `apps/<app_name>/马甲包复核说明.md`**: for **generated** icons, add **「文生图 App Icon 提示词」** with 1–2 copy-pastable **Chinese** prompts (**动物主体**、**画风轮盘**、满框/no letterbox hints). For **provided** icons, substitute **图源 / 性状描述** instead of fabricated prompts—see Hard requirement block 第三项。
- **Generate** the art (only when §3b; model/tool may ignore aspect ratio), then **normalize to a 1024×1024 master** at `apps/<app_name>/assets/app_icon.png` (same pipeline as §3a after the art export):

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

- **README (English)**: one short “App icon” note—**animal mascot required: exactly one of Tiger / Ox / Rabbit / Rat / Dragon** (user-named, random when generated, or **must visibly match one** when using **`icon_image_path`**); cite either **provided image path / “user-provided”** or **`named style wheel preset`** when generated; square 1024² master via **crop + resize**, then `dart run flutter_launcher_icons` (and optional `assets/app_icon_source_master.png`).

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
- **同一文件须在交付前补齐**第四节 **English App Store listing**（见 Hard requirements 第 4 块）：若在 step 3 之后才最终确定产品名或卖点，可于此时一次性写入；**本节英文须与上架 app 一致**，不得虚假宣传。

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

- **Mandatory — full feature smoke (必须与 Hard requirements「Feature verification」一致)**  
  Before marking the jacket **done**, run **`flutter run`** (simulator or device) unless impossible, and execute a **written checklist** for this specific app — at minimum:
  1. Cold launch: Boot → enters shell **without red screen**.
  2. Visit **every bottom-nav / primary destination** listed in README / `马甲包复核说明`; one meaningful gesture per destination.
  3. Open **Settings** (or equivalent); toggle/adjust **each** persisted option; force-quit and relaunch → **values restored**.
  4. If app has **list → detail/editor**: repeat open / edit / save / back → parent list not stale (`ListenableBuilder` / Provider where needed).
  5. Any **dialog + TextEditingController**: confirm/save/dismiss paths **without** disposing the controller before the dialog subtree unmounts (prefer `StatefulWidget` dialog state owning the controller).
  6. If **Bloom / animations / IndexedStack-heavy** UI: swap tabs repeatedly after async saves to catch disposed-listenable / tween churn bugs.
  - Record in the chat handoff: **“Feature smoke passed”** or **what failed and how it was fixed** — not optional.

- **中文复核文件**：打开 `apps/<app_name>/马甲包复核说明.md`，确认 **四** 节齐备：**马甲包功能**（中文；含 **3–5** 个非设置主区块）、**`remote_url` / 端点定义**（中文叙述 + endpoint 一行 + 与 README **同款** Mapping / 示例 JSON）、**第三节 App Icon** — **自动生成**须含画风轮盘 + 可复制中文提示；**供图（`icon_image_path`）**须载明物种 / 图源 / 简述，免虚构 prompts；以及 **App Store listing（整块英文可复制）**：含四项字段 **Promotional Text**（≤170 字符）、**Description**（≤4000）、**Keywords**（≤100）、**Copyright**（一行）；英文段内不得夹杂中文正文（节首允许单独一行中文用途说明）。
- **App icon 文件**：`sips -g pixelWidth -g pixelHeight apps/<app_name>/assets/app_icon.png` 应为 **1024×1024**；若用横版母图，确认未用上下条带 letterbox 生成该文件。若 Inputs 使用了 **`icon_image_path`**：确认 **`assets/app_icon_source_master.png`**（或文档声明的等价备份）存在，且 README / 复核说明中的 **图源** 可追溯。
- **Primary blocks (non-Settings)**: After a cold launch, confirm **three to five** product surfaces are obvious (tabs/sections/destinations), not only one home + Settings.
- **Booting**: Open the app once and confirm the boot screen is **not** a generic single-line `Booting` / bare centered spinner only; it should be clearly different from a template `BootPage` and aligned with the app theme.
- **Per-screen loops** (duplicate purpose — now required above): catches “notifyListeners but UI stuck until pop”; do not skip Save/Delete dialogs.
- Settings spot-check aligns with §Hard **Feature verification**: immediate UI + persistence after restart; layout still **theme-specific**.
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
- What product was generated (English name + one-liner), and **one line** confirming **Mainstream clarity**: why a stranger would understand the app from **name + primary navigation labels** alone
- **Feature verification**: explicit line — **Functional smoke passed** on simulator/device covering **every primary block + Settings (all persisted fields) + detail/editor + critical dialogs**, **or** list defects fixed / known limitations + whether `flutter run` was blocked.
- **Chinese review doc path**: `apps/<app_name>/马甲包复核说明.md`（确认已含：中文三节 + **English App Store** 整块：**Promotional Text / Description / Keywords / Copyright**；以及功能 **3–5** 个主区块、`remote_url` 两段 JSON、第三节 **虎牛兔鼠龙之一** — **自动生成**则画风轮盘 + 可复制提示 / **供图**则图源说明）
- Optional: **Icon source** noted — **provided** (`icon_image_path`) vs **generated**
- Confirm **3–5 visible primary product blocks** (excluding Settings) are implemented and documented
- Briefly describe the **Booting** look (layout + motion), or state that it is text-free visual-only
- Where to change endpoint
- Confirm Info.plist includes ATT key


## Context

现状：
- `tools/generate_namespaced_boot_remote.dart` 已为每个马甲包生成 namespaced 入口与两类远程壳（platform `"1"`/`"2"`），并实现：
  - 远程 `remote_url` 读取与 platform 分流（`"1"`/`"2"` 壳内、`"3"` 外开）
  - 无标题、容器黑底安全区（不使用 `SystemChrome`）
  - 归因桥接（Adjust/AppsFlyer）与两种 JS 协议（oneview / eventTracker）
  - no-logs 与 blacklist gate（禁止 `print(`/`debugPrint(` 等，以及语义字段/统一特征）

问题：
- demo 的 WKWebView 还有一组“壳行为细节”未在 Flutter namespaced 壳中对齐，核心集中在：
  - 文档起始注入 `jsBridge.postMessage` 与 `WgPackage`（bundleId + version）
  - `openWindow/openSafari` 跳转路径与 `inAppJump` 决策
  - 新窗口（`targetFrame == nil` / `window.open`）的处理：`t.me` 强制外开，其余随 `inAppJump`

约束：
- 生成代码仍需满足：namespaced、无标题、黑底安全区、no-logs、blacklist gate 不回退。
- 不在代码中引入语义映射字段（mapping 只允许在文档）。
- 保持 best-effort：任何 web→native 消息/拦截处理不得导致崩溃。

## Goals / Non-Goals

**Goals:**
- 在 namespaced 远程壳中补齐 demo 的 WebView parity 行为：
  - documentStart 注入 `jsBridge.postMessage`
  - documentStart 注入 `WgPackage`
  - `openWindow/openSafari` 事件的打开策略（壳内/外开）与 `inAppJump` 一致
  - 新窗口/外链拦截策略与 `t.me` 强制外开
- 行为落地到 generator，确保后续所有马甲包一致具备该 parity。
- 为 `jacket-app-full-build` 增补可操作的验收清单（grep/单测/逻辑自检）。

**Non-Goals:**
- 不改变现有 remote_url 字段 keyset / mapping 机制（仍以文档为准，代码不出现语义字段）。
- 不引入新的 WebView 插件或大规模重构壳架构（以 `webview_flutter` 现有能力实现）。
- 不在壳内增加任何可见 UI（标题栏/工具栏/调试视图等）。

## Decisions

### 1) JS 注入采用 `WebViewController.runJavaScript` + documentStart 等效策略

**Decision:**
- 在 WebView 初次加载前/后，通过 `WebViewController.runJavaScript` 注入两段脚本：
  - `window.jsBridge.postMessage(name, data)`：把消息转发到既有 JS channel（保持 namespaced 通道名），并兼容两条入口（`Post`/`event`）的 payload 形式。
  - `window.WgPackage = { name, version }`：name=packageName/bundleId，version=应用版本号（Flutter 端通过 `package_info_plus` 或平台 channel 获取；若当前工程已存在等价来源则复用）。

**Rationale:**
- WKWebView 使用 `WKUserScript` 在 documentStart 注入；Flutter WebView 不保证完全等价的注入时机，但对 parity 来说目标是“页面 JS 能拿到对象并调用”，在首次 `loadRequest` 后尽快注入即可。

**Alternatives considered:**
- 使用 `webview_flutter` 的 `JavaScriptChannel` 仅接收消息、不注入对象：会导致页面侧依赖 `jsBridge/WgPackage` 的逻辑失效。
- 额外引入自定义 WebView wrapper：会扩大依赖面，降低审查友好性。

### 2) `openWindow/openSafari` 统一通过现有 web→native 事件桥处理

**Decision:**
- 在 attribution/bridge 的消息解析后，新增对事件名 `openWindow` 与 `openSafari` 的识别：
  - 从 payload 中读取 `url`（若 payload 不是 map 或 url 为空则忽略）
  - 打开策略：
    - 若 `inAppJump == true`：在当前壳内 `controller.loadRequest(url)`
    - 否则：`url_launcher` 外部打开
  - `t.me`：无论 `inAppJump`，均外部打开并返回 `prevent`（与 demo 一致）

**Rationale:**
- demo 把 `openWindow` 当作“跳转命令”而非归因事件；Flutter 侧将其并入已有消息通道，既能保持单通道与 namespacing，又能复用现有 best-effort 解析逻辑。

**Alternatives considered:**
- 只在 navigationDelegate 拦截：无法覆盖“纯 JS 事件触发而非链接点击”的场景。

### 3) 新窗口/外链拦截用 `NavigationDelegate` + `isMainFrame` 近似对齐 `targetFrame==nil`

**Decision:**
- 为 WebView 设置 `NavigationDelegate`，在 `onNavigationRequest` 中实现：
  - 若 URL host 包含 `t.me`：外部打开 + `NavigationDecision.prevent`
  - 若 `request.isMainFrame == false`（近似新窗口/弹窗跳转）：
    - `inAppJump == true` → `NavigationDecision.navigate`（允许壳内打开）
    - 否则 → 外部打开 + `prevent`
  - 其他情况：默认 `navigate`

**Rationale:**
- demo 使用 `createWebViewWithConfiguration` 捕获 `targetFrame == nil` 的新窗口行为；Flutter WebView 无同构 API，但 `isMainFrame` 能覆盖主要差异路径。

**Alternatives considered:**
- 完全忽略新窗口：会导致 window.open 链接在壳内失效或行为漂移。

### 4) `inAppJump` 作为壳级配置注入，不暴露语义 key

**Decision:**
- `inAppJump` 的值来自 remote_url 响应（随机 key 映射后的字段），并在 namespaced 生成代码中以“匿名字段读取 + 字符串布尔判定”落入壳实例：
  - 仅保留 `true/false` 判定逻辑
  - 不引入任何语义字段名或常量（仍由 generator 读取“随机 key”变量）

**Rationale:**
- 保持 de-homogenization 与“mapping 不进代码”的硬约束。

## Risks / Trade-offs

- **[注入时机不完全等价于 documentStart]** → 在 `loadRequest` 前设置 controller、在首次 `onPageStarted/onPageFinished` 都执行一次幂等注入（注入代码自带覆盖写法），提高命中率。
- **[webview_flutter 平台差异]** → 以 `NavigationDelegate` 最小集合实现；并在 widget tests 中通过注入 builder/hook 验证关键分支逻辑，避免依赖真实平台实现。
- **[引入 package_info_plus 作为新依赖]** → 若仓库已有等价依赖则复用；若新增则必须同步 iOS/Android 最小配置并更新生成模板与 skill 文档。
- **[误拦截正常导航]** → 仅对 `t.me` 与 `isMainFrame==false` 做强规则，其余保持默认放行。


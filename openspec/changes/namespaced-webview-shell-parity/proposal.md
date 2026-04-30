## Why

当前 namespaced 远程壳已具备 platform 分流、双协议事件桥接与归因 parity，但与 demo 的远程壳 WebView 行为仍存在差异：demo 有 `jsBridge.postMessage` 注入、`WgPackage` 注入、`openWindow/openSafari` 特殊处理、`t.me` 强制外开、新窗口拦截与 `inAppJump` 决策等逻辑。需要补齐这些行为，使 `jacket-app-full-build` 生成的马甲包与已生成的 `palette_pilot` 的远程壳逻辑与 demo 保持一致。

## What Changes

- 扩展 namespaced 远程壳模板（`tools/generate_namespaced_boot_remote.dart` 生成的 `lib/_<ns>/_<ns>.dart`）以对齐 demo：
  - 注入 `window.jsBridge.postMessage(name, data)` 并兼容 `Post/event` 两条消息入口
  - 注入 `window.WgPackage = { name, version }`
  - 处理 `openWindow/openSafari`：按 `inAppJump` 决策壳内打开或外部打开
  - 拦截新窗口/外链：`t.me` 强制外开；其他按 `inAppJump` 决策
- 保持审查约束不回退：no-logs、无标题、黑底安全区、无语义映射、blacklist gate 继续生效。
- 同步 `jacket-app-full-build`：补齐远程壳 parity 的硬约束与验收清单（涵盖上述行为）。

## Capabilities

### New Capabilities
- `namespaced-webview-shell-parity`: namespaced 远程壳 WebView 行为与 demo 对齐（JS 注入、openWindow/openSafari、新窗口拦截、t.me 外开、inAppJump 决策、WgPackage 注入）。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `tools/generate_namespaced_boot_remote.dart`
  - `apps/<app>/lib/_<ns>/_<ns>.dart`（壳页面与 WebView 配置/delegate/注入逻辑）
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md`


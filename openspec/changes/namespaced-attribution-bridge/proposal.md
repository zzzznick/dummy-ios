## Why

demo 中存在归因 SDK 配置与事件上报（Adjust / AppsFlyer + revenue 事件规则 + web→native 事件桥接），但目前 `palette_pilot` 已切换到 namespaced 启动/壳链路后缺失该能力。需要在不引用 `app_common` 的前提下恢复与 demo 一致的归因能力，并且同时支持两种 JS 事件协议，且按 `remote_url` 的 platform（"1"/"2"）选择对应协议与壳形态。

## What Changes

- 在 `tools/generate_namespaced_boot_remote.dart` 生成的 namespaced 单文件中加入归因桥接能力：
  - best-effort 读取 `remote_url` 首项相关字段并配置归因 SDK（AF/AD）
  - 接收 WebView 内 JS 事件并上报（两种协议均支持）
- 协议/壳选择与 demo 对齐：根据 `remote_url` 首项的 platform：
  - `"1"` → 壳形态 1 + 协议 A（oneview）
  - `"2"` → 壳形态 2 + 协议 B（twoview/eventTracker）
- 保持审核约束：namespaced 产物继续满足 blacklist/no-logs/无标题/黑底安全区等规则，不在代码中暴露“随机 key → 语义字段”映射关系。
- 同步 `jacket-app-full-build` 流程规范：补齐“归因桥接一致性”的接入与验证清单（包含两协议与 platform 选择）。

## Capabilities

### New Capabilities
- `namespaced-attribution-bridge`: namespaced 壳链路下的归因 SDK 配置与 web→native 事件上报（双协议支持，按 platform 分流）。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `tools/generate_namespaced_boot_remote.dart`
  - `apps/<app>/lib/_<ns>/_<ns>.dart`（新增归因桥与 JS channel）
- 影响依赖/插件：
  - `adjust_sdk`、`appsflyer_sdk`（已在 `palette_pilot` 依赖中存在）
  - WebView JS channel（继续使用 `webview_flutter`）
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md`


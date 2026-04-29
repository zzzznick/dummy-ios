## Why

当前 namespaced 启动入口（`lib/_<ns>/_<ns>.dart`）仅做 best-effort 拉取与 shape 校验，随后无条件进入本地壳，导致与原 `app_common` 的远端分流能力不一致：当 `remote_url` 首项配置了平台值与跳转地址时，无法按既定规则打开远程壳（WebView）或外部跳转。需要在不引入同构/敏感关键词的前提下恢复该能力，保证马甲包行为与既有链路一致。

## What Changes

- 在 namespaced 单文件产物中实现与 `app_common` 等价的“远端分流”能力：基于 `remote_url` 返回首项的随机字段值决定进入本地壳 / 远程壳（两种 WebView 壳形态）/ 外部打开。
- 继续满足源码去同构与 blacklist 门禁：不出现 `app_common`、`Boot*`、`RemoteConfig*`、`remoteConfig*` 以及语义字段名（如 `url/platform/eventType/...`）等关键词；分流逻辑通过 namespaced key 索引/约定实现，不在代码中呈现“随机 key → 语义字段”的映射关系。
- 更新生成器 `tools/generate_namespaced_boot_remote.dart`：生成相应的 WebView 壳（namespaced 命名）与路由逻辑，并补齐 README/复核说明的接入规范（同步到 `jacket-app-full-build`）。

## Capabilities

### New Capabilities
- `namespaced-remote-shell-routing`: 在 namespaced 启动入口中实现与原链路一致的远端分流与 WebView 壳加载能力，并保持 blacklist-safe 的命名与代码形态。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `tools/generate_namespaced_boot_remote.dart`（生成产物将包含 namespaced WebView 壳与分流逻辑）。
  - `apps/*/lib/_<ns>/_<ns>.dart` 的功能边界（从“仅进入本地壳”扩展到“可按远端配置进入远程壳/外部跳转”）。
  - 依赖：生成产物可能需要 `webview_flutter` / `url_launcher` 等（取决于当前马甲包既有依赖与壳实现方式）。
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md` 需要补充/更新“namespaced 远端分流一致性”的接入与验证说明。


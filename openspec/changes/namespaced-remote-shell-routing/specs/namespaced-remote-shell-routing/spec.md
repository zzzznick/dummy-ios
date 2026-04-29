## ADDED Requirements

### Requirement: Remote routing parity for namespaced entry
namespaced 入口（`apps/<app>/lib/_<ns>/_<ns>.dart`）MUST 根据 `remote_url` 返回首项的两项值执行分流，并与既有 `app_common` 规则保持一致：
- 平台值为 `"1"`：进入远程壳形态 1（WebView）
- 平台值为 `"2"`：进入远程壳形态 2（WebView）
- 平台值为 `"3"`：外部打开目标地址
- 其他/缺失/空：进入本地壳

#### Scenario: Route to remote shell type 1
- **WHEN** `remote_url` 返回数组首项，且平台值为 `"1"` 且目标地址非空
- **THEN** 应进入远程壳形态 1 并加载目标地址

#### Scenario: Route to remote shell type 2
- **WHEN** `remote_url` 返回数组首项，且平台值为 `"2"` 且目标地址非空
- **THEN** 应进入远程壳形态 2 并加载目标地址

#### Scenario: Route to external open
- **WHEN** `remote_url` 返回数组首项，且平台值为 `"3"` 且目标地址非空
- **THEN** 应触发外部打开目标地址，并结束当前入口流程

#### Scenario: Fall back to local on missing/invalid values
- **WHEN** `remote_url` 返回空数组、请求失败、或首项缺失平台值/目标地址、或平台值不在 `"1"|"2"|"3"`
- **THEN** 应进入本地壳（离线优先）

### Requirement: Blacklist-safe implementation (no semantic mapping in code)
上述分流实现 MUST 在代码侧保持去语义化与去同构：
- `apps/<app>/lib/**` 中 MUST NOT 出现禁词（至少包含：`app_common`、`BootPage`、`BootCoordinator`、`RemoteConfigClient`、`RemoteConfig`、`remoteConfig`、`remote_config` 等）
- `apps/<app>/lib/**` 中 MUST NOT 出现语义字段名（至少包含：`url`、`platform`、`eventType`、`afKey`、`appId`、`adKey`、`adEventList`、`inAppJump`）
- 代码中 MUST NOT 出现 “random key → semantic field” 的映射关系；字段读取 MUST 通过 namespaced key 列表索引或等价无语义约定实现

#### Scenario: Code passes blacklist + semantic-field scans
- **WHEN** 对 `apps/<app>/lib/**` 执行禁词与语义字段名扫描
- **THEN** 扫描不得命中任何 token

### Requirement: Generator integration and documentation sync
生成器（`tools/generate_namespaced_boot_remote.dart`）MUST 生成满足分流能力的 namespaced 产物，并在完成后确保：
- README/复核说明中包含 endpoint + mapping + response example
- `.cursor/skills/jacket-app-full-build/SKILL.md` 同步包含“远端分流一致性”的接入与验证说明

#### Scenario: Generator produces routable namespaced entry and updates process docs
- **WHEN** 使用生成器为某个 app 生成 namespaced 产物
- **THEN** 产物具备远端分流能力且通过 lib/** 门禁
- **THEN** `jacket-app-full-build` 的流程规范与验证清单包含对应说明


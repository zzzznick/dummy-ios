## ADDED Requirements

### Requirement: Namespaced attribution bridge config and track
namespaced 产物（`apps/<app>/lib/_<ns>/_<ns>.dart`）MUST 支持归因 SDK 的 best-effort 配置与事件上报：
- 基于 `remote_url` 首项字段选择并配置归因 SDK（AppsFlyer / Adjust）
- 接收 web→native 事件并调用归因 SDK 上报
- 任何失败 MUST NOT 阻塞进入本地壳，且 MUST NOT 崩溃
- 源码层面 MUST NOT 使用 `print/debugPrint/logger` 等输出

#### Scenario: Configure attribution once from remote first item
- **WHEN** 入口拉取 `remote_url`，且首项包含归因配置所需字段
- **THEN** 系统 best-effort 配置归因 SDK（仅一次），不影响后续路由

#### Scenario: Track event is safe when unconfigured
- **WHEN** web 侧发送事件但归因 SDK 未成功配置
- **THEN** track 调用 MUST 安全返回且不抛异常

### Requirement: Dual JS protocols supported and selected by platform
namespaced 远程壳 MUST 同时支持两种 JS 事件协议，并按 `remote_url` 首项 platform 选择：
- platform `"1"`：壳 1 绑定协议 A（oneview）
- platform `"2"`：壳 2 绑定协议 B（twoview/eventTracker）

#### Scenario: Platform 1 uses oneview protocol
- **WHEN** platform 为 `"1"`，且 web 侧以 oneview 协议发送事件
- **THEN** native MUST 解析出 `(name,payload)` 并交给归因桥上报

#### Scenario: Platform 2 uses eventTracker protocol
- **WHEN** platform 为 `"2"`，且 web 侧以 eventTracker 协议发送事件
- **THEN** native MUST 解析出 `(name,payload)` 并交给归因桥上报

### Requirement: Blacklist / no-logs constraints remain satisfied
namespaced 产物与马甲包 `lib/**.dart` MUST 继续满足既有约束：
- 不引入 `app_common`、`RemoteConfig*`、`Boot*` 等同构/敏感词
- 不引入任何日志输出 token（`print(`/`debugPrint(`/`developer.log(`/`Logger(` 等）
- 不在代码中呈现随机 key 到语义字段的映射关系

#### Scenario: Generated lib passes gates
- **WHEN** 生成器写入 namespaced 文件并执行 gate 扫描
- **THEN** gate 不得命中 blacklist/no-logs tokens

### Requirement: Process docs updated for attribution bridge
`.cursor/skills/jacket-app-full-build/SKILL.md` MUST 增加归因桥接的接入与验收说明，包括：
- 两协议与 platform 的绑定关系
- 最小验证步骤（至少验证 JS 事件可到达 native 并触发桥接入口）

#### Scenario: Jacket build skill documents attribution parity
- **WHEN** 按 `jacket-app-full-build` 生成新马甲包
- **THEN** 流程文档包含归因桥接说明与验证项


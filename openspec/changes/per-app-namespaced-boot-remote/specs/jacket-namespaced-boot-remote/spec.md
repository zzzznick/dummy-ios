## ADDED Requirements

### Requirement: Per-app namespaced boot+remote code generation
系统 MUST 为每个马甲包（`apps/<app>/`）生成一套 per-app namespaced 的启动与远端读取链路代码产物，并且这些产物在不同 app 之间的目录名、文件名与符号名 MUST 不同（由 namespace 派生且可复现）。

#### Scenario: Generate namespaced artifacts for an app
- **WHEN** 生成器以 `apps/<app>` 与 `namespace`（5 字母前缀）为输入运行
- **THEN** 在 `apps/<app>/lib/_<namespace>/` 下生成启动+远端读取链路产物
- **THEN** 业务侧只需要通过单一入口（单个 import + 单个入口 widget/builder）完成接入
- **THEN** 多个不同 app 生成后的产物路径与符号名彼此不同，且可通过 namespace 复现

### Requirement: Code blacklist enforcement in lib/
系统 MUST 对 `apps/<app>/lib/**` 执行黑名单关键字校验；若命中，生成流程 MUST 失败并给出命中项（至少包含文件路径与命中的 token）。

黑名单 token（最小集合） MUST 包含：
- `remote_config`
- `RemoteConfig`
- `remoteConfig`
- `app_common`
- `BootPage`
- `BootCoordinator`
- `RemoteConfigClient`
- `remoteConfigEndpoint`
- `remoteConfigKeys`

#### Scenario: Generation fails when forbidden tokens exist in lib/
- **WHEN** 生成产物（或 app 现有代码）在 `apps/<app>/lib/**` 中出现任一黑名单 token
- **THEN** 生成流程返回非 0 并报告命中位置

### Requirement: No semantic-field mapping in code
系统 MUST 确保“random key → semantic field”的映射关系不在 `apps/<app>/lib/**` 中出现；特别是语义字段名 MUST NOT 以字段/常量/类型/日志文案的形式出现在源码中。

语义字段名最小集合 MUST 包含：
- `url`
- `platform`
- `eventType`
- `afKey`
- `appId`
- `adKey`
- `adEventList`
- `inAppJump`

#### Scenario: Semantic field names do not appear in lib/
- **WHEN** 对 `apps/<app>/lib/**` 做全文扫描
- **THEN** 不存在上述语义字段名（包括变量名、类成员名、字符串日志/注释等形式）

### Requirement: Docs remain the source of truth for endpoint and mapping
系统 MUST 将每个马甲包的 endpoint（remote_url）、字段映射与 response example 输出到 `apps/<app>/README.md` 与 `apps/<app>/马甲包复核说明.md`，以支持联调与人工复核。

#### Scenario: Docs include endpoint, mapping and response example
- **WHEN** 为某个 `apps/<app>` 生成/更新 namespaced 产物
- **THEN** `README.md` 中包含 endpoint、mapping（random key → semantic label）与 `remote_url` response example（JSON array，首项生效）
- **THEN** `马甲包复核说明.md` 中也包含同样三段信息（可中文说明，但 JSON 键名保持随机串）

### Requirement: Deterministic outputs for the same inputs
系统 MUST 保证在相同 `apps/<app>` 与相同 `namespace` 输入下，多次生成得到的产物在符号命名、路径结构与联调文档片段上保持一致（除非显式 `--force` 覆盖或输入变化）。

#### Scenario: Re-running generator yields identical results
- **WHEN** 以相同输入参数重复运行生成器
- **THEN** 生成产物保持一致，不引入额外随机化导致 diff 噪声


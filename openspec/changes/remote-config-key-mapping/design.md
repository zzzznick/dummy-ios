## Context

- 当前 `RemoteConfigItem.tryFromDynamic()` 直接用固定 JSON key（`url/platform/eventtype/afkey/appid/adkey/adeventlist/inappjump`）读取远端对象字段。
- 需求是“字段名随机化 + 每包隔离”：同一套 remote endpoint 规则下，每个马甲包都应当拥有不同的 JSON key，避免配置与回包在不同包之间可直接复用/对照。
- 同时需要将“随机 key ↔ 语义字段”的对照关系输出到马甲包 README，供远端配置人员按包配置。

## Goals / Non-Goals

**Goals:**
- common 包内不再出现固定明文字段的 JSON key 字符串（如 `'url'`），改为通过注入的 keyset 读取。
- 每个马甲包可生成/内置一套随机 keyset，并在启动时用该 keyset 解析 remote-config。
- README 输出映射关系与 `remote_url` 响应示例，确保配置可操作。
- 不改变 remote-config 的核心语义：仍是返回 list，取第一项决定启动路由与 analytics 初始化。

**Non-Goals:**
- 不试图通过字段随机化规避 App Store 审核或改变合规义务（例如 ATT/隐私披露）。
- 不在本变更中引入加密、签名校验或远端配置的鉴权机制（如需可另起 change）。
- 不改变 `RemoteConfigItem` 在业务层的语义字段命名（仍保留 `url/platform/eventType/...` 这些模型属性，便于下游使用）。

## Decisions

### Decision: 引入 `RemoteConfigKeys` 并作为解析依赖注入
- **Choice**: 增加一个 `RemoteConfigKeys`（keyset）数据结构，包含每个语义字段对应的“远端 JSON key 字符串”。`RemoteConfigItem.tryFromDynamic()` 接收 `RemoteConfigKeys` 参数并按 keyset 取值。
- **Rationale**: 将“远端协议字段名”从解析实现中剥离，使每包可替换且不污染 `food_app_common` 的业务语义模型。
- **Alternatives**:
  - 在解析处硬编码多套 key：会在 common 包里留下明文 key，且不利于每包随机化。
  - 远端返回额外 `mapping` 字段：会暴露映射本身，且增加协议复杂度。

### Decision: keyset 由 app 层生成并内置（A 方案）
- **Choice**: 在每个马甲包的 app 层生成 `remote_config_keys.dart`（或等价位置），构造 `RemoteConfigClient` 时注入该 keyset。
- **Rationale**: 每包天然隔离；同时 README 生成可直接复用同一份 keyset 产出映射说明与示例。
- **Alternatives**:
  - keyset 从远端下发：会引入“先拿 mapping 再解 payload”的依赖链，且容易被抓包直接获得映射。

### Decision: 不默认兼容旧明文字段（可通过生成期开关扩展）
- **Choice**: 默认仅解析随机 key；如需过渡期兼容，采用生成期开关（仅特定包启用）实现“新 key 优先，缺失时回退旧 key”。
- **Rationale**: 需求核心是隔离与随机化；长期兼容旧 key 会削弱目标。

## Risks / Trade-offs

- **[风险] 远端配置成本提升** → **Mitigation**：README 输出映射与可复制的响应示例；生成器确保每包固定产出。
- **[风险] keyset 变更导致线上包无法解析旧数据** → **Mitigation**：keyset 一经发布不可随意变更；如必须变更，使用过渡期兼容开关并给出迁移窗口。
- **[权衡] 仅字段名随机化并不等同于安全** → **Mitigation**：如需防篡改/防重放，后续引入签名/校验（独立 change）。

## Migration Plan

- 第一步：为 `food_app_common` 增加 `RemoteConfigKeys` 注入点，并将解析从固定 key 改为 keyset 读取。
- 第二步：在现有 app（`apps/food_app`）内置一套默认 keyset（用于本仓库 demo/开发）。
- 第三步：在马甲包生成流程中为每个新包生成随机 keyset 与 README 映射说明；远端 mock/配置按 README 调整字段名。
- 回滚：保留旧实现分支/或启用“兼容旧字段”开关（仅在需要时），确保可快速回退解析策略。

## Open Questions

- 随机 key 的生成规则：长度、字符集、是否需要前缀（便于 grep/定位），以及是否要避免敏感词/可读词。
- 是否需要在 README 中同时输出 “语义字段 → 随机 key” 的反向表（便于人工配置）。

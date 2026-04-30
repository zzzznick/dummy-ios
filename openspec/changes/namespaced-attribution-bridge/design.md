## Context

demo 的归因链路由 `app_common` 提供：启动阶段根据远端字段配置 AppsFlyer/Adjust，并在 WebView 壳内通过 JS message 将 web 侧事件转发到 native，最终调用归因 SDK 上报。当前 `palette_pilot` 已迁移到 namespaced 生成的启动/壳（`lib/_<ns>/_<ns>.dart`），仅保留了 platform 分流与壳加载，缺少：
- 归因 SDK 的配置（AF/AD）
- web→native 事件通道与两种协议解析

同时要满足本仓库已确立的审查约束：
- 不引用 `app_common`
- namespaced `lib/_<ns>/_<ns>.dart` 不出现语义字段名与映射关系
- 不打印/不 logger
- 远程壳无标题 + 黑底安全区

## Goals / Non-Goals

**Goals:**
- 在 namespaced 单文件内补齐归因桥接能力（配置 + 上报）。
- 同时支持两种 JS 事件协议，并按 `remote_url` 首项 platform 选择对应协议/壳形态：
  - `"1"`：壳 1 + oneview 协议
  - `"2"`：壳 2 + twoview/eventTracker 协议
- best-effort：任何失败不影响进入本地壳；归因配置与上报不可导致崩溃。
- 保持无日志：不使用 `print/debugPrint/logger`。

**Non-Goals:**
- 不在本变更中实现 demo 的全部 web 壳功能（如 in-app jump 外开策略、强制外部 host 等），除非归因事件桥接依赖。
- 不增加新的明文语义字段映射到代码中（mapping 仍只存在文档）。

## Decisions

### 1) 远端字段读取仍采用“索引约定”，不引入语义字段名

**Decision:** namespaced 文件内继续保留 `const List<String> <ns>1 = [...]` 作为随机 key 列表，新增归因所需字段读取同样通过索引访问：
- platform 与目标地址用于分流（已实现）
- eventType / afKey / appId / adKey / adEventListRaw 等用于归因配置

变量命名使用无语义短名（如 `p2/p3/...`），避免出现 `eventType/afKey/appId/...`。

### 2) JS 通道按 platform 绑定不同解析器

**Decision:** 为壳 1/壳 2 分别生成独立的 JS channel（namespaced 且无语义命名），并在 channel 回调内使用不同协议解析：
- 平台 `"1"`：解析 oneview 格式（支持 `{name,data}` JSON 与 `name+payload` 变体）
- 平台 `"2"`：解析 eventTracker 格式（支持 `{eventName,eventValue}` 的 JSON）

解析结果统一为 `(name, payload)`，再交给归因桥 `t(name,payload)` 上报。

### 3) 归因桥为 best-effort、无日志、无崩溃

**Decision:** 生成一个 namespaced 的归因桥对象：
- `c(cfgFields)`：仅配置一次，吞异常
- `t(name,payload)`：未配置则直接返回，吞异常
- revenue 事件规则与 demo 对齐（若实现成本可控）

不使用 `logger`，不打印。

### 4) 流程规范同步到 jacket-app-full-build

**Decision:** 在 `jacket-app-full-build` 增加：
- 归因桥接开关/依赖说明（需要 `adjust_sdk`、`appsflyer_sdk`、`webview_flutter`）
- 两协议与 platform 对应关系
- 最小验收步骤（通过 mock/测试或手工 JS 注入验证事件被接收并调用桥接入口）

## Risks / Trade-offs

- **[字段索引错位]** 归因字段依赖 key 列表顺序，若未来 keyset 变化可能错读 → **Mitigation:** 将 key 列表顺序在生成器内固定为“远端协定”，并在 README 映射中同步；必要时加轻量形态校验（但不打印）。
- **[WebView channel 兼容性]** 不同 web 侧可能发送不同格式 → **Mitigation:** 同时兼容 JSON 与 raw string 两种常见形态；解析失败时静默忽略。
- **[SDK 依赖]** 某些马甲包未包含归因 SDK 依赖 → **Mitigation:** 在 full-build 流程中统一纳入依赖；或在生成器中按需生成（实现阶段决定）。


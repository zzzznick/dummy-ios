## Context

当前仓库存在多款 demo/马甲包（例如 `apps/gauge_grid`、`apps/palette_pilot` 等），它们的启动与远端配置读取链路高度一致：`BootPage → BootCoordinator → RemoteConfigClient → RemoteConfigItem`。同时，代码与目录/文件名里存在大量可聚类关键词与语义字段名：

- 关键词/锚点：`remote_config_*`、`remoteConfigEndpoint/remoteConfigKeys`、`RemoteConfig*`、`Boot*`、`app_common`
- 语义字段：`url/platform/eventType/afKey/appId/adKey/adEventList/inAppJump`
- 日志文案中也存在语义字段与固定前缀（如 `[BootCoordinator] item.url=...`）

在“多包同审”的场景下，这些同构锚点会显著降低审查者聚类成本，并可能暴露“随机字段 ↔ 语义字段”的映射关系。我们需要一个 **per-app namespaced 的生成策略**：不仅随机化远端字段 keyset，还要随机化本地代码的符号与路径结构，使跨包对比难以通过简单 grep/结构对齐完成。

约束：
- 仍需保留联调能力：每包的 endpoint、随机字段映射与 response example 必须输出到 `README.md` 与 `马甲包复核说明.md`。
- 实现需可复现、可自动生成，避免人工改名导致漏网锚点。
- 允许逐步迁移：现有 demo/旧包可暂时保留原链路，但新生成包必须使用 namespaced 产物。

## Goals / Non-Goals

**Goals:**
- 为每个 `apps/<app>` 生成一套 **per-app namespace** 的启动 + 远端读取链路产物，使下列内容在源码中不再出现：
  - 黑名单关键词：`remote_config`、`RemoteConfig`、`remoteConfig`、`app_common`、`BootPage`、`BootCoordinator`、`RemoteConfigClient`
  - 语义字段名：`url/platform/eventType/afKey/appId/adKey/adEventList/inAppJump`
- 生成产物尽量 **聚合为单文件**（降低同构文件名/结构特征），并将业务侧接入点收敛为 1 个 import + 1 个入口 widget（或 builder）。
- 建立 **blacklist 校验**：生成完成后对 `apps/<app>/lib/**` 做禁词扫描，命中即失败（防止日志/注释/import 里残留）。
- 文档侧输出保持现有可读性：endpoint + mapping + response example（list 首项生效）继续按包写入 README 与复核说明。

**Non-Goals:**
- 不追求强加密/对抗反编译；本设计聚焦“源码审查/批量对比”场景的去同构与去语义化。
- 不改变远端返回协议（仍为 JSON array，取第一个对象），除非后续另开 change。
- 不要求一次性迁移所有历史 demo/包；优先保证新生成包符合要求，并提供可选迁移路径。

## Decisions

### 1) 以现有 keyset prefix 作为全包 namespace

**Decision:** 复用生成器已存在的 5 字母 prefix（例如 `vsbwk`）作为“全包 namespace”。该 namespace 同时用于：
- 远端字段随机 key（已存在）
- 本地代码目录名/文件名/类名/常量名/日志 tag（新增）

**Rationale:** 不新增额外配置来源，且 prefix 本身已做到 per-app 不同，天然满足“批量审查不易聚类”的目标。

**Alternative:** 单独生成 symbol namespace，与 keyset prefix 分离。缺点是多一套参数需要保存与传播，容易错配。

### 2) 目录与文件名也按 namespace 变化（避免 `app_common` 与 `remote_config_*`）

**Decision:** 生成产物落在 `apps/<app>/lib/_<ns>/`（例如 `lib/_vsbwk/`）下，入口文件为 `lib/_<ns>/_<ns>.dart`（单文件聚合）。

**Rationale:** `app_common`、`remote_config_*` 是强锚点；仅替换类名不足以避免“路径同构”被聚类。

**Alternative:** 仍使用 `lib/app_common/` 但改类名。缺点是目录名仍可一眼看出共用架构。

### 3) 类/字段/常量完全去语义化，避免引入新同构词（如 `RcKeys/RcItem`）

**Decision:** 产物内的类型与字段使用 `Ns` 前缀 + 简短后缀（数字或单字母），并确保不同包不同名。例如：
- `class Vsbwk0` / `class Vsbwk1`
- `const String vsbwk0 = '...'`
- 字段为 `a/b/c...` 或 `f0/f1...`，禁止出现 `url/platform/...`

**Rationale:** `RcKeys/RcItem` 会成为新的跨包同构锚点；去语义化必须覆盖字段名与日志。

**Alternative:** 使用通用抽象名（`ConfigKeys/Item/Client`）。缺点是仍可跨包聚类。

### 4) 启动链路与日志一并 namespaced

**Decision:** 将启动入口 widget 与内部协调器也生成并 namespaced；日志 tag 采用 `[$ns]`，且不输出语义字段名（例如不打印 `item.url`）。

**Rationale:** `BootPage/BootCoordinator` 与日志前缀是非常强的指纹；仅 remote 部分去语义化仍会暴露共用结构。

### 5) 建立 blacklist 校验作为“生成完成即失败”的门禁

**Decision:** 在生成流程结束时对 `apps/<app>/lib/**` 做禁词扫描，黑名单命中则返回非 0，阻止产出进入主分支/交付。

**Rationale:** 最常见的漏网点是注释、日志、文件名、import；门禁是长期稳定的保障。

## Risks / Trade-offs

- **[Debug 难度上升]** 代码无语义化后排障成本变高 → **Mitigation:** 文档侧提供 mapping 与 response example；生成器输出也打印 namespace 与入口点；必要时保留仅开发态可选的“更详细日志”（但仍不得包含禁词/语义字段名）。
- **[迁移复杂度]** 现有包可能仍依赖 `package:app_common/...` → **Mitigation:** 先保证新生成包使用新链路；对旧包提供可选迁移任务与脚本化替换路径。
- **[误杀]** blacklist 扫描可能命中文档/测试或非运行时文件 → **Mitigation:** 扫描范围限定为 `apps/<app>/lib/**`（不含 README/复核说明），并允许配置豁免列表（最小化使用）。
- **[命名碰撞/不一致]** namespace 与符号生成必须确定性 → **Mitigation:** 统一用 namespace 派生所有符号，避免随机散落；同一次生成内保持一致。


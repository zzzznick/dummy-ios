## Why

马甲包后续可能会被批量一起审查；当前每个包里普遍存在高度同构且带语义的启动/remote 相关代码与命名（如 `remote_config_*`、`remoteConfigEndpoint/remoteConfigKeys`、`RemoteConfig*`、`Boot*`、`app_common`）。这些锚点会让审查者快速把多个包聚类对比，并在源码中直接看到“随机字段 ↔ 语义字段”的映射关系，增加审核风险。因此需要把相关逻辑改为 **per-app namespaced 生成**，并在代码侧彻底去语义化/去同构。

## What Changes

- 为每个马甲包生成一套 **per-app namespace** 的启动 + remote 代码产物（目录、文件名、类名、常量名、字段名、日志文案都随 app/namespace 变化），避免跨包同构特征。
- 马甲包源码中不再出现敏感/聚类关键词（如 `remote_config`、`RemoteConfig`、`remoteConfig`、`app_common`、`BootPage`、`BootCoordinator`、`RemoteConfigClient` 等），并提供自动校验（blacklist check）。
- 远端 JSON 随机字段 keyset 仍保留，但“random key → semantic field”的映射关系不在代码中出现；映射信息仅输出在 `README.md` / `马甲包复核说明.md` 供联调使用。
- 更新生成器/流程，使之可复现（同一 app/namespace 多次生成结果一致），并支持在现有 demo/马甲包中逐步迁移。

## Capabilities

### New Capabilities
- `jacket-namespaced-boot-remote`: 为每个马甲包生成去同构、去语义化的启动与 remote 配置读取链路（含命名/路径随机化与 blacklist 校验），并将映射信息限制在文档侧输出。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `tools/generate_namespaced_boot_remote.dart` 与马甲包生成流程（`jacket-app-full-build` 对应的实现与约束）。
  - `apps/*` 中的启动入口与 remote 读取注入方式（import 路径与入口符号将变化）。
  - `packages/app_common` 及其被吸收进马甲包后的形态（目录名不再固定为 `app_common`，并避免公开 API 名称同构）。
- 影响文档：
  - `apps/<app>/README.md`、`apps/<app>/马甲包复核说明.md` 中的 remote endpoint + mapping + response example 仍保留，作为联调“真相来源”。

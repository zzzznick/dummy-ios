---
name: jacket-remote-config-keyset
description: Generates per-app remote_url endpoint + random field keyset, writes namespaced boot+remote glue code under lib/_<ns>/_<ns>.dart, prints a README snippet (endpoint + mapping + response example), and enforces a lib/** blacklist gate using tools/generate_namespaced_boot_remote.dart. Use when the user asks to randomize/mapping remote fields, set different remote_url per jacket app, mockapi remote 字段映射, or to output the mapping in the generated jacket app README.
---

# Remote config（remote_url）端点 + 字段随机化（keyset）+ README 输出

## 适用场景

- 用户提出 mockAPI / remote-config 返回字段需要“映射/混淆/随机化”
- 用户要求“项目内只出现随机字段（如 `rsjgjUr`），映射关系写进马甲包 README”
- 用户要为某个 `apps/<app_name>` 生成专属字段 keyset
- 用户要求不同马甲包使用不同的 `remote_url`（endpoint）

## 前置条件（仓库内已提供）

- `app_common` 已支持通过 `RemoteConfigKeys` 注入解析 remote-config
- 生成工具：`tools/generate_namespaced_boot_remote.dart`

## 输入

- **目标 app 目录**：例如 `apps/<app_name>`
- 可选：**prefix**（例如 `rsjgj`）。不提供则自动生成随机 5 字母前缀
- 可选：是否需要**兼容模式**（迁移窗口用）
- 可选：**endpoint（remote_url）**：例如 `https://<your-domain>/remote-config/<app>`

## 工作流程

### 1) 生成 `remote_url` endpoint + namespaced 单文件（含 blacklist 门禁）

在仓库根目录执行：

```bash
dart run tools/generate_namespaced_boot_remote.dart apps/<app_name> [ns] --force --endpoint <remote_url>
```

说明：
- 输出文件路径固定：`apps/<app_name>/lib/_<ns>/_<ns>.dart`（单文件聚合）
- 生成器会在结束时对 `apps/<app_name>/lib/**` 执行 blacklist 扫描，命中即失败并报告文件+token
- 默认会拒绝覆盖已存在文件；需要替换时加 `--force`

### 2)（兼容策略）

本次 namespaced 方案的目标是源码去同构/去语义化；如需兼容旧字段（fallback）请在实现阶段另开 change 设计迁移窗口策略，避免把语义字段名引回 `lib/**`。

### 3) 更新/追加 README 映射说明

生成器会在 stdout 打印一段 markdown（包含三部分）：
- endpoint（remote_url）
- 字段映射（随机 key → 语义字段）
- `remote_url` 响应示例（list 第一个对象生效）

将该段内容追加到 `apps/<app_name>/README.md` 的 “Remote Config 字段映射（remote_url）” 小节。

## 验证清单

- 检查 app 启动入口是否已使用 `apps/<app_name>/lib/_<ns>/_<ns>.dart` 的入口 widget/builder
- 确认 blacklist 扫描通过（生成器退出码为 0）
- 运行：`cd apps/<app_name> && flutter test`

## 常见坑

- **误覆盖 demo app keys**：生成器默认拒绝覆盖；使用 `--force` 前确认目标路径是新马甲包目录
- **远端返回格式**：必须是 list，且取第一个对象作为有效项


---
name: jacket-remote-config-keyset
description: Generates per-app remote_url endpoint + remote-config random field keyset, and prints a README snippet (endpoint + mapping + response example) using tools/generate_remote_config_keyset.dart. Use when the user asks to randomize/mapping remote fields, set different remote_url per jacket app, mockapi remote 字段映射, or to output the mapping in the generated jacket app README.
---

# Remote config（remote_url）端点 + 字段随机化（keyset）+ README 输出

## 适用场景

- 用户提出 mockAPI / remote-config 返回字段需要“映射/混淆/随机化”
- 用户要求“项目内只出现随机字段（如 `rsjgjUr`），映射关系写进马甲包 README”
- 用户要为某个 `apps/<app_name>` 生成专属字段 keyset
- 用户要求不同马甲包使用不同的 `remote_url`（endpoint）

## 前置条件（仓库内已提供）

- `app_common` 已支持通过 `RemoteConfigKeys` 注入解析 remote-config
- 生成工具：`tools/generate_remote_config_keyset.dart`

## 输入

- **目标 app 目录**：例如 `apps/<app_name>`
- 可选：**prefix**（例如 `rsjgj`）。不提供则自动生成随机 5 字母前缀
- 可选：是否需要**兼容模式**（迁移窗口用）
- 可选：**endpoint（remote_url）**：例如 `https://<your-domain>/remote-config/<app>`

## 工作流程

### 1) 生成 `remote_url` endpoint + `remote_config_keys.dart`

在仓库根目录执行：

```bash
dart run tools/generate_remote_config_keyset.dart apps/<app_name> [prefix] --force --endpoint <remote_url>
```

说明：
- 输出文件路径固定：`apps/<app_name>/lib/boot/remote_config_keys.dart`
- 文件内导出常量：`remoteConfigKeys`
- 输出 endpoint 文件：`apps/<app_name>/lib/boot/remote_config_endpoint.dart`
  - 文件内导出常量：`remoteConfigEndpoint`
- 默认会拒绝覆盖已存在文件；需要替换时加 `--force`

### 2)（可选）生成兼容模式 fallback keys

仅在需要“新 key 优先、缺失则回退旧明文字段”的迁移窗口时使用：

```bash
dart run tools/generate_remote_config_keyset.dart apps/<app_name> [prefix] --force --compat
```

说明：
- 额外生成 `remoteConfigFallbackKeys`（明文字段）
- 客户端接入方式：构造 `RemoteConfigClient(endpoint: ..., keys: remoteConfigKeys, fallbackKeys: remoteConfigFallbackKeys)`

### 3) 更新/追加 README 映射说明

生成器会在 stdout 打印一段 markdown（包含三部分）：
- endpoint（remote_url）
- 字段映射（随机 key → 语义字段）
- `remote_url` 响应示例（list 第一个对象生效）

将该段内容追加到 `apps/<app_name>/README.md` 的 “Remote Config 字段映射（remote_url）” 小节。

## 验证清单

- 检查 `apps/<app_name>/lib/boot/boot_page.dart`（或等价位置）是否已经注入 `keys: remoteConfigKeys`
- 如果启用 compat：确认注入了 `fallbackKeys: remoteConfigFallbackKeys`
- 运行：`cd apps/<app_name> && flutter test`

## 常见坑

- **误覆盖 demo app keys**：生成器默认拒绝覆盖；使用 `--force` 前确认目标路径是新马甲包目录
- **远端返回格式**：必须是 list，且取第一个对象作为有效项


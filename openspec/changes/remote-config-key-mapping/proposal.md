## Why

当前 Flutter 工程的 remote-config 解析使用固定明文字段（如 `url`、`platform`、`eventtype` 等）。当批量生成新的 iOS 马甲包并复用同一套 MockAPI/remote endpoint 时，容易出现“不同包拿到相同字段名与响应值”的可配置性/隔离性问题。

我们需要让每个马甲包拥有一套专属的 remote-config JSON 字段名（随机化 key），客户端代码仅识别该专属字段名，同时在马甲包 README 中输出“专属字段名 ↔ 语义字段”的映射说明，便于远端配置与排障。

## What Changes

- 为 remote-config JSON 解析引入“可注入 keyset（字段名集合）”，不再在 common 包中写死 `url/platform/eventtype/...` 等 JSON key 字符串。
- 每个马甲包在 app 层生成并内置一套随机 keyset（例如 `rsjgjUr`、`rsjgjPlaf` 等），运行时用该 keyset 解析 remote-config 响应。
- 马甲包生成的 README SHALL 输出该包的字段映射关系（随机 key → 语义字段），并给出 `remote_url` 响应示例（list 的第一个对象为有效项）。
- 不引入新的网络行为：仍为启动时 HTTP GET，读取返回 list 的第一项作为 remote-config。

## Capabilities

### New Capabilities
- `remote-config-keyset`: 支持以可注入 keyset 的方式解析 remote-config JSON，并为每个马甲包生成随机 keyset 与 README 映射说明。

### Modified Capabilities
- （无）

## Impact

- 影响模块：`packages/app_common/lib/remote_config/*`、启动链路中构造 `RemoteConfigClient`/解析 `RemoteConfigItem` 的位置、以及马甲包生成流程（生成 `RemoteConfigKeys` 与 README）。
- 行为影响：远端响应 JSON 的 key 将变为“马甲包专属随机 key”，远端配置需要按 README 指引调整字段名。

## 1. 生成器与产物结构

- [x] 1.1 设计并固化 per-app `namespace` 规则（复用 5 字母 prefix）并在生成流程中传递
- [x] 1.2 更新/新增生成工具：为 `apps/<app>/lib/_<ns>/_<ns>.dart` 生成单文件聚合产物（启动入口 + 远端读取 + 决策链路 + 必要依赖封装）
- [x] 1.3 确保生成产物不包含语义字段名（`url/platform/...`）与同构锚点命名（`RemoteConfig*`、`Boot*`、`app_common` 等）
- [x] 1.4 生成器输出 README/复核说明片段：endpoint + mapping + response example（JSON array 首项生效），并可重复运行保持一致

## 2. Blacklist 门禁（lib/**）

- [x] 2.1 实现对 `apps/<app>/lib/**` 的黑名单 token 扫描（按 spec 列表），命中即失败并报告路径+token
- [x] 2.2 将 blacklist 校验接入到生成流程末尾（确保“生成完成即校验”）
- [x] 2.3 增加最小回归用例：在一个样例 app 上运行生成与校验，确认能通过且不会误扫文档

## 3. 现有包接入与迁移（最小闭包）

- [x] 3.1 选定一个现有马甲包作为迁移样例（如 `apps/palette_pilot` 或新建一个 app），将启动入口改为使用 `lib/_<ns>/_<ns>.dart` 的入口 widget/builder
- [x] 3.2 移除/替换旧的同构文件与命名（例如 `lib/boot/remote_config_*`、`remoteConfigEndpoint/remoteConfigKeys`）使 `lib/**` 满足 blacklist
- [x] 3.3 确认联调文档仍包含 endpoint + mapping + response example，且代码不出现映射关系

## 4. 验证与验收

- [x] 4.1 对迁移样例 app 运行全文扫描：确认 `apps/<app>/lib/**` 不包含黑名单 token 与语义字段名集合
- [x] 4.2 运行 `flutter test`（至少对迁移样例 app），确保启动链路与本地壳不回归
- [x] 4.3 文档核对：`README.md` 与 `马甲包复核说明.md` 的 endpoint/mapping/response example 与生成器输出一致


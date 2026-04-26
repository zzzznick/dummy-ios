## 1. 新增公共 package（方案 A）

- [x] 1.1 在仓库根目录新增 `packages/app_common/` Flutter/Dart package（仅 Dart 也可），并确认 `apps/food_app` 以 path 依赖方式引用
- [x] 1.2 在 `packages/app_common/pubspec.yaml` 声明公共模块所需依赖（dio、connectivity_plus、webview_flutter、package_info_plus、device_info_plus、logger、appsflyer_sdk、adjust_sdk、app_tracking_transparency 等）
- [x] 1.3 在 `packages/app_common/lib/` 创建目录骨架：`boot/ remote_config/ analytics/ web_shells/ att/ routing/`
- [x] 1.4 定义公共包对外 export（例如 `app_common.dart`）与最小可编译占位实现

## 2. 抽离 Remote Config（endpoint 注入）

- [x] 2.1 将 `apps/food_app/lib/models/remote_config.dart` 迁移到 `packages/app_common/lib/remote_config/remote_config.dart`
- [x] 2.2 将 `apps/food_app/lib/services/remote_config_service.dart` 迁移并重命名为 `RemoteConfigClient`（或等价命名），移除硬编码 `defaultEndpoint`，改为构造参数注入
- [x] 2.3 更新 `food_app` 内引用路径与 import（从 app 内文件改为从 package 引用）

## 3. 抽离 Bootkit（编排 + 策略 + 注入点）

- [x] 3.1 将 `apps/food_app/lib/boot/boot_decision.dart` 迁移到 `packages/app_common/lib/boot/boot_decision.dart`
- [x] 3.2 将 `apps/food_app/lib/boot/boot_coordinator.dart` 迁移到 `packages/app_common/lib/boot/boot_coordinator.dart`
- [x] 3.3 在公共包内引入 `BootDecisionStrategy`（默认策略保持当前 `platform/url` 规则），并允许 host app 覆写
- [x] 3.4 将 `LocalTabsPage` 等 app 专属页面从 `BootCoordinator` 依赖中剥离：改为注入 `WidgetBuilder`/factory（local destination builder）
- [x] 3.5 将 remote-config endpoint 作为 host app 注入项贯穿 boot（BootCoordinator 依赖注入 RemoteConfigClient）
- [x] 3.6 校验 boot 行为与当前一致：重试 backoff、网络恢复触发、evaluation 去重、路由 pushReplacement

## 4. 抽离 Analytics Bridge（AF/Adjust）

- [x] 4.1 将 `apps/food_app/lib/analytics/analytics_bridge.dart` 迁移到 `packages/app_common/lib/analytics/analytics_bridge.dart`
- [x] 4.2 提供可注入配置项：Adjust 环境、内置 token map、可选事件过滤器（默认行为保持当前一致）
- [x] 4.3 保持 `configure(RemoteConfigItem)` 幂等（配置成功后不重复 init）与失败容错（不抛异常）
- [x] 4.4 保持 revenue 事件规则与当前一致（withdraw 为负；从 amount/af_revenue 读取金额）

## 5. 抽离 Web Shells（One/Two + shared）

- [x] 5.1 将 `apps/food_app/lib/shells/js_message.dart`、`js_payload.dart` 迁移到 `packages/app_common/lib/web_shells/`
- [x] 5.2 将 `apps/food_app/lib/shells/web_shell_one_page.dart` 迁移到 `packages/app_common/lib/web_shells/web_shell_one_page.dart`
- [x] 5.3 将 `apps/food_app/lib/shells/web_shell_two_page.dart` 迁移到 `packages/app_common/lib/web_shells/web_shell_two_page.dart`
- [x] 5.4 在公共包内提取 shared 逻辑（可选）：t.me 拦截、window.open override 注入、inAppJump 行为（in-webview vs external）
- [x] 5.5 保持“控制事件不进埋点”的规则（openWindow/openSafari 等仅用于导航，不调用 trackEvent）

## 6. 抽离 ATT Alignment（非阻塞 + 会话去重）

- [x] 6.1 将 `apps/food_app/lib/services/att_service.dart` 迁移到 `packages/app_common/lib/att/att_service.dart`
- [x] 6.2 可选：提供 `AttLifecycleBinder`（或 mixin/helper）简化 host app 绑定 `initState` + `resumed` 触发
- [x] 6.3 在 `apps/food_app/ios/Runner/Info.plist` 校验 `NSUserTrackingUsageDescription` 仍存在（每个新马甲包也必须配置）

## 7. food_app 迁移与清理

- [x] 7.1 在 `apps/food_app/pubspec.yaml` 增加对 `packages/app_common` 的 path 依赖，并确保依赖解析通过
- [x] 7.2 更新 `apps/food_app/lib/*` 的 imports：统一从 `package:app_common/...` 引用抽离后的能力
- [x] 7.3 `FoodApp`（`apps/food_app/lib/app.dart`）改为使用公共包的 ATT service（或 binder），并保留现有生命周期触发语义
- [x] 7.4 删除/精简 `food_app` 内被迁移的重复文件（避免双实现）

## 8. 可验证性（回归与测试）

- [x] 8.1 跑通 `food_app` iOS 启动：本地 tabs / shell one / shell two / external 四种路径（remote-config 不同组合）
- [x] 8.2 验证 WebShell One：`Post/event` 事件可解析且可转发埋点；`t.me` 强制外跳；window.open 被拦截
- [x] 8.3 验证 WebShell Two：UA 设置 best-effort；`eventTracker/openSafari` 可解析；window.open 被拦截；inAppJump 生效
- [x] 8.4 验证 analytics：`eventtype=af/ad` 两种初始化路径不崩溃；revenue 规则保持一致
- [x] 8.5 验证 ATT：首次启动/恢复时 best-effort 请求不阻塞 boot；Info.plist key 完整避免崩溃


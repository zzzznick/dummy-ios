## Context

当前 `apps/food_app` 已实现一整套马甲包共性能力，并且在 app 内部已经按目录拆分为：

- `lib/boot/*`：远端配置拉取 + 启动路由决策 + 启动编排（含重试/网络恢复）
- `lib/analytics/*`：AppsFlyer/Adjust 初始化与事件桥
- `lib/shells/*`：Web Shell One/Two（WebView 注入、channel、消息解析、事件转发、外跳/内跳）
- `lib/services/att_service.dart`：ATT best-effort 请求（不阻塞启动）

但这些代码仍属于单一 app 的实现，未来新马甲包复用会落入复制粘贴 + 局部改造，容易产生：

- 行为漂移（拦截规则、事件格式、初始化时机不一致）
- 配置散落（endpoint、event token map、UA、inAppJump 等）
- iOS 隐私/权限对齐遗漏（Info.plist key 缺失导致 TCC 闪退）

本设计采用**方案 A：一个 repo 内共享 Dart package（path 依赖）**，在包内按能力分模块，提供稳定的对外 API 和配置注入点。

## Goals / Non-Goals

**Goals:**

- 将以下能力抽离为可复用公共模块（单包多模块）：
  - Boot：远端配置拉取、重试/网络恢复触发、启动路由决策
  - Analytics：AppsFlyer/Adjust 初始化与统一事件上报
  - Web Shell One/Two：注入 + channel + 消息解析 + 事件桥 + 外跳/内跳规则
  - ATT：best-effort 请求与推荐的生命周期触发方式（不阻塞 boot）
- 把“马甲差异点”显式化为 app 层注入项：
  - 远端配置 endpoint（不同包、不同环境）
  - 本地落地页（如 `LocalTabsPage`）
  - 外跳实现（URL launcher 或系统浏览器策略）
  - Analytics 的默认 token map / 环境 / 过滤策略（需要时）
- `apps/food_app` 迁移为依赖公共模块，保证行为与当前一致（无感迁移）。

**Non-Goals:**

- 不做对远端配置字段含义/协议的重大变更（仅抽离与配置化）
- 不将“应用品牌差异”（主题、文案、图标、bundleId 等）放入公共模块
- 不自动修改各马甲包的 iOS `Info.plist`（只在设计/任务中明确要求）

## Decisions

### 1) 单一公共 package + 内部模块化

**Decision：** 新增 `packages/food_app_common/`（名称可在实现阶段最终确定），在 `lib/` 下按能力分目录：

- `lib/boot/*`
- `lib/remote_config/*`
- `lib/analytics/*`
- `lib/web_shells/*`
- `lib/att/*`
- `lib/routing/*`

**Rationale：**

- Boot/Analytics/WebShell 之间存在天然耦合（Boot 决策路由到 Shell；Shell 需要 Analytics；二者共享 remote config model）
- 单包降低 path 依赖碎片化，利于新马甲包快速接入

**Alternatives considered：**

- 多 package（bootkit/analytics/webshell/att 分包）：边界更纯，但早期维护成本更高、变更更碎

### 2) 对外 API 以“配置 + 依赖注入 + 策略接口”为中心

**Decision：** 公共模块不持有 app 级常量（如 endpoint、App 名），而是通过构造参数注入。

建议的核心类型（命名可实现时微调）：

- `RemoteConfigClient(endpoint, dio)`：只负责拉取与解析（不硬编码 endpoint）
- `BootDecisionStrategy`：给默认实现（兼容当前 `platform/url` 规则），允许马甲包覆写
- `BootCoordinator`：负责启动编排（拉取、重试、网络恢复触发、analytics configure、路由执行）
  - 需要注入：`RemoteConfigClient`、`Connectivity`、`ExternalNavigator`、`AnalyticsBridge`、`BootDecisionStrategy`
  - 需要注入：`WidgetBuilder localHomeBuilder`（本地落地页，如 LocalTabs）
- `AnalyticsBridge`：保留 `configure(RemoteConfigItem)` + `trackEvent(name,payload)`
  - 提供可注入的默认 token map、Adjust 环境、事件过滤器（例如忽略 openWindow 之外的某些噪声事件）
- `WebShellOnePage` / `WebShellTwoPage`：保持两套页面对外使用方式一致：
  - 注入：`initialUrl`、`RemoteConfigItem config`、`AnalyticsBridge analytics`、`ExternalNavigator externalNavigator`
  - 共享：window.open override、t.me 拦截规则、inAppJump 决策（in-app load vs external）

**Rationale：**

- 新马甲包最常变化的是 endpoint 与落地页；用注入能避免 fork 公共模块
- 保持 BootCoordinator 作为“可复用启动骨架”，避免每个马甲包重复写启动流程

**Alternatives considered：**

- 公共模块内部读 `--dart-define`：会把环境/注入机制耦合在包内部，降低可测试性与可替换性

### 3) 初始化时序保持“ATT 不阻塞 boot，analytics 按需配置”

**Decision：**

- ATT：仍为 best-effort，建议由 app 壳（`FoodApp`）在 `initState` 与 `resumed` 时触发；公共模块提供 `AttService`，可选提供一个 `AttLifecycleBinder` 帮助绑定生命周期。
- analytics：仅当 remote config 需要并且 boot 决策进入 web/external 时才配置（与当前一致：进入本地 tabs 不强制初始化）
- boot：重试/网络恢复触发逻辑由 `BootCoordinator` 统一实现，避免多个马甲包出现不同 backoff 行为

**Rationale：**

- ATT 弹窗不应阻塞远端配置拉取与路由（当前已满足）
- analytics SDK 初始化失败不能影响启动

### 4) iOS 隐私 Usage Description 由 app 壳负责，公共模块只声明约束

**Decision：**

- 文档/任务明确要求：凡使用 ATT capability 的马甲包，必须在其 `ios/Runner/Info.plist` 配置 `NSUserTrackingUsageDescription`

**Rationale：**

- iOS TCC 缺 key 会直接崩溃，且每个马甲包文案可能不同，不能由公共模块统一写死

## Risks / Trade-offs

- **[依赖归属混乱]** 公共包与 app 重复声明依赖 → **Mitigation**：公共包声明其需要的插件依赖；app 仅保留自身 UI/本地功能依赖，迁移时逐步清理
- **[路由/注入边界不清]** BootCoordinator 直接引用 app 页面类型 → **Mitigation**：通过 `WidgetBuilder` / `WidgetFactory` 注入本地落地页
- **[WebView 行为平台差异]** 不同 WebView 版本对“document start 注入”支持差异 → **Mitigation**：保持 best-effort 注入与容错；关键注入点统一封装，便于后续统一修复
- **[ATT 合规遗漏]** 新马甲包忘记补 Info.plist key → **Mitigation**：任务清单中加入 “Info.plist 检查项”，并在公共模块文档中醒目提示


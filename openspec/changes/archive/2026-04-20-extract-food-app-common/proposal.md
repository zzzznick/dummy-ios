## Why

目前 `apps/food_app` 已实现启动编排（远端配置 + 路由决策）、Analytics 初始化与事件桥、两套 Web Shell、以及 iOS ATT 行为对齐。这些能力属于“马甲包共性”，但现在仍内聚在单个 app 里，导致后续新马甲包需要复制粘贴与二次改造，风险高、迭代慢、且容易出现行为不一致。

现在抽离为公共模块（方案 A：单一 package 内部分模块），让新马甲包只需要注入少量配置与策略即可复用同一套启动/埋点/WebView/ATT 行为。

## What Changes

- 新增一个 repo 内共享 Dart package（path 依赖）作为公共模块，沉淀以下能力：
  - Boot：远端配置拉取、失败重试与网络恢复触发、启动路由决策
  - Analytics：AppsFlyer/Adjust 初始化与统一事件上报接口
  - Web Shell One：JS bridge 注入、消息解析、事件上报与外跳/内跳规则
  - Web Shell Two：自定义 UA、JS channel 接入、事件上报与外跳/内跳规则
  - iOS 行为对齐：ATT best-effort 请求（不阻塞 boot）
- `apps/food_app` 迁移为依赖公共模块，并保留自身差异点（App 名称/主题/图标、本地 Tab 页面、远端配置 endpoint 等）在 app 层配置/注入。
- 远端配置 endpoint 不再由实现硬编码，改由 app 层注入（支持不同马甲包/环境配置）。

## Capabilities

### New Capabilities

- `bootkit`: 远端配置拉取、启动编排与路由决策的可复用能力（支持注入 endpoint、策略与依赖）
- `analytics-bridge`: AppsFlyer/Adjust 初始化与事件桥（支持配置来自远端配置）
- `web-shells`: Web Shell One/Two 的通用拦截、注入与事件桥能力（保留两套协议差异）
- `att-alignment`: ATT best-effort 请求与生命周期触发建议（Info.plist 由 app 壳负责）

### Modified Capabilities

- （无）

## Impact

- 代码结构：新增 `packages/<common-package>/`；`food_app` 相关目录改为从 package 引用
- 依赖：`food_app` 对 `dio/connectivity_plus/webview_flutter/...` 等依赖可能需要上移或在公共包中声明
- iOS：继续要求 `ios/Runner/Info.plist` 保留 `NSUserTrackingUsageDescription`（每个马甲包都要配置）

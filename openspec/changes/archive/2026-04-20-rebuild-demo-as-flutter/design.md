## Context

- 现有 iOS demo 位于 `demo/ABiteOfMouthFeastBook_5.28`，启动入口为 `AppDelegate` → `FirstController`，其通过 MockAPI 拉取远端配置，决定进入：
  - `oneView`（WebView + JSBridge + AppsFlyer/Adjust）
  - `twoView`（WebView + JSBridge + 自定义 UA + Adjust）
  - 或外跳 Safari
  - 否则进入本地 Tab 业务（以 Xcode target 实际编译功能集合为准：Feast/Recipe/Diary 三个 Tab）
- demo 中存在文件重复/缺失导致的“源码不一致但 target 只编译其中一套”的现象；Flutter 迁移以 **运行时行为** 为唯一基准。
- 目标是将以上行为在 Flutter 中复刻，并落到仓库内 `apps/food_app`。

## Goals / Non-Goals

**Goals:**
- 复刻启动路由决策：远端配置拉取 + 网络恢复重试 + 单会话去重。
- 复刻 Web Shell One/Two：页面加载、JSBridge、注入对象、外跳策略、新开窗拦截策略、自定义 UA（Two）。
- 复刻 analytics 初始化与事件转发：AppsFlyer/Adjust 初始化、`adeventlist` token 映射、revenue 特判。
- 复刻本地三 Tab 业务：CRUD + 搜索 +（Feast）排序偏好持久化与总消费统计 +（Feast）备份/恢复。
- iOS 对齐：App active 时触发 ATT 请求，但不阻塞启动路由。

**Non-Goals:**
- 不保证兼容读取 iOS 端 `NSKeyedArchiver` 生成的历史数据文件（Flutter 采用自身存储格式）。
- 不补齐 iOS 仓库中未被 target 编译或缺失实现的页面（如 `HomeViewController`、`MapViewController.m`），除非后续另起 change。
- 不在本 change 中完善埋点“服务端验证/对账”，仅复刻客户端调用路径与参数约定。

## Decisions

### Decision: 单一 Boot 状态机驱动初始路由
- **Choice**: 在 Flutter 侧实现一个 `BootCoordinator`（状态机）统一处理：
  - 网络状态监听
  - 远端配置拉取
  - 结果解析与路由决策
  - “一次成功后不重复”的会话级去重
- **Alternatives**:
  - 直接在 `main()` 里写命令式逻辑：实现快但难测、难扩展
  - 各页面自行拉取：会导致重复请求和竞争条件
- **Rationale**: iOS demo 通过通知 + `abmfb_isFirstOpen` 达到类似效果；状态机在 Flutter 更易测试与追踪。

### Decision: WebView 壳以“通道分发器 + provider bridge”实现
- **Choice**: Web Shell One/Two 各自维护：
  - WebView 配置（注入、UA）
  - JS 消息接入（按 channel 解析）
  - 将事件统一交给 `AnalyticsBridge` 处理
  - 将外跳统一交给 `ExternalNavigator` 处理
- **Alternatives**:
  - 把解析/上报写进 WebView 页面：耦合过高，后续难替换 provider
- **Rationale**: 与 spec 中的“web shell → analytics bridge”边界一致。

### Decision: 本地存储选型以“可序列化模型 + 文件/数据库”实现，图片以文件路径存储
- **Choice**: 本地业务模型（Feast/Recipe/Diary）存结构化字段；图片以文件存储并在模型中保存路径/标识。
- **Alternatives**:
  - 直接存 raw bytes：备份/恢复与性能风险更高
  - 强行复刻 iOS 归档格式：投入大且价值低
- **Rationale**: iOS 当前是归档对象写文件；Flutter 更适合显式模型与可迁移数据格式。

### Decision: 远端配置解析严格容错，失败保持可重试
- **Choice**:
  - 解析失败/网络失败不崩溃，保持在 Boot 状态可重试
  - 仅在成功解析并完成路由后“锁定”会话
- **Alternatives**:
  - 失败直接进入本地 Tab：会改变 iOS 行为（iOS 会递归重试请求）
- **Rationale**: iOS `FirstController` 对失败会递归重试，且网络恢复会再触发。

## Risks / Trade-offs

- **[风险] iOS demo 对网络失败的递归重试可能导致 Flutter 侧资源消耗/请求风暴** → **Mitigation**：Flutter 使用退避（backoff）与单飞（single-flight）控制，同时保留“网络恢复触发重试”的语义。
- **[风险] WebView JS 消息格式不稳定（字符串/对象混用）** → **Mitigation**：解析器同时支持字符串与对象；失败记录日志但不中断会话。
- **[风险] Adjust/AppsFlyer SDK 在 Flutter 插件层能力与 iOS 原生存在差异** → **Mitigation**：优先选择官方/主流插件；对齐“初始化 + 事件名/参数”契约，必要时留原生桥接扩展点。
- **[风险] 自定义 UA 设备字段在 Flutter 难以完全 1:1** → **Mitigation**：确保 UA 包含关键子串（`AppShellVer:1.0.0`、model、UUID），并记录差异点；必要时通过平台通道获取更接近的字段。
- **[权衡] 不迁移旧 iOS 数据文件** → **Mitigation**：作为后续独立 change 评估“iOS 导出 JSON → Flutter 导入”的一次性迁移方案。


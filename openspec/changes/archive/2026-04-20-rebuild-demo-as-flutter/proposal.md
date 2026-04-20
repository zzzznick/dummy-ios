## Why

当前仓库的 iOS demo（`demo/ABiteOfMouthFeastBook_5.28`）把“远端开关 + WebView 壳 + 归因埋点”与“本地美食记录（三个 Tab）”耦合在一起，且存在入口/控制器文件不一致（例如多份 `RootTabBarController`、缺失的 `HomeViewController`/`MapViewController.m`），不利于持续迭代与跨平台复用。需要将其 **按现有运行行为原样复刻** 为 Flutter 应用，统一到 `apps/food_app` 以便后续扩展与维护。

## What Changes

- 在 `apps/food_app` 新建 Flutter 应用，复刻 iOS demo 的真实运行路径：
  - 启动后拉取远端配置（MockAPI），并根据返回决定进入 `oneView` / `twoView` / 外跳 Safari / 本地 Tab
  - 网络恢复时重试拉取（对应 iOS 的 Reachability + `GFEDAW` 通知）
- 复刻 `oneView` WebView 壳行为：
  - JSBridge（`Post` + `event` + `Ball`）与注入对象（`jsBridge`、`WgPackage`）
  - `openWindow` 外跳与新开窗拦截策略（含 `t.me` 特判、`inappjump` 行为）
  - AppsFlyer / Adjust 事件上报规则（含 revenue 特判）
- 复刻 `twoView` WebView 壳行为：
  - JSBridge（`eventTracker` + `openSafari`）
  - 自定义 User-Agent 格式（含 `AppShellVer`、model、UUID 等字段）
  - Adjust 事件上报规则（含 revenue 特判）
- 复刻本地业务（以 Xcode target 实际编译的功能集合为准）：
  - 三个 Tab：**My Feast**（用餐记录）、**Recipes**（菜谱）、**Food Diary**（日记）
  - CRUD、搜索、排序/统计（例如 Feast 的排序偏好与总消费）
  - 本地持久化（等价于 iOS 当前的归档写文件语义，不要求兼容旧 iOS 数据文件）
  - 启动后执行“恢复备份”逻辑（对应 iOS `DataBackupManager` 对 `feasts.data` 的备份/恢复）
- iOS 系统行为对齐：
  - App 恢复活跃时触发 ATT 授权流程（iOS 14+）

## Capabilities

### New Capabilities

- `boot-remote-config`: 启动与路由决策；拉取远端配置、网络恢复重试、根据 `platform/url` 决定进入 WebView 壳/外跳/本地 Tab。
- `web-shell-one`: 对应 iOS `oneView` 的 WebView 壳、JSBridge、注入与事件上报策略。
- `web-shell-two`: 对应 iOS `twoView` 的 WebView 壳、JSBridge、自定义 UA 与事件上报策略。
- `analytics-bridge`: AppsFlyer/Adjust 初始化与事件映射（包含 `adeventlist` 事件 token 映射与 revenue 特判）。
- `local-food-feast`: My Feast（用餐记录）本地业务能力：CRUD、搜索、排序、总消费统计、数据备份/恢复。
- `local-food-recipes`: Recipes（菜谱）本地业务能力：CRUD、搜索、图片字段。
- `local-food-diary`: Food Diary（日记）本地业务能力：CRUD、搜索、图片字段。
- `ios-permissions-att`: iOS ATT 授权触发时机与状态处理（Flutter 侧对齐行为）。

### Modified Capabilities

<!-- none -->

## Impact

- 新增 Flutter 工程与依赖（WebView、网络、存储、图片选择、归因/埋点、网络状态监听、权限）。
- 仓库结构新增 `apps/food_app`（可能需要在仓库根部增加多 app 的组织与文档说明）。
- 需要定义一套与 iOS demo 对齐的远端配置数据结构与容错/重试策略，确保行为一致。


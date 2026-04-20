## 1. Repo / Flutter 工程初始化

- [x] 1.1 在仓库根目录创建 `apps/` 目录（如不存在）并生成 Flutter 工程到 `apps/food_app`
- [x] 1.2 固定 Flutter 工程基础配置（bundle id、应用名、最低 iOS 版本、图标资源占位）
- [x] 1.3 添加基础依赖（HTTP、网络状态监听、WebView、URL launcher、存储、图片选择、权限、日志）
- [x] 1.4 建立工程目录结构（boot / shells / analytics / local_tabs / storage / shared）

## 2. Boot 远端配置与路由决策（boot-remote-config）

- [x] 2.1 定义远端配置 model（字段：`url/platform/eventtype/afkey/appid/adkey/adeventlist/inappjump`）与解析容错
- [x] 2.2 实现远端配置拉取（GET）与错误处理（失败不崩溃、可重试）
- [x] 2.3 实现网络恢复触发重试（offline→online）与会话级去重（成功后不再重跑）
- [x] 2.4 实现启动路由决策：platform=1→ShellOne，platform=2→ShellTwo，platform=3→外跳，url 为空→LocalTabs

## 3. Analytics 初始化与事件桥（analytics-bridge）

- [x] 3.1 接入 AppsFlyer Flutter 插件并实现初始化（`eventtype=af` 使用 `afkey/appid`）
- [x] 3.2 接入 Adjust Flutter 插件并实现初始化（`eventtype=ad` 使用 `adkey`，production）
- [x] 3.3 实现 `adeventlist` JSON 映射合并逻辑（远端覆盖/追加内置 token map）
- [x] 3.4 实现 revenue 事件特判（`firstrecharge/recharge/withdrawOrderSuccess`；withdraw 为负）
- [x] 3.5 提供统一 `trackEvent(name, payload)` 接口供 Web shells 调用

## 4. Web Shell One（web-shell-one）

- [x] 4.1 实现 WebView 页面与加载 URL
- [x] 4.2 注入 `window.jsBridge` 与 `window.WgPackage`（app id + version）在 document start
- [x] 4.3 实现 JS 消息接入：`Post`（{name,data}）与 `event`（"name+data"）
- [x] 4.4 实现 `openWindow` 外跳规则（打开 `json.url`）
- [x] 4.5 实现非 `openWindow` 事件转发到 analytics bridge
- [x] 4.6 实现新开窗拦截：t.me 必外跳；否则按 `inappjump` 决定 in-app load 或外跳

## 5. Web Shell Two（web-shell-two）

- [x] 5.1 实现 WebView 页面与加载 URL
- [x] 5.2 实现自定义 UA（包含 `AppShellVer:1.0.0`、model、UUID 等关键字段）
- [x] 5.3 实现 JS 消息接入：`eventTracker`（{eventName,eventValue}）与 `openSafari`（{url}）
- [x] 5.4 `eventTracker` 事件转发到 analytics bridge（兼容 eventValue 为字符串/对象）
- [x] 5.5 复刻新开窗拦截规则（同 Shell One）

## 6. LocalTabs（Feast / Recipes / Food Diary）

- [x] 6.1 实现本地 Tab 容器与三个 Tab（My Feast / Recipes / Food Diary）导航结构
- [x] 6.2 Feast：实现模型、CRUD、列表 UI、详情页 UI、删除
- [x] 6.3 Feast：实现搜索（restaurant/dish）、排序（date/cost 升降序）与排序偏好持久化
- [x] 6.4 Feast：实现总消费统计展示与随数据变更刷新
- [x] 6.5 Feast：实现数据备份/恢复（进入 LocalTabs 时检查备份并恢复）
- [x] 6.6 Recipes：实现模型、CRUD、列表 UI、详情页 UI、删除与按 name 搜索
- [x] 6.7 Diary：实现模型、CRUD、列表 UI、详情页 UI、删除与按 content 搜索
- [x] 6.8 图片：接入图片选择/拍照并将图片以文件形式存储（模型保存路径）

## 7. iOS 行为对齐（ATT）

- [x] 7.1 集成 ATT 权限请求插件并在 app active/resume 时触发一次检查/请求
- [x] 7.2 确保 ATT 流程不阻塞 boot 拉取与路由

## 8. 质量与可验证性

- [x] 8.1 为远端配置解析与路由决策添加单元测试（覆盖 platform/url 组合）
- [x] 8.2 为 JS 消息解析器添加单元测试（Post/event/eventTracker 的多形态 payload）
- [x] 8.3 手动验证清单：平台 1/2/3/空 url 四种路径 + 新开窗拦截 + 事件上报调用不崩溃


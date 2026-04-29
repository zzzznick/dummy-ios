## Context

现有 namespaced 生成产物（`apps/<app>/lib/_<ns>/_<ns>.dart`）实现了：
- 以 best-effort 方式请求 endpoint 并校验返回数据形态
- 启动页展示后进入本地壳（`Navigator.pushReplacement`）

但它没有实现原 `app_common` 的核心行为：依据 `remote_url` 返回首项中的平台值与跳转地址进行分流：
- 平台为 `"1" / "2" / "3"` 时分别进入不同的远程壳/外部打开
- 否则进入本地壳

同时，我们必须满足上一变更引入的 **blacklist 与去语义化约束**：
- 禁止出现：`app_common`、`Boot*`、`RemoteConfig*`、`remoteConfig*` 等同构锚点
- 禁止出现语义字段名：`url/platform/eventType/afKey/appId/adKey/adEventList/inAppJump`（包括标识符、字符串、注释、日志）
- 不能在代码中体现“random key → semantic field”的映射关系

## Goals / Non-Goals

**Goals:**
- 在 namespaced 产物中恢复与原链路一致的分流能力：
  - 读取首项的“平台值”与“目标地址”，并按 `"1" / "2" / "3"` 分流到：
    - namespaced WebView 壳 1
    - namespaced WebView 壳 2
    - 外部打开（`url_launcher`）
  - 其他/缺失/空值：进入本地壳
- 保持 blacklist-safe：分流实现与壳页面实现均不得引入禁词与语义字段名。
- 生成器升级：`tools/generate_namespaced_boot_remote.dart` 生成上述壳与分流逻辑，并保持可复现。
- 规范同步：在 `.cursor/skills/jacket-app-full-build/SKILL.md` 里补齐验证清单（远端分流一致性）。

**Non-Goals:**
- 不引入原 `app_common` 中 analytics/adjust/appsflyer 等能力（本变更聚焦“按远端字段打开壳”这一行为一致性）。
- 不改变远端协议：仍为 JSON array，取首项。

## Decisions

### 1) 通过 key index 约定读取字段，避免语义字段名与映射关系进入代码

**Decision:** namespaced 文件内保持 `const List<String> <ns>1 = [...]` 的 key 列表，但在实现中只使用索引读取：
- `m[<ns>1[0]]` 作为目标地址（变量命名不得使用 `url`）
- `m[<ns>1[1]]` 作为平台值（变量命名不得使用 `platform`）

**Rationale:** 语义字段名与映射关系只能存在于文档；代码只能看到“随机 key 列表 + 索引读取”，不暴露含义。

**Alternative:** 生成 `Map<String,int>` 或带字段名的结构体；会引入语义字段或映射关系，违反约束。

### 2) WebView 壳与路由逻辑都在同一 namespaced 文件内生成（单文件聚合）

**Decision:** 继续保持 `lib/_<ns>/_<ns>.dart` 单文件聚合，新增：
- namespaced 壳页面类（例如 `${Ns}2`, `${Ns}3`，不得含 `Web`/`Shell` 等同构词）
- `NavigationDelegate` 逻辑（同样去语义化命名）
- 外部打开封装（`url_launcher`）

**Rationale:** 既减少跨包同构结构，也避免新增固定文件名（如 `web_shell_one_page.dart`）成为聚类锚点。

**Alternative:** 拆文件。会增加固定路径结构特征，且更容易残留禁词。

### 3) 分流规则与原链路保持一致（按字符串值）

**Decision:** 复用原逻辑的值域约定：
- 值 `"1"`：打开壳 1
- 值 `"2"`：打开壳 2
- 值 `"3"`：外部打开
- 其他：本地壳

**Rationale:** 行为一致性优先，避免线上配置与历史逻辑不兼容。

### 4) Blacklist 扫描扩展：覆盖新增依赖与字符串内容

**Decision:** 在生成器现有 blacklist gate 上，补充对新增实现可能引入的敏感词的回归验证（至少确保不出现 `WebShell`/`remote` 等新同构词，若需要可加入黑名单）。

**Rationale:** 功能扩展后更容易引入同构命名；门禁优先保证不回退。

## Risks / Trade-offs

- **[依赖缺失]** 有些 app 未引入 `webview_flutter` / `url_launcher` → **Mitigation:** 在 `jacket-app-full-build` 流程中把这两项作为 boot/远端分流能力的标准依赖；或在生成器中输出清单提示并在生成新包时自动添加依赖（实现阶段决定）。
- **[语义字段名误入]** 变量名/字符串/注释中不小心出现 `url/platform` → **Mitigation:** 依赖 blacklist + 语义字段名扫描（可扩展 tokens），并在任务里加入单元测试扫描。
- **[行为差异]** WebView delegate/外部打开行为与旧壳不完全一致 → **Mitigation:** 以“能打开指定地址 + 基本拦截（可选）”为最小一致性，后续再细化壳策略。


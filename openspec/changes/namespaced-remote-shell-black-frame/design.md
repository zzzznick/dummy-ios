## Context

当前 namespaced 远程壳（in-app WebView 容器）由生成器 `tools/generate_namespaced_boot_remote.dart` 生成在 `apps/<app>/lib/_<ns>/_<ns>.dart` 中。壳页面需要满足两类审查约束：
- **无标题**：不展示任何标题文案（已在前序变更落地）
- **黑边框架**：顶部/底部安全区区域背景必须为黑色（本次新增）

用户明确要求本次只做“容器黑底”实现，即通过 widget 结构保证安全区露出的背景为黑色，不触及 `SystemChrome`（系统状态栏/导航条）配置。

## Goals / Non-Goals

**Goals:**
- 远程壳页面默认使用黑色背景，并确保顶部与底部安全区区域同样为黑色。
- 仍保持无标题（不引入 `AppBar` 标题文本）。
- 将该约束写入 `jacket-app-full-build`，并给出明确的验证项。

**Non-Goals:**
- 不设置/修改系统 UI（如 `SystemUiOverlayStyle`、状态栏样式等）。
- 不改变远程壳的分流逻辑与加载能力。

## Decisions

### 1) 使用黑色容器 + SafeArea 包裹 WebView

**Decision:** 远程壳页面的结构为：
- `Scaffold(backgroundColor: Colors.black, body: ColoredBox(color: Colors.black, child: SafeArea(child: WebViewWidget(...))))`

其中 `SafeArea` 负责为顶部/底部插入 padding；padding 区域的背景由外层 `ColoredBox` 提供，确保上下露出的区域为黑色。

**Rationale:** 最小改动、可复用、无需系统级 API，且对不同机型（刘海/圆角/home indicator）稳定。

**Alternative:** 使用 `Container(color: ...) + Padding(MediaQuery.viewPadding)` 手动处理。复杂度更高且更易漏边界。

### 2) 约束同步到流程规范

**Decision:** 在 `.cursor/skills/jacket-app-full-build/SKILL.md` 的 Remote shell UI 段落补充：
- 远程壳顶部/底部必须黑色（容器黑底实现）
- 禁止用 `SystemChrome` 作为默认实现路径

## Risks / Trade-offs

- **[WebView 背景露白]** 某些网页加载前可能闪白 → **Mitigation:** WebView 外层黑底至少保证安全区与壳背景为黑；网页内容闪白属于网页自身，可在后续需要时再加加载遮罩（但本变更不做）。


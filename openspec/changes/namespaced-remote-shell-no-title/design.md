## Context

namespaced 远程壳由 `tools/generate_namespaced_boot_remote.dart` 生成在 `apps/<app>/lib/_<ns>/_<ns>.dart` 中。当前生成模板会在壳页面中渲染 `AppBar` 标题（例如 `palette_pilot` 里出现 `Workspace/Browse`），这与审核约束冲突：远程壳不得展示标题文本。

同时，整个 namespaced 方案仍受 blacklist/去同构约束：实现不能引入 `app_common`、`Boot*`、`RemoteConfig*`、以及语义字段名等敏感锚点。标题移除属于 UI 细节，但需要在生成模板与流程规范里形成统一硬约束。

## Goals / Non-Goals

**Goals:**
- 生成的 in-app WebView 容器默认不展示标题栏标题（不出现任何可见标题文本）。
- 在 `apps/palette_pilot` 修复现存标题问题。
- 将该约束同步到 `.cursor/skills/jacket-app-full-build/SKILL.md`（作为 hard validation / checklist）。

**Non-Goals:**
- 不改变远程壳的加载能力与分流规则（`"1"|"2"|"3"` 行为保持不变）。
- 不引入额外“同构 UI 组件名”或固定文案（避免新增聚类特征）。

## Decisions

### 1) 远程壳默认不渲染标题栏标题

**Decision:** 生成模板中的壳页面使用以下之一实现“无标题”：
- 方案 A：不使用 `AppBar`（`Scaffold` 无 `appBar`）
- 方案 B：保留 `AppBar` 但 title 为空（例如 `title: const SizedBox.shrink()`），且不设置任何文字标题

优先采用方案 A（最少 UI 元素）；若需要提供返回按钮/状态栏占位，再采用方案 B。

**Rationale:** 任何固定标题文案都会在批量审查中形成可见锚点；无标题是最稳妥的默认。

### 2) 规范化：把“无标题”写入 jacket 生成流程

**Decision:** 在 `jacket-app-full-build` 的 remote routing parity/validation 段落中加入硬约束：
- 远程壳不得显示标题（任何文本）
- 若存在 `AppBar`，必须无标题

**Rationale:** 防止后续生成包回归；让人工复核有明确检查项。

## Risks / Trade-offs

- **[可用性下降]** 无标题可能影响用户感知当前页面 → **Mitigation:** 远程壳本身为审查敏感区域，优先满足审查约束；必要时可通过页面内容本身表达，而不是标题栏。
- **[回归风险]** 模板变更后，已有包需重跑生成器或手动修复 → **Mitigation:** 在本变更中至少修复 `palette_pilot`，并建议后续生成统一走新模板。


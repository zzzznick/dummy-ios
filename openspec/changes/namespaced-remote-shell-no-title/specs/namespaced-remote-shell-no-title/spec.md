## ADDED Requirements

### Requirement: In-app web container must be titleless
namespaced 远程壳（in-app WebView 容器）MUST NOT 展示任何标题栏标题文本（例如 `Workspace`、`Browse` 或任何固定文案）。

#### Scenario: AppBar omitted
- **WHEN** 远程壳页面渲染
- **THEN** 页面不渲染 `AppBar`（无标题栏区域）

#### Scenario: AppBar present but titleless
- **WHEN** 出于交互/导航需要保留 `AppBar`
- **THEN** `AppBar` MUST 无标题（例如 `title` 为空组件），且 UI 上不出现任何标题文本

### Requirement: Generator must enforce titleless shell by default
生成器（`tools/generate_namespaced_boot_remote.dart`）生成的 namespaced 壳页面 MUST 默认不显示标题栏标题，并使新生成的马甲包遵循该约束。

#### Scenario: Newly generated app has no visible shell title
- **WHEN** 使用生成器生成 `lib/_<ns>/_<ns>.dart`
- **THEN** 远程壳页面默认无标题文本

### Requirement: Process documentation must include the constraint
`.cursor/skills/jacket-app-full-build/SKILL.md` MUST 明确写出“远程壳不能有标题”的硬约束，并在验证清单中包含对应检查项。

#### Scenario: Skill doc includes validation checklist for titleless shell
- **WHEN** 阅读 `jacket-app-full-build` 流程规范
- **THEN** 能看到“远程壳无标题”的硬约束与验证方式


## Why

远程壳（in-app WebView 容器）在审核视角下不应暴露任何“产品/功能标题栏文案”；当前 `palette_pilot` 的 namespaced 壳页面存在 `Workspace/Browse` 标题，需要统一移除并将该约束纳入 `jacket-app-full-build` 流程规范，避免后续马甲包重复出现同类问题。

## What Changes

- 修复 `palette_pilot` 的 namespaced 远程壳：移除标题（不显示 `Workspace` 等文案），保持 UI 极简。
- 更新 `tools/generate_namespaced_boot_remote.dart` 生成的壳页面模板：默认不渲染标题栏标题（必要时可不使用 `AppBar` 或使用无标题的 `AppBar`）。
- 将“远程壳不能有标题”的硬约束同步到 `.cursor/skills/jacket-app-full-build/SKILL.md` 的验证清单/约束中。

## Capabilities

### New Capabilities
- `namespaced-remote-shell-no-title`: 规定并实现 namespaced 远程壳页面不得展示标题栏标题，同时将该规范写入 jacket 生成流程。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `apps/palette_pilot/lib/_vsbwk/_vsbwk.dart`（壳页面 UI）
  - `tools/generate_namespaced_boot_remote.dart`（生成模板）
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md`（新增约束与验证项）


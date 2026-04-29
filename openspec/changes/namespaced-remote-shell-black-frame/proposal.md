## Why

`palette_pilot` 的远程壳需要在顶部/底部安全区呈现黑色（沉浸式黑边），避免出现主题色/白底等“露底”效果；同时该约束需要进入 `jacket-app-full-build` 流程规范，确保后续生成包默认满足。为降低审查风险，本次只做“容器黑底”实现，不引入 `SystemChrome` 等系统 UI 级改动。

## What Changes

- 更新 `palette_pilot` 的 namespaced 远程壳页面：使用黑色容器 + `SafeArea` 包裹 WebView，使顶部与底部安全区背景为黑色。
- 更新 `tools/generate_namespaced_boot_remote.dart` 的壳页面模板：默认生成“容器黑底”版本（仍保持无标题）。
- 将“远程壳顶部/底部黑色（容器黑底实现）”约束同步到 `.cursor/skills/jacket-app-full-build/SKILL.md` 的 hard rules 与验证清单。

## Capabilities

### New Capabilities
- `namespaced-remote-shell-black-frame`: namespaced 远程壳默认黑底框架（覆盖顶部/底部安全区），并同步到 jacket 生成流程规范。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `apps/palette_pilot/lib/_vsbwk/_vsbwk.dart`
  - `tools/generate_namespaced_boot_remote.dart`
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md`


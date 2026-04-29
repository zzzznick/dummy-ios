## ADDED Requirements

### Requirement: No log/print calls in jacket app lib/
对所有马甲包，`apps/<app>/lib/**.dart` MUST NOT 出现任何打印/日志输出相关调用或直接使用点（源码层面禁止）。

禁止 token（最小集合，可扩展）：
- `print(`
- `debugPrint(`
- `developer.log(`
- `Logger(`（`logger` 包的直接使用点）
- `.i(`、`.w(`、`.e(`（当与 `Logger` 相关联时）

#### Scenario: Lib scan finds no forbidden tokens
- **WHEN** 对某个马甲包执行 `apps/<app>/lib/**.dart` 扫描
- **THEN** 不得命中任何禁止 token；若命中必须报告文件路径与 token

### Requirement: Palette Pilot is cleaned as a reference jacket
`apps/palette_pilot/lib/**.dart` MUST 作为参考实现，清理并不包含任何上述禁止 token。

#### Scenario: Palette Pilot passes the no-logs scan
- **WHEN** 对 `apps/palette_pilot/lib/**.dart` 执行同样的扫描
- **THEN** 不得命中任何禁止 token

### Requirement: Jacket build process documents the constraint and validation
`.cursor/skills/jacket-app-full-build/SKILL.md` MUST 明确写出“不能有任何打印/日志相关的东西”的硬约束，并包含可执行的验证方式（扫描 `lib/**.dart` 命中即失败）。

#### Scenario: Skill doc includes a validation checklist
- **WHEN** 阅读 `jacket-app-full-build` 流程规范
- **THEN** 能看到禁止项清单与验证步骤


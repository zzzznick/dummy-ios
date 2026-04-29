## Why

马甲包在批量审查场景下，任何 `print/debugPrint/logger` 等日志输出以及相关调试文案都会形成明显的审查锚点，并可能暴露启动链路、远端分流与壳行为。需要在 `palette_pilot` 中彻底移除这些调试/打印相关内容，并把“`lib/**` 禁止任何打印/日志”的硬约束纳入 `jacket-app-full-build` 流程规范与验证清单，防止后续生成包回归。

## What Changes

- 清理 `apps/palette_pilot/lib/**`：移除所有打印/日志/调试输出相关调用（包括 `print`、`debugPrint`、`Logger`、`developer.log` 等）。
- 将“无日志”要求加入 `.cursor/skills/jacket-app-full-build/SKILL.md`：
  - 明确禁止项清单
  - 给出验证方式（扫描 `apps/<app>/lib/**` 命中即失败）
- （可选实现点）将无日志扫描接入生成器门禁（如 `tools/generate_namespaced_boot_remote.dart` 的 gate），统一在生成完成时 fail-fast。

## Capabilities

### New Capabilities
- `jacket-no-logs`: 马甲包 `lib/**` 无任何打印/日志输出的规范与执行（样例包清理 + 流程硬约束 + 验证方式）。

### Modified Capabilities
- （无）

## Impact

- 影响代码：
  - `apps/palette_pilot/lib/**`（清理日志/调试输出）
  - 可能影响生成器门禁（若选择接入统一扫描）
- 影响流程规范：
  - `.cursor/skills/jacket-app-full-build/SKILL.md`


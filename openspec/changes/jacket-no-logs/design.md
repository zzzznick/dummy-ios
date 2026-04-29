## Context

当前仓库已逐步把马甲包启动/远端链路改为 namespaced 生成，并通过 blacklist gate 降低跨包同构与敏感信息暴露。但日志/打印仍是非常显眼的审查锚点：
- 源码中出现 `print/debugPrint` 等调用会被快速 grep 命中
- `logger` 包的 `.i/.w/.e` 也会暴露运行时行为与错误路径

用户要求：
- `palette_pilot` 必须移除所有 debug/打印相关信息
- `jacket-app-full-build` 需要明确“不能有任何打印相关的东西”

## Goals / Non-Goals

**Goals:**
- 在 `apps/palette_pilot/lib/**` 中清理所有打印/日志输出相关代码。
- 在 `jacket-app-full-build` 中新增 hard rule + validation：`apps/<app>/lib/**` 不允许出现任何打印/日志相关内容。
- 提供可执行的验证方式（字符串扫描），命中即失败并报告文件。

**Non-Goals:**
- 不对第三方 SDK 内部日志做“运行时拦截”；本变更聚焦源码层面的显式调用与依赖使用。
- 不要求移除依赖本身（例如 `logger` 作为依赖是否保留由实现阶段评估；即使保留也必须确保代码里不使用它输出）。

## Decisions

### 1) 禁止项以“可 grep 的 token 清单”表达，并用于门禁扫描

**Decision:** 在规范与验证中使用明确 token 清单（可扩展）：
- `print(`
- `debugPrint(`
- `Logger(` / `logger`
- `.i(` / `.w(` / `.e(`（配合 `Logger` 使用）
- `developer.log(` / `log(`

扫描范围限定为 `apps/<app>/lib/**.dart`，不扫描 README/复核说明与 tests（避免误伤文档与测试辅助）。

### 2) palette_pilot 清理优先“删调用”，不引入条件编译或 debug flag

**Decision:** 对 `palette_pilot` 直接移除打印/日志调用；不采用 `kDebugMode` 分支保留调试输出。

**Rationale:** 用户要求“不能有任何打印相关的东西”，源码层面应当彻底消失，而不是仅在 release 不执行。

### 3) 规范同步到 jacket-app-full-build，并给出执行性验证步骤

**Decision:** 在 `jacket-app-full-build` 的 Validation 段落加入：
- “No logs in lib/”硬约束（列出禁止 token）
- 一个可执行的检查方式（例如使用 `rg`/脚本扫描，或通过生成器 gate 输出）

## Risks / Trade-offs

- **[误杀]** token 扫描可能误伤普通字符串 → **Mitigation:** 扫描仅对 `.dart` 源文件，且优先匹配调用形态（例如 `print(`），降低误命中概率。
- **[漏网]** 有些日志来自别名/封装函数 → **Mitigation:** 先覆盖常见调用点；必要时在实现阶段补充规则（例如禁止自定义 `logX(` wrapper 的命名约定）。


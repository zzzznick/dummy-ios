## 1. 清理 palette_pilot 打印/日志

- [x] 1.1 扫描并移除 `apps/palette_pilot/lib/**.dart` 中的 `print(` / `debugPrint(` / `developer.log(` / `Logger(` / `.i(` `.w(` `.e(` 等日志调用
- [x] 1.2 复跑测试：`cd apps/palette_pilot && flutter test`

## 2. 流程规范同步（jacket-app-full-build）

- [x] 2.1 更新 `.cursor/skills/jacket-app-full-build/SKILL.md`：加入 “No logs in lib/ (mandatory)” 的硬约束与 token 清单
- [x] 2.2 在 Validation 清单中加入可执行验证方式（扫描 `apps/<app>/lib/**.dart` 命中即失败）

## 3.（可选）生成器门禁

- [x] 3.1 若需要：将无日志扫描接入生成器 gate（对 `apps/<app>/lib/**.dart`），以便生成后 fail-fast


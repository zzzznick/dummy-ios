## 1. 修复 palette_pilot 远程壳标题

- [x] 1.1 更新 `apps/palette_pilot/lib/_vsbwk/_vsbwk.dart`：远程壳页面不显示任何标题文本（移除 `Workspace/Browse`）
- [x] 1.2 更新/补充测试：验证远程壳页面无标题（且不影响现有分流测试）

## 2. 更新生成器模板

- [x] 2.1 更新 `tools/generate_namespaced_boot_remote.dart`：生成的壳页面默认不渲染标题栏标题（无 `AppBar` 或 `AppBar` title 为空）
- [x] 2.2 重新生成 `palette_pilot` 的 namespaced 文件并确保 blacklist gate 通过

## 3. 流程规范同步

- [x] 3.1 更新 `.cursor/skills/jacket-app-full-build/SKILL.md`：加入“远程壳不能有标题”的硬约束与验证项
- [x] 3.2 跑 `cd apps/palette_pilot && flutter test` 验证无回归


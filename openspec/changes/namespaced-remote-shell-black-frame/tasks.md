## 1. 远程壳黑底框架（palette_pilot）

- [x] 1.1 更新 `apps/palette_pilot/lib/_vsbwk/_vsbwk.dart`：远程壳页面使用黑色容器 + `SafeArea` 包裹 WebView，确保顶部/底部安全区背景为黑色
- [x] 1.2 补充测试/断言：验证生成文件包含黑底容器结构（不引入 SystemChrome）

## 2. 生成器模板更新

- [x] 2.1 更新 `tools/generate_namespaced_boot_remote.dart`：壳页面模板默认“容器黑底 + SafeArea”，并保持无标题
- [x] 2.2 重跑生成器刷新 `palette_pilot` 的 namespaced 文件并确保 blacklist gate 通过

## 3. 流程规范同步

- [x] 3.1 更新 `.cursor/skills/jacket-app-full-build/SKILL.md`：加入“远程壳顶部/底部黑色（只做容器黑底）”硬约束与验证项
- [x] 3.2 跑 `cd apps/palette_pilot && flutter test` 验证无回归


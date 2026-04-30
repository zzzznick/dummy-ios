## 1. Namespaced 归因桥实现（生成器）

- [x] 1.1 扩展 `tools/generate_namespaced_boot_remote.dart`：在 namespaced 文件中生成归因桥（配置 + track），best-effort 且无日志
- [x] 1.2 在 namespaced 壳 1/壳 2 中分别加入 JS channel，按 platform 绑定协议解析（oneview / eventTracker）
- [x] 1.3 确保实现不引入 blacklist/no-logs token，且不出现语义字段映射关系（继续使用 key index 读取）

## 2. palette_pilot 验证

- [x] 2.1 重跑生成器刷新 `apps/palette_pilot/lib/_vsbwk/_vsbwk.dart`
- [x] 2.2 增加/更新测试：模拟 JS message（两协议）并断言 native 侧会调用归因桥 track 入口（可通过注入 hook 替换 SDK 调用以避免真上报）
- [x] 2.3 跑 `cd apps/palette_pilot && flutter test`

## 3. 流程规范同步

- [x] 3.1 更新 `.cursor/skills/jacket-app-full-build/SKILL.md`：补齐归因桥接说明、platform→协议绑定关系与验证清单


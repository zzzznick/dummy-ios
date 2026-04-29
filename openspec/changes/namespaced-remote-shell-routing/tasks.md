## 1. Namespaced 分流能力实现

- [x] 1.1 在 `tools/generate_namespaced_boot_remote.dart` 中为 `lib/_<ns>/_<ns>.dart` 增加分流：读取首项两字段并按 `"1"|"2"|"3"` 分流（本地/壳1/壳2/外部）
- [x] 1.2 在 namespaced 单文件内生成两种壳形态（WebView），并确保类名/字段名/字符串不引入禁词与语义字段名
- [x] 1.3 增加外部打开封装（`url_launcher`），并保持无禁词/无语义字段名

## 2. 门禁与回归验证

- [x] 2.1 扩展/复核 blacklist + 语义字段名扫描覆盖新增代码路径（确保不会引入 `WebShell` 等新同构锚点）
- [x] 2.2 在 `apps/palette_pilot` 上做验证：构造 `remote_url` 首项 `vsbwkPlaf="1"` 且 `vsbwkUr="<test-url>"` 时进入壳 1（可用 widget test / 最小可运行验证）
- [x] 2.3 运行 `flutter test`（至少 `apps/palette_pilot`），并确保生成器退出码为 0（门禁通过）

## 3. 流程规范同步

- [x] 3.1 更新 `.cursor/skills/jacket-app-full-build/SKILL.md`：补齐“远端分流一致性”接入点与验证清单（包含 `"1"|"2"|"3"` 的行为说明）
- [x] 3.2 更新相关 README/复核说明模板（如需要）：确保文档仍是 mapping 真相来源，且不要求代码出现映射关系


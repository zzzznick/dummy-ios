## ADDED Requirements

### Requirement: Remote shell top/bottom safe areas are black (container-only)
namespaced 远程壳（in-app WebView 容器）MUST 通过“容器黑底”的方式确保：
- 顶部安全区区域背景为黑色
- 底部安全区区域背景为黑色

实现 MUST 为 widget 结构层面的黑底（例如 `Scaffold/ColoredBox`），并且 MUST NOT 依赖 `SystemChrome` / `SystemUiOverlayStyle` 作为默认路径。

#### Scenario: Black top safe area
- **WHEN** 远程壳页面在带刘海/状态栏安全区的设备上显示
- **THEN** 顶部安全区露出的区域背景为黑色

#### Scenario: Black bottom safe area
- **WHEN** 远程壳页面在带 Home Indicator/底部安全区的设备上显示
- **THEN** 底部安全区露出的区域背景为黑色

### Requirement: Generator default template includes black frame
生成器（`tools/generate_namespaced_boot_remote.dart`）生成的远程壳页面 MUST 默认带黑色框架（顶部/底部安全区黑底），并保持无标题约束不回退。

#### Scenario: Newly generated namespaced shell is titleless and black-framed
- **WHEN** 使用生成器生成 `lib/_<ns>/_<ns>.dart`
- **THEN** 远程壳页面无标题文本
- **THEN** 顶部/底部安全区背景为黑色（容器黑底实现）

### Requirement: Jacket build process docs include the constraint
`.cursor/skills/jacket-app-full-build/SKILL.md` MUST 包含该约束与验证项，明确“只做容器黑底”。

#### Scenario: Skill doc includes validation checklist
- **WHEN** 阅读 `jacket-app-full-build` 规范
- **THEN** 能看到远程壳顶部/底部黑色（容器黑底）要求与检查方式


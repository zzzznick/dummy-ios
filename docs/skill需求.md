1. 这个skill主要用在cursor中，方便其识别并创建新的flutter ios马甲包

2. 流程：要求输入马甲包类型（工具包、游戏包），如果没有则随机定一个包类型 -> 在apps目录中生成应用，需要集成 app_common 相关逻辑 -> 检查 Info.plist 相关权限是否定义（要求一定有ATT）

3. Cursor Skills（项目级）：

- `.cursor/skills/jacket-flutter-app-create`：创建 Flutter iOS 马甲包骨架 + 集成 `app_common` 的启动链路
- `.cursor/skills/jacket-remote-config-keyset`：为马甲包生成 remote-config 随机字段 keyset，并生成 per-app namespaced 启动/remote 单文件（`lib/_<ns>/_<ns>.dart`）与 README 映射及 `remote_url` 示例（调用 `tools/generate_namespaced_boot_remote.dart`，含 lib/** blacklist 门禁）
- `.cursor/skills/jacket-ios-privacy-plist-check`：自检/补齐 `ios/Runner/Info.plist` 权限文案（必须包含 ATT 的 `NSUserTrackingUsageDescription`）
- `.cursor/skills/jacket-app-full-build`：单一入口，串联“生成真实全英文 App + 集成启动链路 + remote_url/字段随机化 + Info.plist(ATT) 自检补齐”

4. 推荐使用顺序：

- 先用 `jacket-flutter-app-create` 生成 app
- 再用 `jacket-remote-config-keyset` 生成随机字段并把输出追加到新包 README
- 最后用 `jacket-ios-privacy-plist-check` 检查/补齐 Info.plist（含 ATT）

5. 如果希望只用一个 skill 完成全部流程：直接使用 `jacket-app-full-build`
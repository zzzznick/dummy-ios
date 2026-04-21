---
name: jacket-ios-privacy-plist-check
description: Audits and updates iOS Runner/Info.plist usage descriptions (including ATT) for a Flutter jacket app. Use when generating iOS 马甲包, modifying iOS permissions, adding SDKs that touch privacy, or when the user mentions Info.plist, ATT, tracking, camera, photo library, location, microphone, contacts, bluetooth.
---

# iOS `Info.plist` 权限文案自检与补齐（含 ATT）

## 适用场景

- 生成 Flutter iOS 马甲包后，需要确认 `ios/Runner/Info.plist` 不会因缺失权限 Key 而 TCC 闪退
- 集成/启用会触发权限的 SDK（ATT、相机、相册、定位、麦克风等）
- 用户明确要求“必须有 ATT”

## 目标

- 对指定 app：`apps/<app_name>/ios/Runner/Info.plist`
  - **确保包含** `NSUserTrackingUsageDescription`（ATT）
  - 对已使用的能力补齐对应 Usage Description Key
  - 不引入无意义/误导的权限描述（与实际使用保持一致）

## 工作流程

### 1) 确定目标 app

- 目标路径：`apps/<app_name>/ios/Runner/Info.plist`

### 2) 扫描依赖与代码使用

至少检查：
- `pubspec.yaml` 是否包含可能触发权限的插件：
  - `app_tracking_transparency` → ATT
  - `image_picker` → 相机/相册
  - `permission_handler` → 多权限
  - `device_info_plus` → 通常不需要 Usage Description，但可能涉及隐私披露（以 Apple 要求为准）
- iOS 原生侧（如有）是否主动调用相关 API

### 3) 补齐常见 Key（按实际使用）

**必须（本项目要求）：**
- `NSUserTrackingUsageDescription`

**按需添加：**
- 相机：`NSCameraUsageDescription`
- 相册读取：`NSPhotoLibraryUsageDescription`
- 相册写入：`NSPhotoLibraryAddUsageDescription`
- 定位（前台）：`NSLocationWhenInUseUsageDescription`
- 定位（常驻）：`NSLocationAlwaysAndWhenInUseUsageDescription`
- 麦克风：`NSMicrophoneUsageDescription`
- 通讯录：`NSContactsUsageDescription`
- 蓝牙：`NSBluetoothAlwaysUsageDescription`

### 4) 文案要求

- 文案必须可被审核理解，说明用途与用户收益
- 避免泛化“用于改善体验”这类空话；尽量贴合实际功能
- 若该马甲包类型不同（工具包/游戏包），允许文案有轻微差异，但不得与实际行为冲突

### 5) 验证

- `flutter build ios --no-codesign`（环境允许时）
- 至少运行一次 iOS 模拟器启动，确保不因缺失 Key 崩溃（如可执行）


# food_app

A new Flutter project.

## Remote Config 字段映射（remote_url）

本仓库 demo app 使用明文字段名（便于本地调试）。马甲包生成时请使用 `tools/generate_remote_config_keyset.dart` 生成专属随机字段名，并将映射/示例写入该包 README。

### demo 默认字段（与 `lib/boot/remote_config_keys.dart` 一致）

```json
{
  "url": "url",
  "platform": "platform",
  "inappjump": "inappjump",
  "eventtype": "eventtype",
  "afkey": "afkey",
  "appid": "appid",
  "adkey": "adkey",
  "adeventlist": "adeventlist"
}
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

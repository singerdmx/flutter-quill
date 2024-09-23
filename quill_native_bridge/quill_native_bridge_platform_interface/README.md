# 🪶 Quill Native Bridge

A common platform interface for the [`quill_native_bridge`](https://pub.dev/packages/quill_native_bridge) plugin.

This interface allows platform-specific implementations of the `quill_native_bridge` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## ⚙️ Usage

To implement a new platform-specific implementation of `quill_native_bridge`, extend [`QuillNativeBridgePlatform`](./lib/quill_native_bridge_platform_interface.dart) with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `QuillNativeBridgePlatform` by calling:

```dart
QuillNativeBridgePlatform.instance = MyPlatformQuillNativeBridge();
```

## 📉 Note on breaking changes

The `quill_native_bridge` is intended for internal use and exclusively for `flutter_quill`. Breaking changes may occur.
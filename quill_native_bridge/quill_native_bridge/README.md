# 🪶 Quill Native Bridge

An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill) package to access platform-specific APIs.

> [!NOTE]
> **Internal Use Only**: Exclusively for `flutter_quill`. Breaking changes may occur.

| Feature                  | iOS  | Android | macOS | Windows | Linux | Web   |
|--------------------------|------|---------|-------|---------|-------|-------|
| **isIOSSimulator**        | ✅   | ⚪      | ⚪    | ⚪      | ⚪    | ⚪    |
| **getClipboardHtml**      | ✅   | ✅      | ✅    | ✅      | ✅    | ✅    |
| **copyHtmlToClipboard**   | ✅   | ✅      | ✅    | ✅      | ✅    | ✅    |
| **copyImageToClipboard**  | ✅   | ✅      | ✅    | ❌      | ✅    | ✅    |
| **getClipboardImage**     | ✅   | ✅      | ✅    | ❌      | ✅    | ✅    |
| **getClipboardGif**       | ✅   | ✅      | ⚪    | ⚪      | ⚪    | ⚪    |


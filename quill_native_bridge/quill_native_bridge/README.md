# 🪶 Quill Native Bridge

An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill) package to access platform-specific APIs.

> [!NOTE]
> **Internal Use Only**: Exclusively for `flutter_quill`. Breaking changes may occur.

| Feature                      | iOS  | Android | macOS | Windows | Linux | Web    | Description                                                                                             |
|------------------------------|------|---------|-------|---------|-------|--------|---------------------------------------------------------------------------------------------------------|
| **isIOSSimulator**           | Yes  | No      | No    | No      | No    | No     | Checks if the code is running in an iOS simulator.                                                     |
| **getClipboardHtml**         | Yes  | Yes     | Yes   | Yes     | Yes   | Yes    | Retrieves HTML content from the system clipboard.                                                      |
| **copyHtmlToClipboard**      | Yes  | Yes     | Yes   | No      | Yes   | Yes    | Copies HTML content to the system clipboard.                                                           |
| **copyImageToClipboard**     | Yes  | Yes     | Yes   | No      | Yes   | Yes    | Copies an image to the system clipboard.                                                                |
| **getClipboardImage**        | Yes  | Yes     | Yes   | No      | Yes   | Yes    | Retrieves an image from the system clipboard.                                                           |
| **getClipboardGif**          | Yes  | Yes     | No    | No      | No    | No     | Retrieves a GIF from the system clipboard.                                                              |

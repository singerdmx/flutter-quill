/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, Uint8List, defaultTargetPlatform, kIsWeb;

import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

export 'package:quill_native_bridge_platform_interface/src/platform_feature.dart'
    show QuillNativeBridgeFeature;

/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
///
/// See [QuillNativeBridgeFeature] to check whatever if a feature is supported.
class QuillNativeBridge {
  QuillNativeBridge._();

  static QuillNativeBridgePlatform get _platform =>
      QuillNativeBridgePlatform.instance;

  /// Check if the app is running on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  ///
  /// Should only be called when [defaultTargetPlatform]
  /// is [TargetPlatform.iOS] and [kIsWeb] is `false`.
  static Future<bool> isIOSSimulator() => _platform.isIOSSimulator();

  /// Checks if the specified [feature] is supported in the current implementation.
  ///
  /// Will verify if this is supported in the platform itself:
  ///
  /// - If [feature] is supported on **Android API 21** (as an example) and the
  /// current Android API is `19` then will return `false`
  /// - If [feature] is supported on the web if Clipboard API (as another example)
  /// available in the current browser, and the current browser doesn't support it,
  /// will return `false` too. For this specific example, you will need
  /// to fallback to **Clipboard events** on **Firefox** or browsers that doesn't
  /// support **Clipboard API**.
  ///
  /// Always check the docs of the method you're calling to see if there
  /// are special notes.
  static Future<bool> isSupported(QuillNativeBridgeFeature feature) =>
      _platform.isSupported(feature);

  /// Return HTML from the Clipboard.
  ///
  /// **Important for web**: If [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
  /// is not supported on the web browser, should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// such as the [paste_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event).
  ///
  /// The HTML can be platform-dependent.
  ///
  /// Returns `null` if the HTML content is not available or if the user has not granted
  /// permission for pasting (on some platforms such as iOS).
  ///
  /// Currently only supports **Android**, **iOS**, **macOS**, **Windows**, **Linux**, and the **Web**.
  static Future<String?> getClipboardHtml() => _platform.getClipboardHtml();

  /// Copy the [html] to the clipboard to be pasted on other apps.
  ///
  /// **Important for web**: If [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
  /// is not supported on the web browser, should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// such as the [copy_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/copy_event).
  ///
  /// Currently only supports **Android**, **iOS**, **macOS**, **Linux**, **Windows** and the **Web**.
  static Future<void> copyHtmlToClipboard(String html) =>
      _platform.copyHtmlToClipboard(html);

  /// Copy the [imageBytes] to Clipboard to be pasted on other apps.
  ///
  /// Require modifying `AndroidManifest.xml` to work on **Android**.
  /// Otherwise, you will get a warning available only on debug-builds.
  /// See: https://github.com/singerdmx/flutter-quill#-platform-specific-configurations
  ///
  /// **Important for web**: If [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
  /// is not supported on the web browser, should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// such as the [copy_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/copy_event).
  ///
  ///
  /// Currently only supports **Android**, **iOS**, **macOS**, **Linux**, and the **Web**.
  static Future<void> copyImageToClipboard(Uint8List imageBytes) =>
      _platform.copyImageToClipboard(imageBytes);

  /// Return the copied image from the Clipboard.
  ///
  /// **Important for web**: If [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
  /// is not supported on the web browser, should fallback to [Clipboard Events](https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent)
  /// such as the [paste_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event).
  ///
  /// Currently only supports **Android**, **iOS**, **macOS**, **Linux**, and the **Web**.
  static Future<Uint8List?> getClipboardImage() =>
      _platform.getClipboardImage();

  /// Return the copied gif from the Clipboard.
  ///
  /// Currently only supports **Android**, **iOS**.
  static Future<Uint8List?> getClipboardGif() => _platform.getClipboardGif();

  /// Return the file paths from the Clipboard.
  ///
  /// Currently only supports **macOS** and **Linux**.
  static Future<List<String>> getClipboardFiles() =>
      _platform.getClipboardFiles();
}

library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, Uint8List, defaultTargetPlatform, kIsWeb;

import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

// TODO: Might move platform feature check outside of quill_native_bridge_platform_interface
//  to allow the implementation of QuillNativeBridgePlatform to have a different check.
export 'package:quill_native_bridge_platform_interface/src/platform_feature.dart';

/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
///
/// See [QuillNativeBridgePlatformFeature] to check whatever if a feature is supported.
class QuillNativeBridge {
  QuillNativeBridge._();

  static QuillNativeBridgePlatform get _platform =>
      QuillNativeBridgePlatform.instance;

  /// Check if the app is running on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  ///
  /// Should only be called when [defaultTargetPlatform]
  /// is [TargetPlatform.iOS] and [kIsWeb] is `false`.
  static Future<bool> isIOSSimulator() => _platform.isIOSSimulator();

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
  /// Currently only supports **Android**, **iOS**, **macOS**, **Linux**, and the **Web**.
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
}

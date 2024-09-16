library;

import 'package:flutter/foundation.dart' show TargetPlatform, Uint8List;

import 'src/quill_native_bridge_platform_interface.dart';

/// An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill)
/// package to access platform-specific APIs.
class QuillNativeBridge {
  QuillNativeBridge._();

  /// Check if the app is running on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  ///
  /// This function should only be called when [defaultTargetPlatform]
  /// is [TargetPlatform.iOS] and [kIsWeb] is `false`.
  static Future<bool> isIOSSimulator() =>
      QuillNativeBridgePlatform.instance.isIOSSimulator();

  /// Experimental and might removed in future releases.
  ///
  /// For now we do plan on removing this property once all non-web platforms
  /// are supported.
  ///
  /// Available to avoid hardcoding.
  static const Set<TargetPlatform> supportedClipboardPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS
  };

  /// Return HTML from the Clipboard for **non-web platforms**.
  ///
  /// Doesn't support web, should use
  /// [paste_event](https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event)
  /// instead.
  ///
  /// The HTML can be platform-dependent.
  ///
  /// Returns `null` if the HTML content is not available or if the user has not granted
  /// permission for pasting (on some platforms such as iOS).
  ///
  /// Currently only supports **Android**, **iOS** and **macOS**.
  static Future<String?> getClipboardHTML() =>
      QuillNativeBridgePlatform.instance.getClipboardHTML();

  /// Copy the [imageBytes] to Clipboard to be pasted on other apps for **non-web platforms**.
  ///
  /// Require modifying `AndroidManifest.xml` to work on **Android**.
  /// Otherwise, you will get a warning available only on debug-builds.
  /// See: https://github.com/singerdmx/flutter-quill#-platform-specific-configurations
  ///
  ///
  /// Currently only supports **Android**, **iOS** and **macOS**.
  static Future<void> copyImageToClipboard(Uint8List imageBytes) =>
      QuillNativeBridgePlatform.instance.copyImageToClipboard(imageBytes);
}

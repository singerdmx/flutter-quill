library;

import 'package:flutter/foundation.dart';

import 'src/quill_native_bridge_platform_interface.dart';

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
  static const Set<TargetPlatform> supportedHtmlClipboardPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS
  };

  /// Return the clipboard content as HTML for **non-web platforms**.
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
}

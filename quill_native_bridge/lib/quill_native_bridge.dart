library;

import 'src/quill_native_bridge_platform_interface.dart';

class QuillNativeBridge {
  QuillNativeBridge._();

  /// Check if the app is running on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  ///
  /// This function should only be called when [defaultTargetPlatform]
  /// is [TargetPlatform.iOS] and [kIsWeb] is `false`.
  static Future<bool> isIOSSimulator() =>
      QuillNativeBridgePlatform.instance.isIOSSimulator();

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
  /// Currently only supports **Android** and **iOS**.
  static Future<String?> getClipboardHTML() =>
      QuillNativeBridgePlatform.instance.getClipboardHTML();
}

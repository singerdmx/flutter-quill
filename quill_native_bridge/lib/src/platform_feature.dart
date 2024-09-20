import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// The features/methods provided by the plugin
enum QuillNativeBridgePlatformFeature {
  isIOSSimulator(hasWebSupport: false),
  getClipboardHTML(hasWebSupport: true),
  copyImageToClipboard(hasWebSupport: true),
  getClipboardImage(hasWebSupport: true),
  getClipboardGif(hasWebSupport: false);

  const QuillNativeBridgePlatformFeature({required this.hasWebSupport});

  /// Verify if this feature is supported on web regardless of the [TargetPlatform].
  ///
  /// **Note**: This doesn't check whatever if the web browser support this
  /// specific feature.
  ///
  /// For example the **Clipboard API** is not supported on **Firefox**
  /// but is supported on the web itself in general, the [hasWebSupport]
  /// will return `true`.
  ///
  /// Always check the docs of the method you're calling to see if there
  /// are special notes. For this specific example, you will need
  /// to fallback to **Clipboard events** on **Firefox** or browsers that doesn't
  /// support **Clipboard API**.
  final bool hasWebSupport;

  // Note: the [hasWebSupport] need to be manually updated to be in sync with
  // [isSupported]

  /// Verify whether a specific feature is supported by the plugin for the [TargetPlatform].
  ///
  /// **Note**: This doesn't check if the platform operating system does support
  /// this feature. It only check if this feature is supported
  /// on a specific platform (e.g. **Android** or **iOS**).
  ///
  /// If feature A is not supported on **Android API 21** (for example),
  /// then the [isSupported] doesn't cover this case.
  ///
  /// Always check the docs of the method you're calling to see if there
  /// are special notes.
  bool get isSupported {
    return switch (this) {
      QuillNativeBridgePlatformFeature.isIOSSimulator =>
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
      QuillNativeBridgePlatformFeature.getClipboardHTML => kIsWeb ||
          {TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS}
              .contains(defaultTargetPlatform),
      QuillNativeBridgePlatformFeature.copyImageToClipboard => kIsWeb ||
          {TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS}
              .contains(defaultTargetPlatform),
      QuillNativeBridgePlatformFeature.getClipboardImage => kIsWeb ||
          {TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS}
              .contains(defaultTargetPlatform),
      QuillNativeBridgePlatformFeature.getClipboardGif => !kIsWeb &&
          {TargetPlatform.android, TargetPlatform.iOS}
              .contains(defaultTargetPlatform),
    };
  }

  /// Negation of [isSupported]
  bool get isUnsupported => !isSupported;
}

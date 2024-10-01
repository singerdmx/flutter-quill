/// The platform features provided by the plugin
enum QuillNativeBridgeFeature {
  isIOSSimulator,
  getClipboardHtml,
  copyHtmlToClipboard,
  copyImageToClipboard,
  getClipboardImage,
  getClipboardGif,
  getClipboardFiles;

  const QuillNativeBridgeFeature();

  // TODO: Remove those comments later

  // /// Verify if this feature is supported on web regardless of the [TargetPlatform].
  // ///
  // /// **Note**: This doesn't check whatever if the web browser support this
  // /// specific feature.
  // ///
  // /// For example the **Clipboard API** might not be supported on **Firefox**
  // /// but is supported on the web itself in general, the [hasWebSupport]
  // /// will return `true`.
  // ///
  // /// Always check the docs of the method you're calling to see if there
  // /// are special notes. For this specific example, you will need
  // /// to fallback to **Clipboard events** on **Firefox** or browsers that doesn't
  // /// support **Clipboard API**.
  // final bool hasWebSupport;

  // /// Verify whether a specific feature is supported by the plugin for the [TargetPlatform].
  // ///
  // /// **Note**: This doesn't check if the platform operating system does support
  // /// this feature. It only check if this feature is supported
  // /// on a specific platform (e.g. **Android** or **iOS**).
  // ///
  // /// If feature A is not supported on **Android API 21** (for example),
  // /// then the [isSupported] doesn't cover this case.
  // ///
  // /// Always check the docs of the method you're calling to see if there
  // /// are special notes.
  // bool get isSupported {
  //   if (kIsWeb) {
  //     return hasWebSupport;
  //   }
  //   return switch (this) {
  //     QuillNativeBridgeFeature.isIOSSimulator =>
  //       !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
  //     QuillNativeBridgeFeature.getClipboardHtml => {
  //         TargetPlatform.android,
  //         TargetPlatform.iOS,
  //         TargetPlatform.macOS,
  //         TargetPlatform.windows,
  //         TargetPlatform.linux,
  //       }.contains(defaultTargetPlatform),
  //     QuillNativeBridgeFeature.copyHtmlToClipboard => {
  //         TargetPlatform.android,
  //         TargetPlatform.iOS,
  //         TargetPlatform.macOS,
  //         TargetPlatform.linux,
  //       }.contains(defaultTargetPlatform),
  //     QuillNativeBridgeFeature.copyImageToClipboard => {
  //         TargetPlatform.android,
  //         TargetPlatform.iOS,
  //         TargetPlatform.macOS,
  //         TargetPlatform.linux,
  //       }.contains(defaultTargetPlatform),
  //     QuillNativeBridgeFeature.getClipboardImage => {
  //         TargetPlatform.android,
  //         TargetPlatform.iOS,
  //         TargetPlatform.macOS,
  //         TargetPlatform.linux,
  //       }.contains(defaultTargetPlatform),
  //     QuillNativeBridgeFeature.getClipboardGif => {
  //         TargetPlatform.android,
  //         TargetPlatform.iOS
  //       }.contains(defaultTargetPlatform),
  //   };
  // }

  // /// Negation of [isSupported]
  // bool get isUnsupported => !isSupported;
}

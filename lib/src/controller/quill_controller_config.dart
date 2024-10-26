import 'package:meta/meta.dart';

class QuillControllerConfig {
  const QuillControllerConfig({
    @experimental this.onClipboardPaste,
    this.requireScriptFontFeatures = false,
  });

  /// Callback to allow overriding the default clipboard paste handling.
  ///
  /// A minimal example of removing the plain text if it exists in the
  /// system clipboard, otherwise fallback to the default handling:
  ///
  /// ```dart
  /// onClipboardPaste: () async {
  ///   final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  ///   if (clipboardData != null) {
  ///     await Clipboard.setData(const ClipboardData(text: ''));
  ///     // The paste operation was handled
  ///     return true;
  ///   }
  ///   // Fallback to the default handling
  ///   return false;
  /// }
  /// ```
  ///
  /// An example of disabling the clipboard paste:
  ///
  /// ```dart
  /// onClipboardPaste: () async {
  ///   return true;
  /// }
  /// ```
  ///
  /// Return `true` if the paste operation was handled or `false` to
  /// fallback to the default clipboard paste handling.
  @experimental
  final Future<bool> Function()? onClipboardPaste;

  /// Render subscript and superscript text using Open Type FontFeatures
  ///
  /// Default is false to use built-in script rendering that is independent of font capabilities
  final bool requireScriptFontFeatures;
}

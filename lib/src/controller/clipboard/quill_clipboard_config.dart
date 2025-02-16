import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../quill_delta.dart';

@immutable
@experimental
class QuillClipboardConfig {
  const QuillClipboardConfig({
    @experimental this.onClipboardPaste,
    @experimental this.onUnprocessedPaste,
    this.onImagePaste,
    @experimental this.onGifPaste,
    @experimental this.onRichTextPaste,
    @experimental this.onPlainTextPaste,
    @experimental this.enableExternalRichPaste,
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

  /// Callback when the user pastes and data has not already been processed.
  ///
  /// Return `true` if the paste operation was handled.
  @experimental
  final Future<bool> Function()? onUnprocessedPaste;

  /// Callback when the user pastes the given image.
  ///
  /// Returns the URL of the image if the image should be inserted.
  final Future<String?> Function(Uint8List imageBytes)? onImagePaste;

  /// Callback when the user pastes the given GIF.
  ///
  /// Supports **Android** and **iOS** only.
  ///
  /// Returns the URL of the image if the GIF image should be inserted.
  @experimental
  final Future<String?> Function(Uint8List imageBytes)? onGifPaste;

  /// Callback triggered when pasting a [Delta] to the editor.
  ///
  /// Returns a modified [Delta] to override the pasted content, or `null` to use the default.
  ///
  /// The [isExternal] determines whether the `Delta` content is coming from
  /// external apps.
  ///
  /// Currently this callback is only called when pasting content from the
  /// system clipboard but that's subject to change, see [#2474](https://github.com/singerdmx/flutter-quill/issues/2474).
  @experimental
  final Future<Delta?> Function(Delta delta, bool isExternal)? onRichTextPaste;

  /// Callback triggered when pasting plain text into the editor.
  ///
  /// Return modified text to override the pasted content, or `null` to use the default.
  @experimental
  final Future<String?> Function(String plainText)? onPlainTextPaste;

  /// Determines if rich text pasting from external sources (system clipboard) is enabled.
  ///
  /// When enabled, rich text content from other apps can be pasted into the editor,
  /// using platform APIs to access the system clipboard.
  ///
  /// Will convert the **HTML** (from the system clipboard) to [Delta]
  /// and then paste it, use [onDeltaPaste] to customize the [Delta]
  /// before pasting it.
  ///
  /// Defaults to `true`.
  ///
  /// See also: https://pub.dev/packages/flutter_quill#-rich-text-paste
  @experimental
  final bool? enableExternalRichPaste;
}

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/services.dart' show Clipboard;
import 'package:meta/meta.dart' show experimental;

/// A more rich abstraction of Flutter [Clipboard] to support images, rich text
/// and more clipboard operations.
@experimental
abstract class ClipboardService {
  /// Return HTML from the Clipboard.
  Future<String?> getHtmlText();

  /// Return HTML text file from the Clipboard.
  Future<String?> getHtmlFile();

  /// Return the Markdown file in the Clipboard.
  Future<String?> getMarkdownFile();

  /// Return image from the Clipboard.
  Future<Uint8List?> getImageFile();

  /// Return Gif from the Clipboard.
  Future<Uint8List?> getGifFile();

  /// Copy an image to the system clipboard to paste it on other apps.
  Future<void> copyImage(Uint8List imageBytes);

  /// If the Clipboard is not empty or has something to paste
  Future<bool> get hasClipboardContent async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData != null;
  }
}

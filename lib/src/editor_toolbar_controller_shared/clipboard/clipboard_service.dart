import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/services.dart' show Clipboard;

/// An abstraction to make it easy to provide different implementations
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

  /// Copy [imageBytes] to the system clipboard to paste on other apps.
  Future<void> copyImageToClipboard(Uint8List imageBytes);

  /// If the Clipboard is not empty or has something to paste
  Future<bool> get hasClipboardContent async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData != null;
  }
}

import 'package:flutter/foundation.dart';

/// An abstraction to make it easy to provide different implementations
@immutable
abstract class ClipboardService {
  Future<bool> canProvideHtmlText();

  /// Get Clipboard content as Html Text, this is platform specific and not the
  /// same as [getPlainText] for two reasons:
  /// 1. The user might want to paste Html text
  /// 2. Copying Html text from other apps and use [getPlainText] will ignore
  /// the Html content and provide it as text
  Future<String?> getHtmlText();

  Future<bool> canProvideHtmlTextFromFile();

  /// Get the Html file in the Clipboard from the system
  Future<String?> getHtmlTextFromFile();

  Future<bool> canProvideMarkdownText();

  /// Get Clipboard content as Markdown Text, this is platform specific and not the
  /// same as [getPlainText] for two reasons:
  /// 1. The user might want to paste Markdown text
  /// 2. Copying Markdown text from other apps and use [getPlainText] will ignore
  /// the Markdown content and provide it as text
  Future<String?> getMarkdownText();

  Future<bool> canProvideMarkdownTextFromFile();

  /// Get the Markdown file in the Clipboard from the system
  Future<String?> getMarkdownTextFromFile();

  Future<bool> canProvidePlainText();
  Future<String?> getPlainText();

  Future<bool> canProvideImageFile();
  Future<Uint8List> getImageFileAsBytes();

  Future<bool> canProvideGifFile();
  Future<Uint8List> getGifFileAsBytes();

  Future<bool> canPaste();
}

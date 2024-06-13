import 'package:flutter/services.dart' show Clipboard, Uint8List;

import 'clipboard_service.dart';

/// Default implementation using only internal flutter plugins
class DefaultClipboardService implements ClipboardService {
  @override
  Future<bool> canProvideHtmlText() async {
    return false;
  }

  @override
  Future<String?> getHtmlText() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving HTML text.',
    );
  }

  @override
  Future<bool> canProvideHtmlTextFromFile() async {
    return false;
  }

  @override
  Future<String?> getHtmlTextFromFile() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving HTML files.',
    );
  }

  @override
  Future<bool> canProvideMarkdownText() async {
    return false;
  }

  @override
  Future<String?> getMarkdownText() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving HTML files.',
    );
  }

  @override
  Future<bool> canProvideMarkdownTextFromFile() async {
    return false;
  }

  @override
  Future<String?> getMarkdownTextFromFile() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving Markdown text.',
    );
  }

  @override
  Future<bool> canProvidePlainText() async {
    final plainText = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    return plainText == null;
  }

  @override
  Future<String?> getPlainText() async {
    final plainText = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    return plainText;
  }

  @override
  Future<bool> canProvideImageFile() async {
    return false;
  }

  @override
  Future<Uint8List> getImageFileAsBytes() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving image files.',
    );
  }

  @override
  Future<bool> canProvideGifFile() async {
    return false;
  }

  @override
  Future<Uint8List> getGifFileAsBytes() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving GIF files.',
    );
  }

  @override
  Future<bool> canPaste() async {
    final plainText = await getPlainText();
    return plainText != null;
  }
}

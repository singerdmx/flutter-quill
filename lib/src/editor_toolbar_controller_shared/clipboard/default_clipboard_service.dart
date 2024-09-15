import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart' show Clipboard, Uint8List;
import 'package:quill_native_bridge/quill_native_bridge.dart'
    show QuillNativeBridge;

import 'clipboard_service.dart';

/// Default implementation
class DefaultClipboardService implements ClipboardService {
  @override
  Future<bool> canProvideHtmlText() async =>
      QuillNativeBridge.supportedHtmlClipboardPlatforms
          .contains(defaultTargetPlatform);

  @override
  Future<String?> getHtmlText() => QuillNativeBridge.getClipboardHTML();

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

import 'package:flutter/services.dart' show Clipboard, Uint8List;

import 'clipboard_service.dart';

/// Default implementation using only internal flutter plugins
class DefaultClipboardService implements ClipboardService {
  @override
  Future<bool> canProvideGifFile() async {
    return false;
  }

  @override
  Future<bool> canProvideHtmlText() async {
    return false;
  }

  @override
  Future<bool> canProvideImageFile() async {
    return false;
  }

  @override
  Future<bool> canProvidePlainText() async {
    final plainText = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    return plainText == null;
  }

  @override
  Future<Uint8List> getGifFileAsBytes() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving GIF files.',
    );
  }

  @override
  Future<String?> getHtmlText() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving HTML text.',
    );
  }

  @override
  Future<Uint8List> getImageFileAsBytes() {
    throw UnsupportedError(
      'DefaultClipboardService does not support retrieving image files.',
    );
  }

  @override
  Future<String?> getPlainText() async {
    final plainText = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    return plainText;
  }

  @override
  Future<bool> canPaste() async {
    final plainText = await getPlainText();
    return plainText != null;
  }
}

import 'package:flutter/services.dart' show Uint8List;
import 'package:meta/meta.dart' show experimental;
import 'package:quill_native_bridge/quill_native_bridge.dart'
    show QuillNativeBridge, QuillNativeBridgeFeature;

import 'clipboard_service.dart';

/// Default implementation of [ClipboardService] to support rich clipboard
/// operations.
@experimental
class DefaultClipboardService extends ClipboardService {
  @override
  Future<String?> getHtmlText() async {
    if (!(await QuillNativeBridge.isSupported(
        QuillNativeBridgeFeature.getClipboardHtml))) {
      return null;
    }
    return await QuillNativeBridge.getClipboardHtml();
  }

  @override
  Future<Uint8List?> getImageFile() async {
    if (!(await QuillNativeBridge.isSupported(
        QuillNativeBridgeFeature.getClipboardImage))) {
      return null;
    }
    return await QuillNativeBridge.getClipboardImage();
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    if (!(await QuillNativeBridge.isSupported(
        QuillNativeBridgeFeature.copyImageToClipboard))) {
      return;
    }
    await QuillNativeBridge.copyImageToClipboard(imageBytes);
  }

  @override
  Future<Uint8List?> getGifFile() async {
    if (!(await QuillNativeBridge.isSupported(
        QuillNativeBridgeFeature.getClipboardGif))) {
      return null;
    }
    return QuillNativeBridge.getClipboardGif();
  }

  @override
  Future<String?> getHtmlFile() async {
    return null;
  }

  @override
  Future<String?> getMarkdownFile() async {
    return null;
  }
}

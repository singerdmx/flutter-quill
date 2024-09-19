import 'package:flutter/services.dart' show Uint8List;
import 'package:quill_native_bridge/quill_native_bridge.dart'
    show QuillNativeBridge, QuillNativeBridgePlatformFeature;

import 'clipboard_service.dart';

/// Default implementation
class DefaultClipboardService extends ClipboardService {
  @override
  Future<String?> getHtmlText() async {
    if (QuillNativeBridgePlatformFeature.getClipboardHTML.isUnsupported) {
      return null;
    }
    return await QuillNativeBridge.getClipboardHTML();
  }

  @override
  Future<Uint8List?> getImageFile() async {
    if (QuillNativeBridgePlatformFeature.getClipboardImage.isUnsupported) {
      return null;
    }
    return await QuillNativeBridge.getClipboardImage();
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    if (QuillNativeBridgePlatformFeature.copyImageToClipboard.isUnsupported) {
      return;
    }
    await QuillNativeBridge.copyImageToClipboard(imageBytes);
  }

  @override
  Future<Uint8List?> getGifFile() async {
    if (QuillNativeBridgePlatformFeature.getClipboardGif.isUnsupported) {
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

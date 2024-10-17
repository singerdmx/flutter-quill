import 'dart:io' as io;

import 'package:flutter/foundation.dart';
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
  Future<void> copyImage(Uint8List imageBytes) async {
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

  Future<String?> _getClipboardFile({required String fileExtension}) async {
    if (!(await QuillNativeBridge.isSupported(
        QuillNativeBridgeFeature.getClipboardFiles))) {
      return null;
    }
    if (kIsWeb) {
      // TODO: Can't read file with dart:io on the Web (See related https://github.com/FlutterQuill/quill-native-bridge/issues/6)
      return null;
    }
    final filePaths = await QuillNativeBridge.getClipboardFiles();
    final filePath = filePaths.firstWhere(
      (filePath) => filePath.endsWith('.$fileExtension'),
      orElse: () => '',
    );
    if (filePath.isEmpty) {
      // Could not find an item
      return null;
    }
    final fileText = await io.File(filePath).readAsString();
    return fileText;
  }

  @override
  Future<String?> getHtmlFile() async {
    final htmlFileText = await _getClipboardFile(fileExtension: 'html');
    return htmlFileText;
  }

  @override
  Future<String?> getMarkdownFile() async {
    final htmlFileText = await _getClipboardFile(fileExtension: 'md');
    return htmlFileText;
  }
}

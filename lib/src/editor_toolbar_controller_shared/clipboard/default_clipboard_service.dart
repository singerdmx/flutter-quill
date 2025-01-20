import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart' show experimental;

import '../../common/utils/quill_native_provider.dart';
import 'clipboard_service.dart';

/// Default implementation of [ClipboardService] to support rich clipboard
/// operations.
@experimental
class DefaultClipboardService extends ClipboardService {
  @override
  Future<String?> getHtmlText() async {
    if (!(await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.getClipboardHtml))) {
      return null;
    }
    return await QuillNativeProvider.instance.getClipboardHtml();
  }

  @override
  Future<Uint8List?> getImageFile() async {
    if (!(await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.getClipboardImage))) {
      return null;
    }
    return await QuillNativeProvider.instance.getClipboardImage();
  }

  @override
  Future<void> copyImage(Uint8List imageBytes) async {
    if (!(await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.copyImageToClipboard))) {
      return;
    }
    await QuillNativeProvider.instance.copyImageToClipboard(imageBytes);
  }

  @override
  Future<Uint8List?> getGifFile() async {
    if (!(await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.getClipboardGif))) {
      return null;
    }
    return QuillNativeProvider.instance.getClipboardGif();
  }

  Future<String?> _getClipboardFile({required String fileExtension}) async {
    if (!(await QuillNativeProvider.instance
        .isSupported(QuillNativeBridgeFeature.getClipboardFiles))) {
      return null;
    }
    if (kIsWeb) {
      // TODO: Can't read file with dart:io on the Web (See related https://github.com/FlutterQuill/quill-native-bridge/issues/6)
      return null;
    }
    final filePaths = await QuillNativeProvider.instance.getClipboardFiles();
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

// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:win32/win32.dart';

import 'src/clipboard_html_format.dart';
import 'src/html_cleaner.dart';

/// A Windows implementation of the [QuillNativeBridgePlatform].
///
/// **Highly Experimental** and can be removed.
///
/// Should extends [QuillNativeBridgePlatform] and not implements it as error will arise:
///
/// ```console
/// Assertion failed: "Platform interfaces must not be implemented with `implements`"
/// ```
///
/// See [Flutter #127396](https://github.com/flutter/flutter/issues/127396)
/// and [QuillNativeBridgePlatform] for more details.
/// ```
class QuillNativeBridgeWindows extends QuillNativeBridgePlatform {
  QuillNativeBridgeWindows._();

  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeWindows._();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        return false;
      case QuillNativeBridgeFeature.getClipboardHtml:
        return true;
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
      case QuillNativeBridgeFeature.copyImageToClipboard:
      case QuillNativeBridgeFeature.getClipboardImage:
      case QuillNativeBridgeFeature.getClipboardGif:
        return false;
      // Without this default check, adding new item to the enum will be a breaking change
      default:
        throw UnimplementedError(
          'Checking if `${feature.name}` is supported on Windows is not covered.',
        );
    }
  }

  // TODO: Cleanup this code here

  // TODO: Improve error handling by throwing exception
  //  instead of using assert, should have a proper way of handling
  //  errors regardless of this implementation.

  // TODO: Test Clipboard operations with other windows apps and
  //  see if this implementation causing issues

  @override
  Future<String?> getClipboardHtml() async {
    if (OpenClipboard(NULL) == FALSE) {
      assert(false, 'Unknown error while opening the clipboard.');
      return null;
    }

    try {
      final htmlFormatId = cfHtml;

      if (htmlFormatId == null) {
        assert(false, 'Failed to register clipboard HTML format.');
        return null;
      }

      if (IsClipboardFormatAvailable(htmlFormatId) == FALSE) {
        return null;
      }

      final clipboardDataHandle = GetClipboardData(htmlFormatId);
      if (clipboardDataHandle == NULL) {
        assert(false, 'Failed to get clipboard data.');
        return null;
      }

      final clipboardDataPointer = Pointer.fromAddress(clipboardDataHandle);
      final lockedMemoryPointer = GlobalLock(clipboardDataPointer);
      if (lockedMemoryPointer == nullptr) {
        assert(
          false,
          'Failed to lock global memory. Error code: ${GetLastError()}',
        );
        return null;
      }

      final windowsHtmlWithMetadata =
          lockedMemoryPointer.cast<Utf8>().toDartString();
      GlobalUnlock(clipboardDataPointer);

      // Strip comments at the start of the HTML as they can cause
      // issues while parsing the HTML

      final cleanedHtml = stripWin32HtmlDescription(windowsHtmlWithMetadata);

      return cleanedHtml;
    } finally {
      CloseClipboard();
    }
  }
}

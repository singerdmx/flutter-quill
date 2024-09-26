// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:win32/win32.dart';

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

  // TODO: Cleanup this code here

  // TODO: Improve error handling by throwing exception
  //  instead of using assert, should have a proper way of handling
  //  errors regardless of this implementation.

  // TODO: Throw exception and always close the clipboard at once
  //  regardless of the result

  // TODO: Test Clipboard operations with other windows apps and
  //  see if this implementation causing issues

  /// From [HTML Clipboard Format](https://docs.microsoft.com/en-us/windows/win32/dataxchg/html-clipboard-format).
  static const _kHtmlFormatName = 'HTML Format';

  @override
  Future<String?> getClipboardHTML() async {
    if (OpenClipboard(NULL) == FALSE) {
      assert(false, 'Unknown error while opening the clipboard.');
      return null;
    }

    final htmlFormatPointer = _kHtmlFormatName.toNativeUtf16();
    final htmlFormatId = RegisterClipboardFormat(htmlFormatPointer);
    calloc.free(htmlFormatPointer);

    if (htmlFormatId == 0) {
      CloseClipboard();
      assert(false, 'Failed to register clipboard HTML format.');
      return null;
    }

    if (IsClipboardFormatAvailable(htmlFormatId) == FALSE) {
      CloseClipboard();
      return null;
    }

    final clipboardDataHandle = GetClipboardData(htmlFormatId);
    if (clipboardDataHandle == NULL) {
      CloseClipboard();
      assert(false, 'Failed to get clipboard data.');
      return null;
    }

    final clipboardDataPointer = Pointer.fromAddress(clipboardDataHandle);
    final lockedMemoryPointer = GlobalLock(clipboardDataPointer);
    if (lockedMemoryPointer == nullptr) {
      CloseClipboard();
      assert(
        false,
        'Failed to lock global memory. Error code: ${GetLastError()}',
      );
      return null;
    }

    final windowsHtmlWithMetadata =
        lockedMemoryPointer.cast<Utf8>().toDartString();
    GlobalUnlock(clipboardDataPointer);
    CloseClipboard();

    // Strip comments at the start of the HTML as they can cause
    // issues while parsing the HTML

    final cleanedHtml = stripWin32HtmlDescription(windowsHtmlWithMetadata);

    return cleanedHtml;
  }
}
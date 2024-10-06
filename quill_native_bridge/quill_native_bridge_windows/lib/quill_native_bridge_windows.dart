// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';
import 'package:win32/win32.dart';

import 'src/clipboard_html_format.dart';
import 'src/html_cleaner.dart';
import 'src/html_formatter.dart';

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
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => {
        QuillNativeBridgeFeature.getClipboardHtml,
        QuillNativeBridgeFeature.copyHtmlToClipboard,
      }.contains(feature);

  // TODO: Cleanup this code here

  // TODO: Improve error handling by throwing exception
  //  instead of using assert, should have a proper way of handling
  //  errors regardless of this implementation.

  // TODO: Test Clipboard operations with other windows apps and
  //  see if this implementation causing issues

  // TODO: Might extract low-level implementation of the clipboard outside of this class

  /// Refer to [Windows GetClipboardData() docs](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclipboarddata)
  @override
  Future<String?> getClipboardHtml() async {
    if (OpenClipboard(NULL) == FALSE) {
      assert(
        false,
        'Unknown error while opening the clipboard. Error code: ${GetLastError()}',
      );
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
        assert(
          false,
          'Failed to get clipboard data. Error code: ${GetLastError()}',
        );
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

      // Strip comments/headers at the start of the HTML as they can cause
      // issues while parsing the HTML

      final cleanedHtml =
          stripWindowsHtmlDescriptionHeaders(windowsHtmlWithMetadata);

      return cleanedHtml;
    } finally {
      CloseClipboard();
    }
  }

  /// Refer to [Windows SetClipboardData() docs](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclipboarddata)
  @override
  Future<void> copyHtmlToClipboard(String html) async {
    if (OpenClipboard(NULL) == FALSE) {
      assert(
        false,
        'Unknown error while opening the clipboard. Error code: ${GetLastError()}',
      );
      return;
    }

    final windowsClipboardHtml = constructWindowsHtmlDescriptionHeaders(html);
    final htmlPointer = windowsClipboardHtml.toNativeUtf8();

    try {
      if (EmptyClipboard() == FALSE) {
        assert(
          false,
          'Failed to empty the clipboard. Error code: ${GetLastError()}',
        );
        return;
      }

      final htmlFormatId = cfHtml;

      if (htmlFormatId == null) {
        assert(
          false,
          'Failed to register clipboard HTML format. Error code: ${GetLastError()}',
        );
        return;
      }

      final unitSize = sizeOf<Uint8>();
      final htmlSize = (htmlPointer.length + 1) * unitSize;

      final clipboardMemoryHandle =
          GlobalAlloc(GLOBAL_ALLOC_FLAGS.GMEM_MOVEABLE, htmlSize);
      if (clipboardMemoryHandle == nullptr) {
        assert(
          false,
          'Failed to allocate memory for the clipboard content. Error code: ${GetLastError()}',
        );
        return;
      }

      final lockedMemoryPointer = GlobalLock(clipboardMemoryHandle);
      if (lockedMemoryPointer == nullptr) {
        GlobalFree(clipboardMemoryHandle);
        assert(
          false,
          'Failed to lock global memory. Error code: ${GetLastError()}',
        );
        return;
      }

      final targetMemoryPointer = lockedMemoryPointer.cast<Uint8>();

      final sourcePointer = htmlPointer.cast<Uint8>();

      // Copy HTML data byte by byte
      for (var i = 0; i < htmlPointer.length; i++) {
        targetMemoryPointer[i] = (sourcePointer + i).value;
      }

      // Add a null terminator for HTML (necessary for proper string handling)
      (targetMemoryPointer + htmlPointer.length).value = NULL;

      // According to Windows docs in https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclipboarddata#parameters
      // Should not call GlobalFree() when SetClipboardData() success
      // as the Windows clipboard takes ownership of the memory.

      GlobalUnlock(clipboardMemoryHandle);

      if (SetClipboardData(htmlFormatId, clipboardMemoryHandle.address) ==
          NULL) {
        GlobalFree(clipboardMemoryHandle);
        assert(
          false,
          'Failed to set the clipboard data: ${GetLastError()}',
        );
      }
    } finally {
      CloseClipboard();
      calloc.free(htmlPointer);
    }
  }
}

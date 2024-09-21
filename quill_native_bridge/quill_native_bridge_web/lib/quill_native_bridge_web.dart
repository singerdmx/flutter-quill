// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:js_interop';

import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:web/web.dart';

import 'src/clipboard_api_support_unsafe.dart';

/// A web implementation of the [QuillNativeBridgePlatform].
///
/// **Highly Experimental** and can be removed.
///
/// Should extends [QuillNativeBridgePlatform] and not implements it as error will arise:
///
/// ```console
/// Assertion failed: "Platform interfaces must not be implemented with `implements`"
///
/// See https://github.com/flutter/flutter/issues/127396
/// ```
class QuillNativeBridgeWeb extends QuillNativeBridgePlatform {
  QuillNativeBridgeWeb._();

  static void registerWith(Registrar registrar) {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeWeb._();
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not copy image to the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    final blob = Blob(
      [imageBytes.toJS].toJS,
      BlobPropertyBag(type: 'image/png'),
    );

    final clipboardItem = ClipboardItem(
      {'image/png': blob}.jsify() as JSObject,
    );

    await window.navigator.clipboard.write([clipboardItem].toJS).toDart;
  }

  @override
  Future<String?> getClipboardHTML() async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not retrieve HTML from the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    const kMimeTextHtml = 'text/html';
    final clipboardItems =
        (await window.navigator.clipboard.read().toDart).toDart;
    for (final item in clipboardItems) {
      if (item.types.toDart.contains(kMimeTextHtml.toJS)) {
        final html = await item.getType(kMimeTextHtml).toDart;
        return (await html.text().toDart).toDart;
      }
    }
    return null;
  }

  @override
  Future<Uint8List?> getClipboardImage() async {
    if (isClipbaordApiUnsupported) {
      throw UnsupportedError(
        'Could not retrieve image from the clipboard.\n'
        'The Clipboard API is not supported on ${window.navigator.userAgent}.\n'
        'Should fallback to Clipboard events.',
      );
    }
    const kMimeImagePng = 'image/png';
    final clipboardItems =
        (await window.navigator.clipboard.read().toDart).toDart;
    for (final item in clipboardItems) {
      if (item.types.toDart.contains(kMimeImagePng.toJS)) {
        final blob = await item.getType(kMimeImagePng).toDart;
        final arrayBuffer = await blob.arrayBuffer().toDart;
        return arrayBuffer.toDart.asUint8List();
      }
    }
    return null;
  }

  @override
  Future<Uint8List?> getClipboardGif() {
    assert(() {
      debugPrint(
        'Retrieving gif image from the clipboard is unsupported regardless of the browser.\n'
        'Refer to https://github.com/singerdmx/flutter-quill/issues/2229 for discussion.',
      );
      return true;
    }());
    throw UnsupportedError(
      'Retrieving gif image from the clipboard is unsupported regardless of the browser.',
    );
  }
}

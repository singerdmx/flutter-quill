// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:js_interop';

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart';

import '../quill_native_bridge_platform_interface.dart';

/// A web implementation of the [QuillNativeBridgePlatform].
///
/// **Experimental** and can be removed.
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
    final blob = Blob(
      [imageBytes.toJS].jsify() as JSArray<Blob>,
      BlobPropertyBag(type: 'image/png'),
    );

    final clipboardItem = ClipboardItem(
      {'image/png': blob}.jsify() as JSObject,
    );

    // TODO: Will cause issue on Firefox as Clipboard API is not supported, fallback to Clipboard events.
    await window.navigator.clipboard
        .write([clipboardItem].jsify() as ClipboardItems)
        .toDart;
  }

  // TODO: This web implementation doesn't work on firefox.
  //  Related: https://github.com/singerdmx/flutter-quill/issues/2220

  // TODO: Need a method to check if Clipboard API is supported (which is not on Firefox)

  // @override
  // Future<String?> getClipboardHTML() async {
  //   final clipboardData =
  //       (await window.navigator.clipboard.read().toDart).toDart;
  //   for (final item in clipboardData) {
  //     if (item.types.toDart.contains('text/html'.toJS)) {
  //       final html = await item.getType('text/html').toDart;
  //       return (await html.text().toDart).toDart;
  //     }
  //   }
  //   return null;
  // }
}

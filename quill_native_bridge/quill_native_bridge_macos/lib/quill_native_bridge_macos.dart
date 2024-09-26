// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'package:flutter/foundation.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [QuillNativeBridgePlatform] for macOS.
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
class QuillNativeBridgeMacOS extends QuillNativeBridgePlatform {
  QuillNativeBridgeMacOS._({
    @visibleForTesting QuillNativeBridgeApi? api,
  }) : _hostApi = api ?? QuillNativeBridgeApi();

  final QuillNativeBridgeApi _hostApi;

  /// Registers this class as the default instance of [QuillNativeBridgePlatform].
  static void registerWith() {
    assert(
      defaultTargetPlatform == TargetPlatform.macOS && !kIsWeb,
      '$QuillNativeBridgeMacOS should be only used for macOS.',
    );
    QuillNativeBridgePlatform.instance = QuillNativeBridgeMacOS._();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        return false;
      case QuillNativeBridgeFeature.getClipboardHtml:
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
      case QuillNativeBridgeFeature.copyImageToClipboard:
      case QuillNativeBridgeFeature.getClipboardImage:
        return true;
      case QuillNativeBridgeFeature.getClipboardGif:
        return false;
      // Without this default check, adding new item to the enum will be a breaking change
      default:
        throw UnimplementedError(
          'Checking if `${feature.name}` is supported on macOS is not covered.',
        );
    }
  }

  @override
  Future<bool> isIOSSimulator() => throw UnsupportedError(
        'isIOSSimulator() is only supported on iOS.',
      );

  @override
  Future<String?> getClipboardHtml() => _hostApi.getClipboardHtml();

  @override
  Future<void> copyHtmlToClipboard(String html) =>
      _hostApi.copyHtmlToClipboard(html);

  @override
  Future<Uint8List?> getClipboardImage() => _hostApi.getClipboardImage();

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) =>
      _hostApi.copyImageToClipboard(imageBytes);

  @override
  Future<Uint8List?> getClipboardGif() => _hostApi.getClipboardGif();
}

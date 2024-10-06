// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

import 'src/messages.g.dart';

/// An implementation of [QuillNativeBridgePlatform] for Android.
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
class QuillNativeBridgeAndroid extends QuillNativeBridgePlatform {
  QuillNativeBridgeAndroid._({
    @visibleForTesting QuillNativeBridgeApi? api,
  }) : _hostApi = api ?? QuillNativeBridgeApi();

  final QuillNativeBridgeApi _hostApi;

  /// Registers this class as the default instance of [QuillNativeBridgePlatform].
  static void registerWith() {
    assert(
      defaultTargetPlatform == TargetPlatform.android && !kIsWeb,
      '$QuillNativeBridgeAndroid should be only used for Android.',
    );
    QuillNativeBridgePlatform.instance = QuillNativeBridgeAndroid._();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async => {
        QuillNativeBridgeFeature.getClipboardHtml,
        QuillNativeBridgeFeature.copyHtmlToClipboard,
        QuillNativeBridgeFeature.copyImageToClipboard,
        QuillNativeBridgeFeature.getClipboardImage,
        QuillNativeBridgeFeature.getClipboardGif,
      }.contains(feature);

  @override
  Future<String?> getClipboardHtml() async => _hostApi.getClipboardHtml();

  @override
  Future<void> copyHtmlToClipboard(String html) =>
      _hostApi.copyHtmlToClipboard(html);

  @override
  Future<Uint8List?> getClipboardImage() async {
    try {
      return await _hostApi.getClipboardImage();
    } on PlatformException catch (e) {
      if (kDebugMode &&
          (e.code == 'FILE_READ_PERMISSION_DENIED' ||
              e.code == 'FILE_NOT_FOUND')) {
        _printAndroidClipboardImageAccessKnownIssue(e);
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    try {
      await _hostApi.copyImageToClipboard(imageBytes);
    } on PlatformException catch (e) {
      // TODO: Update the link, issue and related info if this plugin
      //  moved outside of flutter-quill repo
      if (kDebugMode && e.code == 'ANDROID_MANIFEST_NOT_CONFIGURED') {
        debugPrint(
          'It looks like your AndroidManifest.xml is not configured properly '
          'to support copying images to the clipboard on Android.\n'
          "If you're interested in this feature, refer to https://github.com/singerdmx/flutter-quill#-platform-specific-configurations\n"
          'This message will only shown in debug mode.\n'
          'Platform details: ${e.toString()}',
        );
        throw AssertionError(
          'Optional AndroidManifest configuration is missing. '
          'Copying images to the clipboard on Android require modifying `AndroidManifest.xml`. '
          'A message was shown above this error for more details. This'
          'error will only arise in debug mode.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<Uint8List?> getClipboardGif() async {
    try {
      return await _hostApi.getClipboardGif();
    } on PlatformException catch (e) {
      if (kDebugMode &&
          (e.code == 'FILE_READ_PERMISSION_DENIED' ||
              e.code == 'FILE_NOT_FOUND')) {
        _printAndroidClipboardImageAccessKnownIssue(e);
        return null;
      }
      rethrow;
    }
  }

  /// Should be only used internally for [getClipboardGif] and [getClipboardImage]
  /// for **Android only**.
  ///
  /// This issue can be caused by `SecurityException` or `FileNotFoundException`
  /// from Android side.
  ///
  /// See [#2243](https://github.com/singerdmx/flutter-quill/issues/2243) for more details.
  void _printAndroidClipboardImageAccessKnownIssue(PlatformException e) {
    assert(
      defaultTargetPlatform == TargetPlatform.android,
      '_printAndroidClipboardImageAccessKnownIssue() should be only used for Android.',
    );
    assert(
      kDebugMode,
      '_printAndroidClipboardImageAccessKnownIssue() should be only called in debug mode',
    );
    if (kDebugMode) {
      debugPrint(
        'Could not retrieve the image from clipbaord as the app no longer have access to the image.\n'
        'This can happen on app restart or lifecycle changes.\n'
        'This is known issue on Android and this message will be only shown in debug mode.\n'
        'Refer to https://github.com/singerdmx/flutter-quill/issues/2243 for discussion.\n'
        'Platform details: ${e.toString()}',
      );
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;

import 'platform_feature.dart';
import 'quill_native_bridge_platform_interface.dart';

class MethodChannelQuillNativeBridge implements QuillNativeBridgePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('quill_native_bridge');

  @override
  Future<bool> isIOSSimulator() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.isIOSSimulator.isUnsupported) {
        throw FlutterError(
          'isIOSSimulator() method should be called only on iOS.',
        );
      }
      return true;
    }());
    final isSimulator =
        await methodChannel.invokeMethod<bool>('isIOSSimulator');
    assert(() {
      if (isSimulator == null) {
        throw FlutterError(
          'isSimulator should not be null.',
        );
      }
      return true;
    }());
    return isSimulator ?? false;
  }

  @override
  Future<String?> getClipboardHTML() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardHTML.isUnsupported) {
        throw FlutterError(
          'getClipboardHTML() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    final htmlText =
        await methodChannel.invokeMethod<String?>('getClipboardHTML');
    return htmlText;
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.copyImageToClipboard.isUnsupported) {
        throw FlutterError(
          'copyImageToClipboard() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    try {
      await methodChannel.invokeMethod<void>(
        'copyImageToClipboard',
        imageBytes,
      );
    } on PlatformException catch (e) {
      if ((kDebugMode && defaultTargetPlatform == TargetPlatform.android) &&
          e.code == 'ANDROID_MANIFEST_NOT_CONFIGURED') {
        debugPrint(
          'It looks like your AndroidManifest.xml is not configured properly '
          'to support copying images to the clipboard on Android.\n'
          "If you're interested in this feature, refer to https://github.com/singerdmx/flutter-quill#-platform-specific-configurations\n"
          'This message will only shown in debug mode.\n'
          'Platform details: ${e.toString()}',
        );
        return;
      }
      rethrow;
    }
  }

  // TODO: getClipboardImage() should not return gif files on macOS and iOS, same as Android impl

  @override
  Future<Uint8List?> getClipboardImage() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardImage.isUnsupported) {
        throw FlutterError(
          'getClipboardImage() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    try {
      final imageBytes = await methodChannel.invokeMethod<Uint8List?>(
        'getClipboardImage',
      );
      return imageBytes;
    } on PlatformException catch (e) {
      if ((kDebugMode && defaultTargetPlatform == TargetPlatform.android) &&
          (e.code == 'FILE_READ_PERMISSION_DENIED' ||
              e.code == 'FILE_NOT_FOUND')) {
        _printAndroidClipboardImageAccessKnownIssue(e);
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Uint8List?> getClipboardGif() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardGif.isUnsupported) {
        throw FlutterError(
          'getClipboardGif() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    try {
      final gifBytes = await methodChannel.invokeMethod<Uint8List?>(
        'getClipboardGif',
      );
      return gifBytes;
    } on PlatformException catch (e) {
      if ((kDebugMode && defaultTargetPlatform == TargetPlatform.android) &&
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

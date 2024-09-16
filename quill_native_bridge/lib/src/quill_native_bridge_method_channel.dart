import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;

import '../quill_native_bridge.dart';
import 'quill_native_bridge_platform_interface.dart';

class MethodChannelQuillNativeBridge implements QuillNativeBridgePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('quill_native_bridge');

  @override
  Future<bool> isIOSSimulator() async {
    assert(() {
      if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
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
      if (kIsWeb) {
        throw FlutterError(
          'getClipboardHTML() method should be only called on non-web platforms.',
        );
      }
      if (!QuillNativeBridge.supportedClipboardPlatforms
          .contains(defaultTargetPlatform)) {
        throw FlutterError(
          'getClipboardHTML() currently only supports Android, iOS and macOS.',
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
      if (!QuillNativeBridge.isCopyingImageToClipboardSupported) {
        throw FlutterError(
          'copyImageToClipboard() currently only supports Android, iOS, macOS and Web.',
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
          'More details: ${e.message}',
        );
        return;
      }
      rethrow;
    }
  }
}

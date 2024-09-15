import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel;

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
      if (!QuillNativeBridge.supportedHtmlClipboardPlatforms
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
}

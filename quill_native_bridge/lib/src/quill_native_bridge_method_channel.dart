import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
}

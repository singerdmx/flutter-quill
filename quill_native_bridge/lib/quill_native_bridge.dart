library;

import 'src/quill_native_bridge_platform_interface.dart';

class QuillNativeBridge {
  QuillNativeBridge._();

  static Future<bool> isIOSSimulator() =>
      QuillNativeBridgePlatform.instance.isIOSSimulator();
}

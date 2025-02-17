import 'package:flutter_keyboard_visibility_platform_interface/flutter_keyboard_visibility_platform_interface.dart';

/// The Linux implementation of the [FlutterKeyboardVisibilityPlatform] of the
/// FlutterKeyboardVisibility plugin.
class FlutterKeyboardVisibilityPluginLinux
    extends FlutterKeyboardVisibilityPlatform {

  /// Factory method that initializes the FlutterKeyboardVisibility plugin
  /// platform with an instance of the plugin for Linux.
  static void registerWith() {
    FlutterKeyboardVisibilityPlatform.instance =
        FlutterKeyboardVisibilityPluginLinux();
  }

  /// Emits changes to keyboard visibility from the platform. Linux is not
  /// implemented yet so false is returned.
  @override
  Stream<bool> get onChange async* {
    yield false;
  }
}

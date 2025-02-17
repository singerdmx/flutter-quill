import 'package:flutter_keyboard_visibility_platform_interface/flutter_keyboard_visibility_platform_interface.dart';

/// The Windows implementation of the [FlutterKeyboardVisibilityPlatform] of the
/// FlutterKeyboardVisibility plugin.
class FlutterKeyboardVisibilityPluginWindows
    extends FlutterKeyboardVisibilityPlatform {

  /// Factory method that initializes the FlutterKeyboardVisibility plugin
  /// platform with an instance of the plugin for Windows.
  static void registerWith() {
    FlutterKeyboardVisibilityPlatform.instance =
        FlutterKeyboardVisibilityPluginWindows();
  }

  /// Emits changes to keyboard visibility from the platform. Windows is not
  /// implemented yet so false is returned.
  @override
  Stream<bool> get onChange async* {
    yield false;
  }
}

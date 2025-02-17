import 'dart:async';
import 'package:flutter_keyboard_visibility_platform_interface/src/method_channel_flutter_keyboard_visibility.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The platform interface for the flutter_keyboard_visibility plugin
abstract class FlutterKeyboardVisibilityPlatform extends PlatformInterface {
  /// The platform interface for the flutter_keyboard_visibility plugin
  FlutterKeyboardVisibilityPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterKeyboardVisibilityPlatform _instance =
      MethodChannelFlutterKeyboardVisibility();

  /// The default instance of [FlutterKeyboardVisibilityPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterKeyboardVisibility].
  static FlutterKeyboardVisibilityPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterKeyboardVisibilityPlatform] when they register
  /// themselves.
  static set instance(FlutterKeyboardVisibilityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Emits changes to keyboard visibility from the platform
  Stream<bool> get onChange {
    throw UnimplementedError('get onChange has not been implemented.');
  }
}

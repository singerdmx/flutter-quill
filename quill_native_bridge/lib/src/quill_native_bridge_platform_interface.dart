import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'quill_native_bridge_method_channel.dart';

abstract class QuillNativeBridgePlatform extends PlatformInterface {
  /// Constructs a QuillNativeBridgePlatform.
  QuillNativeBridgePlatform() : super(token: _token);

  /// Avoid using `const` when creating the `Object` for `_token`
  static final Object _token = Object();

  static QuillNativeBridgePlatform _instance = MethodChannelQuillNativeBridge();

  /// The default instance of [QuillNativeBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelQuillNativeBridge].
  static QuillNativeBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QuillNativeBridgePlatform] when
  /// they register themselves.
  static set instance(QuillNativeBridgePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Check if the app is running on [iOS Simulator](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device).
  Future<bool> isIOSSimulator() {
    throw UnimplementedError('isIOSSimulator() has not been implemented.');
  }
}

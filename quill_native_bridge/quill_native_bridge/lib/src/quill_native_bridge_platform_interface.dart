import 'package:flutter/foundation.dart' show Uint8List;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'quill_native_bridge_method_channel.dart';

/// **Experimental** as breaking changes can occur
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
  Future<bool> isIOSSimulator() =>
      throw UnimplementedError('isIOSSimulator() has not been implemented.');

  /// Return HTML from the Clipboard for **non-web platforms**.
  Future<String?> getClipboardHTML() =>
      throw UnimplementedError('getClipboardHTML() has not been implemented.');

  /// Copy the [imageBytes] to Clipboard to be pasted on other apps.
  Future<void> copyImageToClipboard(Uint8List imageBytes) =>
      throw UnimplementedError(
        'copyImageToClipboard() has not been implemented.',
      );

  /// Return the copied image from the Clipboard.
  Future<Uint8List?> getClipboardImage() =>
      throw UnimplementedError('getClipboardImage() has not been implemented.');

  /// Return the copied gif from the Clipboard.
  Future<Uint8List?> getClipboardGif() =>
      throw UnimplementedError('getClipboardGif() has not been implemented.');
}

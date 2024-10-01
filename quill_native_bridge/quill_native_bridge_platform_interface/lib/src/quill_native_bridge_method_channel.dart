import 'dart:io' as io show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel;

import '../quill_native_bridge_platform_interface.dart';

// TODO: This class is no longer used for implementations that use method channel.
//  Instead each platform (e.g. Android) have their own implementation which might
//  or might not use method channel, might remove this class completely

const _methodChannel = MethodChannel('quill_native_bridge');

/// A default [QuillNativeBridgePlatform] implementation backed by a platform
/// channel.
class MethodChannelQuillNativeBridge implements QuillNativeBridgePlatform {
  /// For tests only
  @visibleForTesting
  MethodChannel get testMethodChannel {
    assert(() {
      if (kIsWeb) {
        throw StateError(
          'Could not check if this was a test on web. Method channel should'
          'be only accessed for tests outside of $MethodChannelQuillNativeBridge',
        );
      }
      if (!io.Platform.environment.containsKey('FLUTTER_TEST')) {
        throw StateError(
          'The method channel should be only accessed in tests when used '
          'outside of $MethodChannelQuillNativeBridge',
        );
      }
      return true;
    }());
    return _methodChannel;
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    final isSupported = await _methodChannel.invokeMethod<bool?>(
      'isSupported',
      feature.name,
    );
    return isSupported ?? false;
  }

  @override
  Future<bool> isIOSSimulator() async {
    assert(() {
      if (defaultTargetPlatform != TargetPlatform.iOS || kIsWeb) {
        throw FlutterError(
          'isIOSSimulator() method should be called only on iOS.',
        );
      }
      return true;
    }());
    final isSimulator =
        await _methodChannel.invokeMethod<bool>('isIOSSimulator');
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
  Future<String?> getClipboardHtml() async {
    final htmlText =
        await _methodChannel.invokeMethod<String?>('getClipboardHtml');
    return htmlText;
  }

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    await _methodChannel.invokeMethod<void>(
      'copyHtmlToClipboard',
      html,
    );
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    await _methodChannel.invokeMethod<void>(
      'copyImageToClipboard',
      imageBytes,
    );
  }

  // TODO: getClipboardImage() should not return gif files on macOS and iOS, same as Android impl

  @override
  Future<Uint8List?> getClipboardImage() async {
    final imageBytes = await _methodChannel.invokeMethod<Uint8List?>(
      'getClipboardImage',
    );
    return imageBytes;
  }

  @override
  Future<Uint8List?> getClipboardGif() async {
    final gifBytes = await _methodChannel.invokeMethod<Uint8List?>(
      'getClipboardGif',
    );
    return gifBytes;
  }

  @override
  Future<List<String>> getClipboardFiles() async {
    final filePaths = await _methodChannel.invokeMethod<List<String>?>(
      'getClipboardGif',
    );
    return filePaths ?? [];
  }
}

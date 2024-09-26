import 'dart:io' as io show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MethodChannel;

import '../quill_native_bridge_platform_interface.dart';
import 'platform_feature.dart';

// TODO: This was only for iOS, Android, and macOS, now it's no longer needed
//  for Android, will be no longer used for iOS and macOS either soon.

// TODO: Platform-specific check like if this is supported should be removed from
//  here as discussed in https://github.com/singerdmx/flutter-quill/pull/2230

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
  Future<bool> isIOSSimulator() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.isIOSSimulator.isUnsupported) {
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
  Future<String?> getClipboardHTML() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardHTML.isUnsupported) {
        throw FlutterError(
          'getClipboardHTML() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    final htmlText =
        await _methodChannel.invokeMethod<String?>('getClipboardHTML');
    return htmlText;
  }

  @override
  Future<void> copyHTMLToClipboard(String html) async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.copyHTMLToClipboard.isUnsupported) {
        throw FlutterError(
          'copyHTMLToClipboard() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    await _methodChannel.invokeMethod<void>(
      'copyHTMLToClipboard',
      html,
    );
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.copyImageToClipboard.isUnsupported) {
        throw FlutterError(
          'copyImageToClipboard() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    await _methodChannel.invokeMethod<void>(
      'copyImageToClipboard',
      imageBytes,
    );
  }

  // TODO: getClipboardImage() should not return gif files on macOS and iOS, same as Android impl

  @override
  Future<Uint8List?> getClipboardImage() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardImage.isUnsupported) {
        throw FlutterError(
          'getClipboardImage() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    final imageBytes = await _methodChannel.invokeMethod<Uint8List?>(
      'getClipboardImage',
    );
    return imageBytes;
  }

  @override
  Future<Uint8List?> getClipboardGif() async {
    assert(() {
      if (QuillNativeBridgePlatformFeature.getClipboardGif.isUnsupported) {
        throw FlutterError(
          'getClipboardGif() is currently not supported on $defaultTargetPlatform.',
        );
      }
      return true;
    }());
    final gifBytes = await _methodChannel.invokeMethod<Uint8List?>(
      'getClipboardGif',
    );
    return gifBytes;
  }
}

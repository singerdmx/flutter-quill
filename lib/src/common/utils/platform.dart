import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';

import 'quill_native_provider.dart';

// Android

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAndroidApp => !kIsWeb && isAndroid;

// iOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isIosApp => !kIsWeb && isIos;

Future<bool> isIOSSimulator() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
    return false;
  }

  return await QuillNativeProvider.instance.isIOSSimulator();
}

// Mobile

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMobile =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMobileApp => !kIsWeb && isMobile;

// Destkop

@pragma('vm:platform-const-if', !kDebugMode)
bool get isDesktop =>
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isDesktopApp => !kIsWeb && isDesktop;

// macOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMacOSApp => !kIsWeb && isMacOS;

// AppleOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAppleOS =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAppleOSApp => !kIsWeb && isAppleOS;

// Keyboard

@pragma('vm:platform-const-if', !kDebugMode)
bool get isKeyboardOS =>
    isDesktop || defaultTargetPlatform == TargetPlatform.fuchsia;

extension PlatformThemeCheckExtension on ThemeData {
  bool get isMaterial => !isCupertino;
  bool get isCupertino =>
      {TargetPlatform.iOS, TargetPlatform.macOS}.contains(platform);
}

/// Should check if [kIsWeb] is `false` before checking if
/// this is a test.
bool get isFlutterTest {
  assert(() {
    if (kIsWeb) {
      throw FlutterError(
        'The getter `isFlutterTest` should not be used in web',
      );
    }
    return true;
  }());
  return Platform.environment.containsKey('FLUTTER_TEST');
}

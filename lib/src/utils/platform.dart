import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, visibleForTesting;

/// If you want to override the [kIsWeb] use [overrideIsWeb] but it's only
/// for testing
bool isWeb({
  @visibleForTesting bool? overrideIsWeb,
}) {
  return overrideIsWeb ?? kIsWeb;
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isMobile({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return {TargetPlatform.iOS, TargetPlatform.android}.contains(platform);
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isDesktop({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return {TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows}
      .contains(platform);
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isKeyboardOS({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  platform ??= defaultTargetPlatform;
  return isDesktop(
          platform: platform,
          supportWeb: supportWeb,
          overrideIsWeb: overrideIsWeb) ||
      platform == TargetPlatform.fuchsia;
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isAppleOS({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return {
    TargetPlatform.macOS,
    TargetPlatform.iOS,
  }.contains(platform);
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isMacOS({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return TargetPlatform.macOS == platform;
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isIOS({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return TargetPlatform.iOS == platform;
}

/// [supportWeb] is a parameter that ask you if we should care about web support
/// if the value is true then we will return the result no matter if we are
/// on web or using a native app to run the flutter app
bool isAndroid({
  required bool supportWeb,
  TargetPlatform? platform,
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb) && !supportWeb) return false;
  platform ??= defaultTargetPlatform;
  return TargetPlatform.android == platform;
}

Future<bool> isIOSSimulator({
  bool? overrideIsWeb,
}) async {
  if (!isAppleOS(supportWeb: false, overrideIsWeb: overrideIsWeb)) {
    return false;
  }

  final deviceInfo = DeviceInfoPlugin();

  final osInfo = await deviceInfo.deviceInfo;

  if (osInfo is IosDeviceInfo) {
    final iosInfo = osInfo;
    return !iosInfo.isPhysicalDevice;
  }
  return false;
}

bool isFlutterTest({
  bool? overrideIsWeb,
}) {
  if (isWeb(overrideIsWeb: overrideIsWeb)) return false;
  return Platform.environment.containsKey('FLUTTER_TEST');
}

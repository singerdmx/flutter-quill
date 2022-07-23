import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

bool isMobile([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.iOS, TargetPlatform.android}.contains(targetPlatform);
}

bool isDesktop([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows}
      .contains(targetPlatform);
}

bool isKeyboardOS([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return isDesktop(targetPlatform) || targetPlatform == TargetPlatform.fuchsia;
}

bool isAppleOS([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {
    TargetPlatform.macOS,
    TargetPlatform.iOS,
  }.contains(targetPlatform);
}

Future<bool> isIOSSimulator() async {
  final deviceInfo = DeviceInfoPlugin();

  final osInfo = await deviceInfo.deviceInfo;

  if (osInfo is IosDeviceInfo) {
    final iosInfo = osInfo;
    return !iosInfo.isPhysicalDevice;
  }
  return false;
}

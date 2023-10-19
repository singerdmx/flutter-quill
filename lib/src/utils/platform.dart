import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;

bool isMobile([TargetPlatform? targetPlatform]) {
  if (kIsWeb) return false;
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.iOS, TargetPlatform.android}.contains(targetPlatform);
}

bool isDesktop([TargetPlatform? targetPlatform]) {
  if (kIsWeb) return false;
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows}
      .contains(targetPlatform);
}

bool isKeyboardOS([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return isDesktop(targetPlatform) || targetPlatform == TargetPlatform.fuchsia;
}

bool isAppleOS([TargetPlatform? targetPlatform]) {
  if (kIsWeb) return false;
  targetPlatform ??= defaultTargetPlatform;
  return {
    TargetPlatform.macOS,
    TargetPlatform.iOS,
  }.contains(targetPlatform);
}

bool isMacOS([TargetPlatform? targetPlatform]) {
  if (kIsWeb) return false;
  targetPlatform ??= defaultTargetPlatform;
  return TargetPlatform.macOS == targetPlatform;
}

Future<bool> isIOSSimulator() async {
  if (!isAppleOS()) {
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

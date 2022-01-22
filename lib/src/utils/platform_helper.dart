import 'package:flutter/foundation.dart';

bool isMobile([TargetPlatform? targetPlatform]) {
  targetPlatform ??= defaultTargetPlatform;
  return {TargetPlatform.iOS, TargetPlatform.android}.contains(targetPlatform);
}

bool get isDesktop => {
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows
    }.contains(defaultTargetPlatform);

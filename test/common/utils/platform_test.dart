import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_quill/src/common/utils/platform.dart';
import 'package:test/test.dart';

void main() {
  group('Test platform checking logic', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    test('Check isDesktop', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        isDesktop,
        false,
      );

      for (final desktopPlatform in [
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows
      ]) {
        debugDefaultTargetPlatformOverride = desktopPlatform;
        expect(
          isDesktopApp,
          true,
        );

        debugDefaultTargetPlatformOverride = null;
        expect(
          isDesktopApp,
          false,
        );
      }
    });
    test('Check isMobile', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(
        isMobile,
        false,
      );

      for (final mobilePlatform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        debugDefaultTargetPlatformOverride = mobilePlatform;
        expect(
          isMobile,
          true,
        );

        debugDefaultTargetPlatformOverride = TargetPlatform.windows;

        expect(
          isMobile,
          false,
        );
      }
    });
  });
}

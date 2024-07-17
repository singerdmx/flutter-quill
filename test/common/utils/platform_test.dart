import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_quill/src/common/utils/platform.dart';
import 'package:test/test.dart';

void main() {
  group('Test platform checking logic', () {
    var platform = TargetPlatform.linux;
    test('Check isDesktop()', () {
      platform = TargetPlatform.android;
      expect(
        isDesktop(
          platform: platform,
          supportWeb: true,
        ),
        false,
      );

      for (final desktopPlatform in [
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.windows
      ]) {
        expect(
          isDesktop(
            supportWeb: false,
            overrideIsWeb: false,
            platform: desktopPlatform,
          ),
          true,
        );

        expect(
          isDesktop(
            supportWeb: false,
            overrideIsWeb: true,
            platform: desktopPlatform,
          ),
          false,
        );

        expect(
          isDesktop(
            supportWeb: true,
            overrideIsWeb: true,
            platform: desktopPlatform,
          ),
          true,
        );
      }
    });
    test('Check isMobile()', () {
      platform = TargetPlatform.macOS;
      expect(
        isMobile(
          platform: platform,
          supportWeb: true,
        ),
        false,
      );

      for (final mobilePlatform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        expect(
          isMobile(
            platform: mobilePlatform,
            supportWeb: false,
            overrideIsWeb: false,
          ),
          true,
        );

        expect(
          isMobile(
            platform: mobilePlatform,
            supportWeb: false,
            overrideIsWeb: true,
          ),
          false,
        );

        expect(
          isMobile(
            supportWeb: true,
            overrideIsWeb: true,
            platform: mobilePlatform,
          ),
          true,
        );
      }
    });
    test(
      'Check supportWeb parameter when using desktop platform on web',
      () {
        platform = TargetPlatform.macOS;
        expect(
          isDesktop(
            platform: platform,
            supportWeb: true,
          ),
          true,
        );
        expect(
          isDesktop(
            platform: platform,
            supportWeb: false,
            overrideIsWeb: false,
          ),
          true,
        );

        expect(
          isDesktop(
            platform: platform,
            supportWeb: false,
            overrideIsWeb: true,
          ),
          false,
        );
      },
    );

    test(
      'Check supportWeb parameter when using mobile platform on web',
      () {
        platform = TargetPlatform.android;
        expect(
          isMobile(
            platform: platform,
            supportWeb: true,
            overrideIsWeb: true,
          ),
          true,
        );
        expect(
          isMobile(
            platform: platform,
            supportWeb: false,
            overrideIsWeb: false,
          ),
          true,
        );

        expect(
          isMobile(
            platform: platform,
            supportWeb: false,
            overrideIsWeb: true,
          ),
          false,
        );
      },
    );
  });
}

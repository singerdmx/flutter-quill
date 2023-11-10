import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_quill/src/utils/platform.dart';
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

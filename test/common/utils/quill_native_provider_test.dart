import 'package:flutter_quill/src/common/utils/quill_native_provider.dart';
import 'package:test/test.dart';

void main() {
  group('$QuillNativeProvider', () {
    test('defaults to $DefaultQuillNativeBridge', () {
      expect(QuillNativeProvider.instance, isA<DefaultQuillNativeBridge>());
    });

    test('set the instance correctly', () {
      expect(QuillNativeProvider, isNot(isA<_FakeQuillNativeBridge>()));

      QuillNativeProvider.instance = _FakeQuillNativeBridge();
      expect(QuillNativeProvider.instance, isA<_FakeQuillNativeBridge>());
    });

    test('passing null restores the default instance', () {
      final fake = _FakeQuillNativeBridge();
      QuillNativeProvider.instance = fake;

      QuillNativeProvider.instance = null;
      expect(QuillNativeProvider.instance, isA<DefaultQuillNativeBridge>());
    });

    test('isSupported from the instance delegates to the new provider instance',
        () async {
      final fake = _FakeQuillNativeBridge();

      QuillNativeProvider.instance = fake;
      for (final isSupported in {true, false}) {
        fake.testIsSupported = isSupported;

        expect(
          await QuillNativeProvider.instance
              .isSupported(QuillNativeBridgeFeature.isIOSSimulator),
          await fake.isSupported(QuillNativeBridgeFeature.isIOSSimulator),
        );
      }
    });
  });
}

class _FakeQuillNativeBridge extends QuillNativeBridge {
  var testIsSupported = false;
  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async =>
      testIsSupported;
}

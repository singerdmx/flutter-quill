import 'package:flutter_quill/src/common/utils/color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Colors', () {
    test('Can resolve html named colors', () {
      // test some web colors to make sure they resolve correctly
      expect(stringToColor('lightGoldenrodYellow').toARGB32(), 0xFFFAFAD2);
      expect(stringToColor('navajoWhite').toARGB32(), 0xFFFFDEAD);
      expect(stringToColor('mistyRose').toARGB32(), 0xFFFFE4E1);
      expect(stringToColor('darkSlateGray').toARGB32(), 0xFF2F4F4F);

      // case insensitive
      expect(stringToColor('lightgoldenrodyellow').toARGB32(), 0xFFFAFAD2);
      expect(stringToColor('LIGHTGOLDENRODYELLOW').toARGB32(), 0xFFFAFAD2);
    });
    test('Obsolete CSS2 color names pasted from word resolve to a value', () {
      // test some web colors to make sure they resolve correctly
      expect(stringToColor('windowtext').toARGB32(), 0xff000000);
    });
    test('Can resolve transparent', () {
      // test some web colors to make sure they resolve correctly
      expect(stringToColor('transparent').toARGB32(), 0);
    });
    test('Throws an exception if the color name cannot be converted', () {
      // test some web colors to make sure they resolve correctly
      expect(
          () => stringToColor('not a color'), throwsA(isA<UnsupportedError>()));
    });
  });
}

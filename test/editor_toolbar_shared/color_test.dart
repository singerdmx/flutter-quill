import 'package:flutter/material.dart';
import 'package:flutter_quill/src/editor_toolbar_shared/color.dart';
import 'package:test/test.dart';

void main() {
  test('colorToHex converts to hex correctly', () {
    const testCases = [
      _ColorTestCase(color: Color(0xFFFF0000), expectedHex: 'FFFF0000'),
      _ColorTestCase(color: Color(0xFF00FF00), expectedHex: 'FF00FF00'),
      _ColorTestCase(color: Color(0xFF0000FF), expectedHex: 'FF0000FF'),
      _ColorTestCase(color: Color(0x00000000), expectedHex: '00000000'),
      _ColorTestCase(
          color: Color(0x80FFFFFF),
          expectedHex: '80FFFFFF'), // 50% transparent white
      _ColorTestCase(color: Color(0x12345678), expectedHex: '12345678'),
      _ColorTestCase(color: Color(0xFF000000), expectedHex: 'FF000000'),
      _ColorTestCase(color: Color(0xFFFFFFFF), expectedHex: 'FFFFFFFF'),
      _ColorTestCase(color: Colors.black, expectedHex: 'FF000000'),
      _ColorTestCase(color: Colors.white, expectedHex: 'FFFFFFFF'),
      _ColorTestCase(color: Colors.transparent, expectedHex: '00000000'),
    ];
    for (final testCase in testCases) {
      expect(colorToHex(testCase.color), equals(testCase.expectedHex));
    }
  });
}

class _ColorTestCase {
  const _ColorTestCase({
    required this.color,
    required this.expectedHex,
  });

  final Color color;
  final String expectedHex;
}

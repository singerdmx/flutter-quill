import 'package:flutter_quill/src/delta/delta_diff.dart';
import 'package:test/test.dart';

void main() {
  group('getDiff', () {
    test(
      'does not touch the trailing newline when cursorPosition == newText.length',
      () {
        // Reproduces the crash observed with the Myanmar "Visual order" IME
        // on Windows, which can report a cursor/composing position past the
        // document's implicit trailing newline.
        final diff = getDiff('abc\n', 'abcd\n', 5);
        expect(diff.deleted, isEmpty);
        expect(diff.inserted, 'd');
        expect(diff.start, 3);
      },
    );

    test('detects a simple insertion in the middle of the text', () {
      final diff = getDiff('abc', 'abXc', 3);
      expect(diff.start, 2);
      expect(diff.deleted, isEmpty);
      expect(diff.inserted, 'X');
    });

    test('detects a simple deletion', () {
      final diff = getDiff('abcd', 'acd', 1);
      expect(diff.start, 1);
      expect(diff.deleted, 'b');
      expect(diff.inserted, isEmpty);
    });

    test('detects a full text replacement', () {
      final diff = getDiff('abc', 'xyz', 3);
      expect(diff.start, 0);
      expect(diff.deleted, 'abc');
      expect(diff.inserted, 'xyz');
    });

    test('returns an empty diff when the text is unchanged', () {
      final diff = getDiff('abc', 'abc', 3);
      expect(diff.start, 3);
      expect(diff.deleted, isEmpty);
      expect(diff.inserted, isEmpty);
    });
  });
}

import 'package:flutter_quill/src/delta/delta_diff.dart';
import 'package:test/test.dart';

void main() {
  group('getDiff', () {
    test(
      'does not touch the trailing newline when cursorPosition == newText.length '
      '(Myanmar "Visual order" IME crash repro)',
      () {
        // Captured from a real session typing with the Burmese ("Myanmar
        // Visual order") keyboard on Windows: TextInputClient.updateEditingValue
        // reported oldText="ဆ့တိါ့ါတဆ့ြိါ ့\n", newText="ဆ့တိါ့ါတဆ့ြိါ ့တ\n" and
        // selection.extentOffset == newText.length (17). Before this fix,
        // getDiff returned Diff[15, "\n", "တ\n"] (deleting and reinserting the
        // document's implicit trailing newline), which wiped the whole
        // document (docPlainTextAfter became "") and crashed the editor with
        // `targetChild should not be null`.
        final diff = getDiff('ဆ့တိါ့ါတဆ့ြိါ ့\n', 'ဆ့တိါ့ါတဆ့ြိါ ့တ\n', 17);
        expect(diff.deleted, isEmpty);
        expect(diff.inserted, 'တ');
        expect(diff.start, 15);
      },
    );

    test(
      'does not touch the trailing newline for a minimal ASCII repro of the same shape',
      () {
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

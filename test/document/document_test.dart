import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

void main() {
  group('collectStyle', () {
    /// Enter key inserts newline as plain text without inline styles.
    /// collectStyle needs to retrieve style of preceding line
    test('Simulate double enter key at end', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      expect(document.getPlainText(0, document.length),
          'data\nsecond\n\n\nplain\n');
      expect(document.length, 20);
      //
      expect('data\n', document.getPlainText(0, 5));
      for (var index = 0; index < 5; index++) {
        expect(const Style(), document.collectStyle(index, 0));
      }
      //
      expect('second\n', document.getPlainText(5, 7));
      for (var index = 5; index < 12; index++) {
        expect(const Style.attr({'bold': Attribute.bold}),
            document.collectStyle(index, 0));
      }
      //
      expect('\n\n', document.getPlainText(12, 2));
      for (var index = 12; index < 14; index++) {
        expect(const Style.attr({'bold': Attribute.bold}),
            document.collectStyle(index, 0));
      }
      //
      for (var index = 14; index < document.length; index++) {
        expect(const Style(), document.collectStyle(index, 0));
      }
    });

    test('No selection', () {
      final delta = Delta()
        ..insert('plain\n')
        ..insert('bold\n', <String, dynamic>{'bold': true})
        ..insert('italic\n', <String, dynamic>{'italic': true});
      final document = Document.fromDelta(delta);
      //
      expect(
          document.getPlainText(0, document.length), 'plain\nbold\nitalic\n');
      expect(document.length, 18);
      //
      for (var index = 0; index < 6; index++) {
        expect(const Style(), document.collectStyle(index, 0));
      }
      //
      for (var index = 6; index < 11; index++) {
        expect(const Style.attr({'bold': Attribute.bold}),
            document.collectStyle(index, 0));
      }
      //
      for (var index = 11; index < document.length; index++) {
        expect(const Style.attr({'italic': Attribute.italic}),
            document.collectStyle(index, 0));
      }
    });

    test('Selection', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true});
      final document = Document.fromDelta(delta);
      //
      expect(const Style(), document.collectStyle(0, 4));
      expect(const Style(), document.collectStyle(1, 3));
      //
      expect(const Style.attr({'bold': Attribute.bold}),
          document.collectStyle(5, 3));
      expect(const Style.attr({'bold': Attribute.bold}),
          document.collectStyle(8, 3));
      //
      expect(const Style(), document.collectStyle(3, 3));
    });
  });
}

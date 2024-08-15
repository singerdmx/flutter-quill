import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

void main() {
  group('collectStyle', () {
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

    /// Lists and alignments have the same block attribute key but can have different values.
    /// Changing the format value updates the document but must also update the toolbar button state
    /// by ensuring the collectStyles method returns the attribute selected for the newly entered line.
    test('Change block value type', () {
      void doTest(Map<String, dynamic> start, Attribute attr) {
        /// Create a document with 2 lines of block attribute using [start]
        /// Change the format of the last line using [attr] and verify [change]
        final delta = Delta()
          ..insert('A')
          ..insert('\n', start)
          ..insert('B', {'bold': true})
          ..insert('\n', start);
        final document = Document.fromDelta(delta)

          /// insert a newline
          ..insert(3, '\n');

        /// Verify inserted blank line and block type has not changed
        expect(
            document.toDelta(),
            Delta()
              ..insert('A')
              ..insert('\n', start)
              ..insert('B', {'bold': true})
              ..insert('\n\n', start));

        /// Change format of last (empty) line
        document.format(4, 0, attr);
        expect(
            document.toDelta(),
            Delta()
              ..insert('A')
              ..insert('\n', start)
              ..insert('B', {'bold': true})
              ..insert('\n', start)
              ..insert('\n', {attr.key: attr.value}),
            reason: 'document updated');

        /// Verify that the reported style reflects the newly formatted state
        expect(document.collectStyle(4, 0),
            Style.attr({'bold': Attribute.bold, attr.key: attr}),
            reason: 'collectStyle reporting correct attribute');
      }

      doTest({'list': 'ordered'}, const ListAttribute('bullet'));
      doTest({'list': 'checked'}, const ListAttribute('bullet'));
      doTest({}, const ListAttribute('bullet'));
      doTest({'align': 'center'}, const AlignAttribute('right'));
      doTest({'align': 'left'}, const AlignAttribute('center'));
      doTest({}, const AlignAttribute('center'));
    });

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

    /// Links do not cross a line boundary
    /// Enter key inserts newline as plain text without inline styles.
    /// collectStyle needs to retrieve style of preceding line
    test('Links and line boundaries', () {
      final delta = Delta()
        ..insert('A link ')
        ..insert('home page', <String, dynamic>{'link': 'https://unknown.com'})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      const linkStyle =
          Style.attr({'link': LinkAttribute('https://unknown.com')});
      //
      expect(document.collectStyle(15, 0), linkStyle, reason: 'Within Link');
      expect(document.collectStyle(16, 0), const Style(),
          reason: 'At end of link');
      expect(document.collectStyle(17, 0), const Style(),
          reason: 'start of blank line');
      expect(document.collectStyle(18, 0), const Style(),
          reason: 'start of blank line');
    });
  });
}

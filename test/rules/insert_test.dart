import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/rules/insert.dart';
import 'package:test/test.dart';

void main() {
  group('PreserveInlineStylesRule', () {
    const rule = PreserveInlineStylesRule();

    test('Data does not apply', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 1), null);
      expect(rule.apply(document, 0, data: '\n'), null);
    });

    test('Insert in text', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 1, data: 'X', len: 0), null);
      expect(
          rule.apply(document, 6, data: 'X', len: 0),
          Delta()
            ..retain(6)
            ..insert('X', <String, dynamic>{'bold': true}));
      expect(rule.apply(document, 16, data: 'X', len: 0), null,
          reason: 'insertion with no attributes');
    });

    test('Insert at start of line', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'a', len: 0), null);
      expect(
          rule.apply(document, 5, data: 'X', len: 0),
          Delta()
            ..retain(5)
            ..insert('X', <String, dynamic>{'bold': true}));
      expect(
          rule.apply(document, 12, data: 'X', len: 0),
          Delta()
            ..retain(12)
            ..insert('X', <String, dynamic>{'bold': true}));
      expect(
          rule.apply(document, 13, data: 'X', len: 0),
          Delta()
            ..retain(13)
            ..insert('X', <String, dynamic>{'bold': true}));
      expect(rule.apply(document, 14, data: 'X', len: 0), null,
          reason: 'insertion before "plain" has no attributes');
    });

    test('Insert on first line of document with bold text', () {
      final delta = Delta()..insert('data\n', <String, dynamic>{'bold': true});
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0),
          Delta()..insert('X', <String, dynamic>{'bold': true}),
          reason: 'Insert at document start must pickup style for the line');
      expect(
          rule.apply(document, 1, data: 'X', len: 0),
          Delta()
            ..retain(1)
            ..insert('X', <String, dynamic>{'bold': true}));
    });

    test('Insert around image', () {
      final delta = Delta()
        ..insert(<String, String>{'image': 'url'})
        ..insert('data\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0), null);
      expect(rule.apply(document, 1, data: 'X', len: 0), null);
    });

    test('Insert around image with bold text', () {
      final delta = Delta()
        ..insert(<String, String>{'image': 'url'})
        ..insert('data\n', <String, dynamic>{'bold': true});
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0), null,
          reason:
              'Insert before image must pickup inline attribute for the image');
      expect(
          rule.apply(document, 1, data: 'X', len: 0),
          Delta()
            ..retain(1)
            ..insert('X', <String, dynamic>{'bold': true}),
          reason:
              'Insert after image must pickup style for text following the image');
    });

    test('Insert around image with inline attribute', () {
      final delta = Delta()
        ..insert(
            <String, String>{'image': 'url'}, <String, dynamic>{'bold': true})
        ..insert('data\n', <String, dynamic>{'bold': true});
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0),
          Delta()..insert('X', <String, dynamic>{'bold': true}),
          reason: 'Insert before image must pickup style for the image');
      expect(
          rule.apply(document, 1, data: 'X', len: 0),
          Delta()
            ..retain(1)
            ..insert('X', <String, dynamic>{'bold': true}));
    });

    test('Replace in text', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('second\n', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 1), null);
      expect(
          rule.apply(document, 5, data: 'X', len: 1),
          Delta()
            ..retain(6)
            ..insert('X', <String, dynamic>{'bold': true}));
    });

    test('Insert around multiple images', () {
      final delta = Delta()
        ..insert(
            <String, String>{'image': 'url'}, <String, dynamic>{'bold': true})
        ..insert(<String, String>{'image': 'url2'},
            <String, dynamic>{'italic': true})
        ..insert('data\n', <String, dynamic>{'underline': true});
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0),
          Delta()..insert('X', <String, dynamic>{'bold': true}));
      expect(
          rule.apply(document, 1, data: 'X', len: 0),
          Delta()
            ..retain(1)
            ..insert('X', <String, dynamic>{'italic': true}));
      expect(
          rule.apply(document, 2, data: 'X', len: 0),
          Delta()
            ..retain(2)
            ..insert('X', <String, dynamic>{'underline': true}));
    });

    test('Insert around mix of text and images', () {
      final delta = Delta()
        ..insert(
            <String, String>{'image': 'url'}, <String, dynamic>{'bold': true})
        ..insert('p\n')
        ..insert(<String, String>{'image': 'url2'},
            <String, dynamic>{'italic': true})
        ..insert('data\n', <String, dynamic>{'underline': true});
      final document = Document.fromDelta(delta);
      //
      expect(
          rule.apply(document, 3, data: 'X', len: 0),
          Delta()
            ..retain(3)
            ..insert('X', <String, dynamic>{'italic': true}));
    });

    test('Insert around images with NL', () {
      final delta = Delta()
        ..insert('\n\n\n', <String, dynamic>{'strike': true})
        ..insert(
            <String, String>{'image': 'url'}, <String, dynamic>{'bold': true})
        ..insert('\n\n\n', <String, dynamic>{'strike': true})
        ..insert(<String, String>{'image': 'url2'},
            <String, dynamic>{'italic': true})
        ..insert('data\n', <String, dynamic>{'underline': true});
      final document = Document.fromDelta(delta);
      //
      expect(
          rule.apply(document, 2, data: 'X', len: 0),
          Delta()
            ..retain(2)
            ..insert('X', <String, dynamic>{'strike': true}));
      expect(
          rule.apply(document, 6, data: 'X', len: 0),
          Delta()
            ..retain(6)
            ..insert('X', <String, dynamic>{'strike': true}));
      expect(
          rule.apply(document, 7, data: 'X', len: 0),
          Delta()
            ..retain(7)
            ..insert('X', <String, dynamic>{'italic': true}));
    });

    test('Exclude non-inline styles', () {
      final delta = Delta()..insert('\n', <String, dynamic>{'list': 'ordered'});
      final document = Document.fromDelta(delta);
      expect(rule.apply(document, 0, data: 'X', len: 0), null);
    });

    test('Insert around non-inline styles', () {
      final delta = Delta()
        ..insert('data\n')
        ..insert('first')
        ..insert('\n', <String, dynamic>{'list': 'ordered'})
        ..insert('A', <String, dynamic>{'bold': true})
        ..insert('B')
        ..insert('C', <String, dynamic>{'italic': true})
        ..insert('\n\n', <String, dynamic>{'list': 'ordered'})
        ..insert('D', <String, dynamic>{'strike': true})
        ..insert('\n', <String, dynamic>{'list': 'ordered'})
        ..insert(
            <String, String>{'image': 'url'}, <String, dynamic>{'bold': true})
        ..insert('\n', <String, dynamic>{'list': 'ordered'})
        ..insert(' plain\n');
      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0), null);
      expect(rule.apply(document, 5, data: 'X', len: 0), null,
          reason: '1. plain text');
      expect(
          rule.apply(document, 11, data: 'X', len: 0),
          Delta()
            ..retain(11)
            ..insert('X', <String, dynamic>{'bold': true}),
          reason: '2. bold text at start');
      expect(
          rule.apply(document, 15, data: 'X', len: 0),
          Delta()
            ..retain(15)
            ..insert('X', <String, dynamic>{'italic': true}),
          reason: '3. blank entry gets style from end of previous line');
      expect(
          rule.apply(document, 16, data: 'X', len: 0),
          Delta()
            ..retain(16)
            ..insert('X', <String, dynamic>{'strike': true}),
          reason: '4. strike text');
      expect(
          rule.apply(document, 18, data: 'X', len: 0),
          Delta()
            ..retain(18)
            ..insert('X', <String, dynamic>{'bold': true}),
          reason: '5. bold image');
      expect(rule.apply(document, 20, data: 'X', len: 0), null);
      //
      expect(rule.apply(document, 16, data: LogicalKeyboardKey.enter, len: 0),
          null);
    });

    test('Insert around link, insert within link label', () {
      final delta = Delta()
        ..insert(<String, String>{'image': 'imageUrl'},
            <String, dynamic>{'link': 'linkURL'})
        ..insert('data\n')
        ..insert('link', <String, dynamic>{'link': 'linkURL', 'bold': true})
        ..insert('\n');

      final document = Document.fromDelta(delta);
      //
      expect(rule.apply(document, 0, data: 'X', len: 0), Delta()..insert('X'));
      expect(rule.apply(document, 1, data: 'X', len: 0), null);
      expect(
          rule.apply(document, 6, data: 'X', len: 0),
          Delta()
            ..retain(6)
            ..insert('X', <String, dynamic>{'bold': true}));
      expect(
          rule.apply(document, 7, data: 'X', len: 0),
          Delta()
            ..retain(7)
            ..insert('X', <String, dynamic>{'link': 'linkURL', 'bold': true}),
          reason: 'Insertion within link label updates label');
    });
  });
}

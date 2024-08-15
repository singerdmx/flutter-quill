import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

void main() {
  group('collectStyle', () {
    test('Simple', () {
      final delta = Delta()
        ..insert('First\nSecond ')
        ..insert('Bold', <String, dynamic>{'bold': true})
        ..insert('\n\nplain\n');
      final document = Document.fromDelta(delta);
      //
      final line = document.queryChild(6).node as Line;
      expect(line.getPlainText(0, line.length), 'Second Bold\n');
      expect(line.length, 12);
      //
      expect(line.collectStyle(0, line.length), const Style());
      expect(
          line.collectStyle(7, 4), const Style.attr({'bold': Attribute.bold}));
      expect(
          line.collectStyle(7, 5), const Style.attr({'bold': Attribute.bold}),
          reason: 'Include trailing NL');
      expect(
          line.collectStyle(7, 6), const Style.attr({'bold': Attribute.bold}),
          reason: 'Spans next NL');
      expect(line.collectStyle(7, 7), const Style(),
          reason: 'Spans into plain text');
      //
      final line2 = document.queryChild(18).node as Line;
      expect(line2.length, 1);
      expect(
          line2.collectStyle(0, 1), const Style.attr({'bold': Attribute.bold}),
          reason: 'Empty line gets style from previous line');
    });

    test('Block', () {
      final delta = Delta()
        ..insert('first', {'bold': true})
        ..insert('\n', {'list': Attribute.ol})
        ..insert('second', {'bold': true})
        ..insert('\n', {'list': Attribute.ol})
        ..insert('third', {'italic': true})
        ..insert('\n', {'list': Attribute.ol})
        ..insert('\nplain\n');
      final document = Document.fromDelta(delta);
      //
      const orderedList = Attribute('list', AttributeScope.block, Attribute.ol);
      expect(document.collectStyle(0, 4),
          const Style.attr({'bold': Attribute.bold, 'list': orderedList}));
      //
      final first = document.queryChild(1).node as Line;
      expect(first.getPlainText(0, first.length), 'first\n');
      expect(first.length, 6);
      expect(first.collectStyle(0, 2),
          const Style.attr({'bold': Attribute.bold, 'list': orderedList}));
      //
      final second = document.queryChild(6).node as Line;
      expect(second.getPlainText(0, second.length), 'second\n');
      expect(second.length, 7);
      expect(second.collectStyle(2, 4),
          const Style.attr({'bold': Attribute.bold, 'list': orderedList}));
      //
      expect(first.collectStyle(3, 5),
          const Style.attr({'bold': Attribute.bold, 'list': orderedList}),
          reason: 'spans first and second list entry');
      expect(second.collectStyle(3, 6), const Style.attr({'list': orderedList}),
          reason: 'spans second and third list entry');
      //
      final plain = document.queryChild(20).node as Line;
      expect(plain.getPlainText(0, plain.length), 'plain\n');
      expect(plain.length, 6);
      expect(plain.collectStyle(2, 4), const Style());
      //
      final blank = document.queryChild(19).node as Line;
      expect(blank.getPlainText(0, blank.length), '\n');
      expect(blank.length, 1);
      expect(blank.getPlainText(0, 1), '\n');
      expect(blank.collectStyle(0, 1),
          const Style.attr({'italic': Attribute.italic, 'list': orderedList}));
    });
  });
}

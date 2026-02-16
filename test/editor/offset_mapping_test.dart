import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/document/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/src/editor/raw_editor/offset_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

/// A trivial embed builder whose [toPlainText] returns multi-char text.
class _MentionBuilder extends EmbedBuilder {
  @override
  String get key => 'mention';

  @override
  bool get expanded => false;

  @override
  String toPlainText(leaf.Embed node) => '@${node.value.data}';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const SizedBox.shrink();
}

/// A builder that returns default \uFFFC (length 1).
class _ImageBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const SizedBox.shrink();
}

void main() {
  group('OffsetMapping', () {
    test('no embeds produces identity mapping', () {
      final delta = Delta()..insert('Hello world\n');
      final mapping = buildOffsetMapping(delta, null, null);

      expect(mapping.expandedText, 'Hello world\n');
      expect(mapping.docToExpanded(0), 0);
      expect(mapping.docToExpanded(5), 5);
      expect(mapping.docToExpanded(12), 12);
      expect(mapping.expandedToDoc(0), 0);
      expect(mapping.expandedToDoc(5), 5);
      expect(mapping.expandedToDoc(12), 12);
    });

    test('embed with default toPlainText (\\uFFFC) produces identity mapping',
        () {
      final delta = Delta()
        ..insert('Hi ')
        ..insert({'image': 'url.png'})
        ..insert('\n');
      final mapping = buildOffsetMapping(delta, [_ImageBuilder()], null);

      // The image uses the default \uFFFC, so no shift
      expect(mapping.expandedText, 'Hi ${leaf.Embed.kObjectReplacementCharacter}\n');
      expect(mapping.docToExpanded(0), 0);
      expect(mapping.docToExpanded(3), 3); // at embed
      expect(mapping.docToExpanded(4), 4); // after embed
      expect(mapping.expandedToDoc(3), 3);
      expect(mapping.expandedToDoc(4), 4);
    });

    group('single multi-char embed', () {
      late OffsetMapping mapping;

      setUp(() {
        // Document: "Hello " + {mention: JohnDoe} + ". world\n"
        // Doc offsets: H(0) e(1) l(2) l(3) o(4) (5) [embed](6) .(7) (8) w(9) ...
        // Expanded: "Hello @JohnDoe. world\n"
        final delta = Delta()
          ..insert('Hello ')
          ..insert({'mention': 'JohnDoe'})
          ..insert('. world\n');
        mapping = buildOffsetMapping(delta, [_MentionBuilder()], null);
      });

      test('expanded text is correct', () {
        expect(mapping.expandedText, 'Hello @JohnDoe. world\n');
      });

      test('docToExpanded before embed', () {
        expect(mapping.docToExpanded(0), 0);
        expect(mapping.docToExpanded(5), 5);
        expect(mapping.docToExpanded(6), 6); // start of embed
      });

      test('docToExpanded after embed', () {
        // Doc offset 7 = "." which in expanded is at 14
        expect(mapping.docToExpanded(7), 14);
        expect(mapping.docToExpanded(8), 15);
      });

      test('expandedToDoc before embed', () {
        expect(mapping.expandedToDoc(0), 0);
        expect(mapping.expandedToDoc(5), 5);
        expect(mapping.expandedToDoc(6), 6); // at embed start
      });

      test('expandedToDoc inside embed snaps to nearest boundary', () {
        // "@JohnDoe" is at expanded offsets 6-13 (length 8)
        // Midpoint at 10: dist to start = 4, dist to end = 4 → ties go to start
        expect(mapping.expandedToDoc(7), 6); // closer to start
        expect(mapping.expandedToDoc(9), 6); // closer to start
        expect(mapping.expandedToDoc(10), 6); // tie → start
        expect(mapping.expandedToDoc(11), 7); // closer to end
        expect(mapping.expandedToDoc(13), 7); // closer to end
      });

      test('expandedToDoc after embed', () {
        expect(mapping.expandedToDoc(14), 7); // "."
        expect(mapping.expandedToDoc(15), 8);
        expect(mapping.expandedToDoc(21), 14);
      });

      test('expandedToDocFloor inside embed snaps to embed start', () {
        expect(mapping.expandedToDocFloor(6), 6);
        expect(mapping.expandedToDocFloor(7), 6);
        expect(mapping.expandedToDocFloor(13), 6);
        expect(mapping.expandedToDocFloor(14), 7); // past embed
      });

      test('expandedToDocCeil inside embed snaps to embed end', () {
        expect(mapping.expandedToDocCeil(6), 6); // at embed start → before
        expect(mapping.expandedToDocCeil(7), 7); // inside → after embed
        expect(mapping.expandedToDocCeil(13), 7);
        expect(mapping.expandedToDocCeil(14), 7); // at embed end → after
      });

      test('docToExpandedSelection round trip', () {
        final docSel = const TextSelection(baseOffset: 5, extentOffset: 8);
        final expandedSel = mapping.docToExpandedSelection(docSel);
        expect(expandedSel.baseOffset, 5);
        expect(expandedSel.extentOffset, 15); // 8 + 7 shift

        final backToDoc = mapping.expandedToDocSelection(expandedSel);
        expect(backToDoc.baseOffset, 5);
        expect(backToDoc.extentOffset, 8);
      });
    });

    group('multiple embeds', () {
      late OffsetMapping mapping;

      setUp(() {
        // "Hi " + {mention: A} + " and " + {mention: BC} + "!\n"
        // Doc: H(0)i(1) (2)[embed1](3) (4)a(5)n(6)d(7) (8)[embed2](9)!(10)\n(11)
        // Expanded: "Hi @A and @BC!\n"
        final delta = Delta()
          ..insert('Hi ')
          ..insert({'mention': 'A'})
          ..insert(' and ')
          ..insert({'mention': 'BC'})
          ..insert('!\n');
        mapping = buildOffsetMapping(delta, [_MentionBuilder()], null);
      });

      test('expanded text is correct', () {
        expect(mapping.expandedText, 'Hi @A and @BC!\n');
      });

      test('docToExpanded with cumulative shifts', () {
        expect(mapping.docToExpanded(0), 0); // H
        expect(mapping.docToExpanded(3), 3); // embed1 start
        expect(mapping.docToExpanded(4), 5); // space after embed1 (shift +1)
        expect(mapping.docToExpanded(9), 10); // embed2 start (shift +1)
        expect(mapping.docToExpanded(10), 13); // "!" (shift +1+2=3)
        expect(mapping.docToExpanded(11), 14); // \n
      });

      test('expandedToDoc with cumulative shifts', () {
        expect(mapping.expandedToDoc(0), 0);
        expect(mapping.expandedToDoc(5), 4); // space after embed1
        expect(mapping.expandedToDoc(10), 9); // embed2 start
        expect(mapping.expandedToDoc(13), 10); // "!"
      });
    });

    test('embed at offset 0', () {
      final delta = Delta()
        ..insert({'mention': 'X'})
        ..insert(' hi\n');
      final mapping = buildOffsetMapping(delta, [_MentionBuilder()], null);

      expect(mapping.expandedText, '@X hi\n');
      expect(mapping.docToExpanded(0), 0);
      expect(mapping.docToExpanded(1), 2); // after embed
      expect(mapping.expandedToDoc(0), 0);
      expect(mapping.expandedToDoc(1), 0); // inside embed → snap to start
      expect(mapping.expandedToDoc(2), 1);
    });

    test('adjacent embeds', () {
      final delta = Delta()
        ..insert({'mention': 'A'})
        ..insert({'mention': 'B'})
        ..insert('\n');
      final mapping = buildOffsetMapping(delta, [_MentionBuilder()], null);

      expect(mapping.expandedText, '@A@B\n');
      expect(mapping.docToExpanded(0), 0); // embed1
      expect(mapping.docToExpanded(1), 2); // embed2
      expect(mapping.docToExpanded(2), 4); // \n
    });

    test('no embed builders provided falls back to \\uFFFC', () {
      final delta = Delta()
        ..insert('a')
        ..insert({'mention': 'X'})
        ..insert('\n');
      final mapping = buildOffsetMapping(delta, null, null);

      expect(mapping.expandedText, 'a${leaf.Embed.kObjectReplacementCharacter}\n');
      // No shift because \uFFFC is length 1
      expect(mapping.docToExpanded(1), 1);
      expect(mapping.docToExpanded(2), 2);
    });
  });
}

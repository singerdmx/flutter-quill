import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/editor/widgets/text/text_line.dart'
    show TextLine;
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  Future<QuillController> pumpMention(
    WidgetTester tester,
    VoidCallback onMentionTap,
  ) async {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('hello ')
          ..insert('@bob', {'mention': 'bob'})
          ..insert('\n'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    await tester.pumpWidget(
      QuillTestApp.withScaffold(
        QuillEditor.basic(
          controller: controller,
          config: QuillEditorConfig(
            customRecognizerBuilder: (attribute, leaf) =>
                attribute.key == 'mention'
                ? (TapGestureRecognizer()..onTap = onMentionTap)
                : null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  void rebuildTextLine(WidgetTester tester) {
    tester.element(find.byType(TextLine)).markNeedsBuild();
  }

  LongPressGestureRecognizer? findLinkLongPress(WidgetTester tester) {
    LongPressGestureRecognizer? found;
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      void walk(InlineSpan span) {
        if (span is TextSpan) {
          if (span.recognizer is LongPressGestureRecognizer) {
            found = span.recognizer as LongPressGestureRecognizer;
          }
          span.children?.forEach(walk);
        }
      }

      walk(rich.text);
    }
    return found;
  }

  testWidgets(
    '2271 long-pressing text after removing a link does not throw',
    (tester) async {
      final document = Document.fromDelta(
        Delta()
          ..insert('linktext', {'link': 'https://example.com'})
          ..insert('\n'),
      );
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        QuillTestApp.withScaffold(
          SizedBox(
            height: 200,
            child: QuillEditor.basic(
              controller: controller,
              config: QuillEditorConfig(
                linkActionPickerDelegate: (context, link, node) async {
                  return LinkMenuAction.remove;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstRecognizer = findLinkLongPress(tester);
      expect(firstRecognizer, isNotNull);
      expect(firstRecognizer!.onLongPress, isNotNull);

      firstRecognizer.onLongPress!();
      await tester.pumpAndSettle();

      expect(
        controller.document.toDelta().toList().any(
          (op) => op.attributes != null && op.attributes!.containsKey('link'),
        ),
        isFalse,
      );

      expect(findLinkLongPress(tester), isNull);
    },
    variant: const TargetPlatformVariant({TargetPlatform.android}),
  );

  testWidgets(
    '2271 custom tap recognizer survives repeated text-line rebuilds',
    (tester) async {
      var taps = 0;
      final controller = await pumpMention(tester, () => taps++);
      addTearDown(controller.dispose);

      for (var count = 1; count <= 3; count++) {
        rebuildTextLine(tester);
        await tester.pump();
        final richText = find
            .descendant(
              of: find.byType(TextLine),
              matching: find.byType(RichText),
            )
            .first;
        final paragraph = tester.renderObject<RenderParagraph>(richText);
        final left = paragraph.getOffsetForCaret(
          const TextPosition(offset: 8),
          Rect.zero,
        );
        final right = paragraph.getOffsetForCaret(
          const TextPosition(offset: 9),
          Rect.zero,
        );
        await tester.tapAt(
          paragraph.localToGlobal(
            Offset((left.dx + right.dx) / 2, paragraph.size.height / 2),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(taps, count);
      }
    },
    variant: const TargetPlatformVariant({TargetPlatform.android}),
  );

  testWidgets(
    '2271 custom tap text retains its pointer through rebuilds',
    (tester) async {
      final controller = await pumpMention(tester, () {});
      addTearDown(controller.dispose);

      for (var count = 0; count < 3; count++) {
        final richText = tester.widget<RichText>(
          find
              .descendant(
                of: find.byType(TextLine),
                matching: find.byType(RichText),
              )
              .first,
        );
        TextSpan? mentionSpan;
        richText.text.visitChildren((span) {
          if (span is TextSpan && span.text == '@bob') {
            mentionSpan = span;
            return false;
          }
          return true;
        });
        expect(mentionSpan?.mouseCursor, SystemMouseCursors.click);
        rebuildTextLine(tester);
        await tester.pump();
      }
    },
    variant: const TargetPlatformVariant({TargetPlatform.macOS}),
  );
}

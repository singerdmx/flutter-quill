import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
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

  testWidgets('2271 long-pressing text after removing a link does not throw', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

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
    debugDefaultTargetPlatformOverride = null;
  });
}

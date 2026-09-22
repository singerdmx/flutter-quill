import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tap is recognized after a right click whose pointer up was lost',
    (tester) async {
      final controller = QuillController.basic()
        ..document = Document.fromJson([
          {'insert': 'Splitting bills with friends\n'},
        ]);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QuillEditor.basic(controller: controller)),
        ),
      );

      final editor = find.byType(QuillEditor);
      final topLeft = tester.getTopLeft(editor);
      final textPoint = topLeft + const Offset(20, 10);

      controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 9),
        ChangeSource.local,
      );
      await tester.pump();

      // Right click. The browser context menu swallows the pointer up on the
      // web, so the framework never receives it.
      final rightClick = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await rightClick.down(textPoint);
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.selection.isCollapsed, isFalse);

      // A regular click elsewhere must collapse the selection.
      final click = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 2,
      );
      await click.down(topLeft + const Offset(150, 10));
      await click.up();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.selection.isCollapsed, isTrue);
    },
  );
}

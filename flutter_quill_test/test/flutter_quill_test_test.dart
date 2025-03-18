import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic();
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('Test QuillEditor interactions', (tester) async {
    // Build the QuillEditor widget
    await tester.pumpWidget(
      MaterialApp(
        home: QuillEditor.basic(
          controller: controller,
        ),
      ),
    );

    await tester.tap(find.byType(QuillEditor));
    await tester.quillEnterText(find.byType(QuillEditor), 'Hello, World!\n');
    await tester.idle();
    expect(controller.document.toPlainText(), 'Hello, World!\n');
    expect(controller.selection.isCollapsed, isTrue);

    await tester.quillMoveCursorTo(find.byType(QuillEditor), 12);
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection, const TextSelection.collapsed(offset: 12));

    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 13);
    expect(controller.selection,
        const TextSelection(baseOffset: 12, extentOffset: 13));

    await tester.quillReplaceText(find.byType(QuillEditor), ' and hi, World!');
    expect(controller.document.toPlainText(), 'Hello, World and hi, World!\n');

    await tester.quillMoveCursorTo(find.byType(QuillEditor), 0);
    expect(controller.selection.isCollapsed, isTrue);
    expect(controller.selection, const TextSelection.collapsed(offset: 0));

    await tester.quillExpandSelectionTo(find.byType(QuillEditor), 7);
    expect(controller.selection.isCollapsed, isFalse);
    expect(controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 7));

    await tester.quillRemoveTextInSelection(find.byType(QuillEditor));
    expect(controller.document.toPlainText(), 'World and hi, World!\n');
  });
}

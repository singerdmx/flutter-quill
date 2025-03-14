import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_quill_test/src/test/selection_interactions/widget_tester_toolbar_extension.dart';
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

  testWidgets('Test QuillEditor toolbar interactions', (tester) async {
    // Build the QuillEditor widget
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: <LocalizationsDelegate>[
          FlutterQuillLocalizations.delegate,
        ],
        home: Column(
          children: [
            QuillSimpleToolbar(
              controller: controller,
              config: const QuillSimpleToolbarConfig(
                headerStyleType: HeaderStyleType.buttons,
                multiRowsDisplay: false,
                showAlignmentButtons: true,
                showLineHeightButton: true,
              ),
            ),
            QuillEditor.basic(
              controller: controller,
            ),
          ],
        ),
      ),
    );
    await tester.idle();

    await tester.tap(find.byType(QuillEditor));
    // Enter text
    await tester.quillEnterText(find.byType(QuillEditor), 'Hello, World!\n');
    await tester.idle();
    expect(controller.document.toPlainText(), 'Hello, World!\n');
    expect(controller.selection.isCollapsed, isTrue);

    await tester.quillUpdateSelection(find.byType(QuillEditor), 0, 5);
    expect(controller.selection.isCollapsed, false);
    expect(controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 5));

    var nodes = List<Node>.from(
      await tester.getNodesInSelection(
        find.byType(QuillEditor),
      ),
    );
    expect((nodes.first as Line).first?.toPlainText(), 'Hello, World!');
    expect((nodes.first as Line).first?.style.toJson(), isNull);

    await tester.pressHeaderToolbarOption(
      find.byType(QuillEditor),
      2,
    );

    nodes = List<Node>.from(
      await tester.getNodesInSelection(
        find.byType(QuillEditor),
      ),
    );
    expect((nodes.first as Line).first?.toPlainText(), 'Hello');
    expect((nodes.first as Line).first?.style.toJson(), {'bold': true});
    expect((nodes.first as Line).last.toPlainText(), ', World!');
    expect((nodes.first as Line).last.style.toJson(), isNull);
  });
}

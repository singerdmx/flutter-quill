import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bug fix', () {
    group(
        '1266 - QuillToolbar.basic() custom buttons do not have correct fill'
        'color set', () {
      testWidgets('fillColor of custom buttons and builtin buttons match',
          (tester) async {
        const tooltip = 'custom button';

        await tester.pumpWidget(MaterialApp(
            home: QuillToolbar.basic(
          showRedo: false,
          controller: QuillController.basic(),
          customButtons: [const QuillCustomButton(tooltip: tooltip)],
        )));

        final builtinFinder = find.descendant(
            of: find.byType(HistoryButton),
            matching: find.byType(QuillIconButton),
            matchRoot: true);
        expect(builtinFinder, findsOneWidget);
        final builtinButton =
            builtinFinder.evaluate().first.widget as QuillIconButton;

        final customFinder = find.descendant(
            of: find.byType(QuillToolbar),
            matching: find.byWidgetPredicate((widget) =>
                widget is QuillIconButton && widget.tooltip == tooltip),
            matchRoot: true);
        expect(customFinder, findsOneWidget);
        final customButton =
            customFinder.evaluate().first.widget as QuillIconButton;

        expect(customButton.fillColor, equals(builtinButton.fillColor));
      });
    });

    group('1189 - The provided text position is not in the current node', () {
      late QuillController controller;
      late QuillEditor editor;

      setUp(() {
        controller = QuillController.basic();
        editor = QuillEditor.basic(controller: controller, readOnly: false);
      });

      tearDown(() {
        controller.dispose();
      });

      testWidgets('Refocus editor after controller clears document',
          (tester) async {
        await tester.pumpWidget(MaterialApp(home: Column(children: [editor])));
        await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

        editor.focusNode.unfocus();
        await tester.pump();
        controller.clear();
        editor.focusNode.requestFocus();
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Refocus editor after removing block attribute',
          (tester) async {
        await tester.pumpWidget(MaterialApp(home: Column(children: [editor])));
        await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

        controller.formatSelection(Attribute.ul);
        editor.focusNode.unfocus();
        await tester.pump();
        controller.formatSelection(const ListAttribute(null));
        editor.focusNode.requestFocus();
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tap checkbox in unfocused editor', (tester) async {
        await tester.pumpWidget(MaterialApp(home: Column(children: [editor])));
        await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

        controller.formatSelection(Attribute.unchecked);
        editor.focusNode.unfocus();
        await tester.pump();
        await tester.tap(find.byType(CheckboxPoint));
        expect(tester.takeException(), isNull);
      });
    });
  });
}

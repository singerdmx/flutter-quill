import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bug fix', () {
    group(
        '1266 - QuillToolbar.basic() custom buttons do not have correct fill'
        'color set', () {
      testWidgets('fillColor of custom buttons and builtin buttons match',
          (tester) async {
        const tooltip = 'custom button';

        final controller = QuillController.basic();

        await tester.pumpWidget(
          MaterialApp(
            home: QuillProvider(
              configurations: QuillConfigurations(
                controller: controller,
              ),
              child: const QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  showRedo: false,
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      tooltip: tooltip,
                    )
                  ],
                ),
              ),
            ),
          ),
        );

        final builtinFinder = find.descendant(
          of: find.byType(QuillToolbarHistoryButton),
          matching: find.byType(QuillToolbarIconButton),
          matchRoot: true,
        );
        expect(builtinFinder, findsOneWidget);
        final builtinButton =
            builtinFinder.evaluate().first.widget as QuillToolbarIconButton;

        final customFinder = find.descendant(
            of: find.byType(QuillBaseToolbar),
            matching: find.byWidgetPredicate((widget) =>
                widget is QuillToolbarIconButton && widget.tooltip == tooltip),
            matchRoot: true);
        expect(customFinder, findsOneWidget);
        final customButton =
            customFinder.evaluate().first.widget as QuillToolbarIconButton;

        expect(customButton.fillColor, equals(builtinButton.fillColor));
      });
    });

    group('1189 - The provided text position is not in the current node', () {
      late QuillController controller;
      late QuillEditor editor;

      setUp(() {
        controller = QuillController.basic();
        editor = QuillEditor.basic(
          // ignore: avoid_redundant_argument_values
          configurations: const QuillEditorConfigurations(
            // ignore: avoid_redundant_argument_values
            readOnly: false,
          ),
        );
      });

      tearDown(() {
        controller.dispose();
      });

      testWidgets('Refocus editor after controller clears document',
          (tester) async {
        await tester.pumpWidget(
          QuillProvider(
            configurations: QuillConfigurations(controller: controller),
            child: MaterialApp(
              home: Column(
                children: [editor],
              ),
            ),
          ),
        );
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
        await tester.pumpWidget(QuillProvider(
          configurations: QuillConfigurations(controller: controller),
          child: MaterialApp(
            home: Column(
              children: [editor],
            ),
          ),
        ));
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
        await tester.pumpWidget(
          QuillProvider(
            configurations: QuillConfigurations(controller: controller),
            child: MaterialApp(
              home: Column(
                children: [editor],
              ),
            ),
          ),
        );
        await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

        controller.formatSelection(Attribute.unchecked);
        editor.focusNode.unfocus();
        await tester.pump();
        await tester.tap(find.byType(QuillEditorCheckboxPoint));
        expect(tester.takeException(), isNull);
      });
    });
  });
}

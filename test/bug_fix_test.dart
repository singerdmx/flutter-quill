import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common/utils/quill_test_app.dart';
import 'editor/editor_config_utils.dart';

void main() {
  group('Bug fix', () {
    group('1266 - QuillToolbar.basic() custom buttons do not have correct fill'
        'color set', () {
      testWidgets('fillColor of custom buttons and builtin buttons match', (
        tester,
      ) async {
        const tooltip = 'custom button';

        final controller = QuillController.basic();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            home: Scaffold(
              body: QuillSimpleToolbar(
                controller: controller,
                config: const QuillSimpleToolbarConfig(
                  showRedo: false,
                  customButtons: [
                    QuillToolbarCustomButtonOptions(tooltip: tooltip),
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

        final customFinder = find.descendant(
          of: find.byType(QuillSimpleToolbar),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is QuillToolbarIconButton && widget.tooltip == tooltip,
          ),
          matchRoot: true,
        );
        expect(customFinder, findsOneWidget);
      });
    });

    group('1189 - The provided text position is not in the current node', () {
      late QuillController controller;
      late QuillEditor editor;

      setUp(() {
        controller = QuillController.basic();
        editor = QuillEditor.basic(controller: controller);
      });

      tearDown(() {
        controller.dispose();
      });

      testWidgets('Refocus editor after controller clears document', (
        tester,
      ) async {
        await tester.pumpWidget(MaterialApp(home: Column(children: [editor])));
        await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

        editor.focusNode.unfocus();
        await tester.pump();
        controller.clear();
        editor.focusNode.requestFocus();
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Refocus editor after removing block attribute', (
        tester,
      ) async {
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
        await tester.tap(find.byType(QuillCheckboxPoint));
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('1742 - Disable context menu after selection for desktop platform', () {
    late QuillController controller;

    setUp(() {
      controller = QuillController.basic();
    });

    tearDown(() {
      controller.dispose();
    });

    for (final device in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
      testWidgets(
        '1742 - Disable context menu after selection for desktop platform $device',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: QuillEditor(
                focusNode: FocusNode(),
                scrollController: ScrollController(),
                controller: controller,
                config: const QuillEditorConfig(autoFocus: true, expands: true),
              ),
            ),
          );
          if (device == PointerDeviceKind.mouse) {
            expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
            // Long press to show menu
            await tester.longPress(find.byType(QuillEditor), kind: device);
            await tester.pumpAndSettle();

            // Verify custom widget not shows
            expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

            await tester.tap(
              find.byType(QuillEditor),
              buttons: kSecondaryButton,
              kind: device,
            );
            await tester.pumpAndSettle();
            while (find
                .byType(AdaptiveTextSelectionToolbar)
                .evaluate()
                .isEmpty) {
              await tester.pumpAndSettle();
            }

            // Verify custom widget shows
            expect(find.byType(AdaptiveTextSelectionToolbar), findsAny);
          } else {
            // Long press to show menu
            await tester.longPress(find.byType(QuillEditor), kind: device);
            await tester.pumpAndSettle();

            // Verify custom widget shows
            expect(find.byType(AdaptiveTextSelectionToolbar), findsAny);
          }
        },
      );
    }
  });
  group(
    "2521 - QuillEditor doesn't respect the system keyboard brightness by default on iOS",
    () {
      test('keyboardAppearance defaults to null', () {
        expect(const QuillEditorConfig().keyboardAppearance, null);
        expect(createFakeRawEditorConfig().keyboardAppearance, null);
      });

      testWidgets('uses the keyboardAppearance from the config if not null', (
        tester,
      ) async {
        for (final keyboardAppearanceValue in {
          Brightness.dark,
          Brightness.light,
        }) {
          final key = GlobalKey<QuillRawEditorState>();
          await tester.pumpWidget(
            QuillTestApp.home(
              QuillRawEditor(
                key: key,
                config: createFakeRawEditorConfig(
                  keyboardAppearance: keyboardAppearanceValue,
                ),
                controller: QuillController.basic(),
              ),
            ),
          );

          final keyboardAppearance = key.currentState
              ?.createKeyboardAppearance();

          expect(keyboardAppearance, keyboardAppearanceValue);
        }
      });

      testWidgets(
        'uses the keyboardAppearance from the ThemeData if not declared in the config',
        (tester) async {
          for (final keyboardAppearanceValue in {
            Brightness.dark,
            Brightness.light,
          }) {
            final key = GlobalKey<QuillRawEditorState>();
            await tester.pumpWidget(
              QuillTestApp.home(
                CupertinoTheme(
                  data: CupertinoThemeData(brightness: keyboardAppearanceValue),
                  child: Theme(
                    data: ThemeData(brightness: keyboardAppearanceValue),
                    child: QuillRawEditor(
                      key: key,
                      config: createFakeRawEditorConfig(
                        keyboardAppearance: null,
                      ),
                      controller: QuillController.basic(),
                    ),
                  ),
                ),
              ),
            );

            final keyboardAppearance = key.currentState
                ?.createKeyboardAppearance();

            expect(keyboardAppearance, keyboardAppearanceValue);
          }
        },
      );
    },
  );
  group('malformed UTF-16 crash when the composing range splits an emoji', () {
    testWidgets(
      'the composing decoration is skipped when the range cuts a surrogate '
      'pair instead of laying out a malformed span',
      (tester) async {
        // The emoji occupies code units 2 and 3.
        final controller = QuillController.basic()
          ..document.insert(0, 'ab\u{1F600}cd');
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          QuillTestApp.withScaffold(
            QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(autoFocus: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A composing range the IME reported against an older document state
        // can end inside the surrogate pair. Splitting the text there used to
        // hand a lone surrogate to the paragraph builder, which throws
        // 'string is not well-formed UTF-16' from addText during layout.
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: controller.document.toPlainText(),
            selection: const TextSelection.collapsed(offset: 2),
            composing: const TextRange(start: 0, end: 3),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Clear the composing range: closeConnectionIfNeeded notifies the
        // composing listener from dispose, which asserts on the defunct
        // element when the editor is torn down with a range still set.
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: controller.document.toPlainText(),
            selection: const TextSelection.collapsed(offset: 2),
          ),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}

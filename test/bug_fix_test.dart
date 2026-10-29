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
  group('Mouse drag-select past the bottom of the viewport', () {
    testWidgets('scrolls down to follow the pointer', (tester) async {
      final controller = QuillController(
        document: Document()
          ..insert(0, List.generate(60, (i) => 'Line $i').join('\n')),
        selection: const TextSelection.collapsed(offset: 0),
      );
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);
      await tester.pumpWidget(
        QuillTestApp.withScaffold(
          SizedBox(
            height: 300,
            child: QuillEditor.basic(
              controller: controller,
              scrollController: scrollController,
              config: const QuillEditorConfig(expands: true),
            ),
          ),
        ),
      );

      final editor = find.byType(QuillEditor);
      final start = tester.getTopLeft(editor) + const Offset(10, 10);
      final gesture = await tester.startGesture(
        start,
        kind: PointerDeviceKind.mouse,
        buttons: kPrimaryMouseButton,
      );
      await tester.pump();
      await gesture.moveTo(tester.getBottomLeft(editor) + const Offset(10, -2));
      await tester.pumpAndSettle();
      await gesture.moveBy(const Offset(0, 1));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0));
    });

    // Pumps a mouse drag-select from the top of the editor to [holdAt] and
    // holds the pointer still there; returns the scroll offset it reached on
    // arrival and after holding.
    Future<(double, double)> holdDragAt(
      WidgetTester tester,
      ScrollController scrollController,
      Offset Function(Rect editor) holdAt,
    ) async {
      final editor = tester.getRect(find.byType(QuillEditor));
      final gesture = await tester.startGesture(
        editor.topLeft + const Offset(10, 10),
        kind: PointerDeviceKind.mouse,
        buttons: kPrimaryMouseButton,
      );
      await tester.pump();
      // A sideways move first: the drag recognizer is horizontal, and the
      // update it accepts on only carries the horizontal part of the move.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(holdAt(editor));
      await tester.pump(const Duration(milliseconds: 100));
      final arrived = scrollController.offset;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final held = scrollController.offset;
      await gesture.up();
      await tester.pumpAndSettle();
      return (arrived, held);
    }

    Future<ScrollController> pumpLongNote(
      WidgetTester tester, {
      double scrollBottomInset = 0,
    }) async {
      final controller = QuillController(
        document: Document()
          ..insert(0, List.generate(200, (i) => 'Line $i').join('\n')),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);
      await tester.pumpWidget(
        QuillTestApp.withScaffold(
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 300,
              child: QuillEditor.basic(
                controller: controller,
                scrollController: scrollController,
                config: QuillEditorConfig(
                  expands: true,
                  showCursor: false,
                  scrollBottomInset: scrollBottomInset,
                ),
              ),
            ),
          ),
        ),
      );
      return scrollController;
    }

    testWidgets('keeps scrolling while the pointer is held at the edge', (
      tester,
    ) async {
      final scrollController = await pumpLongNote(tester);
      final (arrived, held) = await holdDragAt(
        tester,
        scrollController,
        (editor) => editor.bottomLeft + const Offset(80, -2),
      );
      expect(held, greaterThan(arrived + 50));
    });

    testWidgets('treats the top of a covered bottom as the edge', (
      tester,
    ) async {
      // The pointer is held 40px above the editor's real bottom edge - out of
      // auto-scroll reach - but inside the 60px drawn over it.
      final scrollController = await pumpLongNote(
        tester,
        scrollBottomInset: 60,
      );
      final (arrived, held) = await holdDragAt(
        tester,
        scrollController,
        (editor) => editor.bottomLeft + const Offset(80, -40),
      );
      expect(held, greaterThan(arrived + 50));
    });
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_quill/quill_delta.dart';
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

  group('Selection handles hide outside the visible part of the editor', () {
    testWidgets('when the line of a handle scrolls below the editor', (
      tester,
    ) async {
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      scrollController.jumpTo(800);
      await tester.pumpAndSettle();
      final editorRect = tester.getRect(find.byType(QuillEditor));
      // The last line whose middle is at least 30 px above the bottom of the
      // editor.
      final line =
          _getFirstLineBelow(tester, controller, editorRect.bottom - 30) - 1;
      await _longPressWord(tester, controller, line: line);
      expect(_getSelectionHandleState(tester, isStart: false).opacity, 1);

      scrollController.jumpTo(800 - 80);
      await tester.pumpAndSettle();

      expect(_getRenderEditor(tester).selectionEndInViewport.value, isFalse);
      expect(_getSelectionHandleState(tester, isStart: false).opacity, 0);
    });

    testWidgets(
      'and then do not take the taps on the widgets below the editor',
      (tester) async {
        var barTapCount = 0;
        final (:controller, :scrollController) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(100),
          isBarBelow: true,
          onBarTap: () => barTapCount++,
        );
        scrollController.jumpTo(800);
        await tester.pumpAndSettle();
        final editorRect = tester.getRect(find.byType(QuillEditor));
        // The last line whose middle is at least 30 px above the bottom of the
        // editor.
        final line =
            _getFirstLineBelow(tester, controller, editorRect.bottom - 30) - 1;
        await _longPressWord(tester, controller, line: line);
        final handleCenterX = _getSelectionHandleState(
          tester,
          isStart: true,
        ).drawnRect.center.dx;
        scrollController.jumpTo(800 - 80);
        await tester.pumpAndSettle();
        expect(
          _getRenderEditor(tester).selectionStartInViewport.value,
          isFalse,
        );

        // The place where a handle at the bottom edge of the editor would
        // receive touches.
        await tester.tapAt(Offset(handleCenterX, editorRect.bottom + 10));
        await tester.pumpAndSettle();

        expect(barTapCount, 1);
      },
    );

    for (final (platform, isBarBelow) in [
      (TargetPlatform.android, false),
      (TargetPlatform.iOS, false),
      (TargetPlatform.android, true),
    ]) {
      testWidgets(
        'and are not drawn over the bar ${isBarBelow ? 'below' : 'above'} the '
        'editor during a fast scroll',
        (tester) async {
          final (:controller, :scrollController) = await _pumpEditorWithMenu(
            tester,
            _createLinesJson(100),
            isBarBelow: isBarBelow,
          );
          if (isBarBelow) {
            scrollController.jumpTo(800);
            await tester.pumpAndSettle();
          }
          final editorRect = tester.getRect(find.byType(QuillEditor));
          // A line whose middle is at least 30 px from the edge. The scroll
          // moves the line out through that edge.
          final line = isBarBelow
              ? _getFirstLineBelow(tester, controller, editorRect.bottom - 30) -
                    1
              : _getFirstLineBelow(tester, controller, editorRect.top + 30);
          await _selectWord(tester, controller, line: line);
          final lineText = find
              .descendant(
                of: find.byType(QuillEditor),
                matching: find.byType(RichText),
              )
              .at(line);
          final barRect = tester.getRect(find.byWidget(_toolbarRow));

          // 48 px in each frame of 16 ms is the speed of a fast fling.
          for (var frame = 0; frame < 10; frame++) {
            scrollController.jumpTo(
              scrollController.offset + (isBarBelow ? -48 : 48),
            );
            await tester.pump(const Duration(milliseconds: 16));
            final lineTop = tester.getRect(lineText).top;
            if (lineTop >= editorRect.top && lineTop <= editorRect.bottom) {
              continue;
            }
            for (final isStart in [true, false]) {
              final handle = _getSelectionHandleState(tester, isStart: isStart);
              expect(
                handle.isShown &&
                    handle.opacity > 0 &&
                    handle.drawnRect.overlaps(barRect),
                isFalse,
                reason: 'frame $frame',
              );
            }
          }
        },
        variant: TargetPlatformVariant.only(platform),
      );
    }

    // An item of a ListView is a repaint boundary. The list therefore does not
    // paint the editor again when it scrolls.
    for (final isListView in [false, true]) {
      testWidgets(
        'when a ${isListView ? 'ListView' : 'SingleChildScrollView'} around '
        'the editor moves their line out of view',
        (tester) async {
          final outerScrollController = ScrollController();
          addTearDown(outerScrollController.dispose);
          final (:controller, scrollController: _) = await _pumpEditorWithMenu(
            tester,
            _createLinesJson(100),
            outerScrollController: outerScrollController,
            isInListView: isListView,
          );
          outerScrollController.jumpTo(400);
          await tester.pumpAndSettle();
          final viewportTop = tester.getRect(find.byType(Scrollable)).top;
          // The first line whose middle is at least 30 px below the top of the
          // scroll view.
          final line = _getFirstLineBelow(tester, controller, viewportTop + 30);
          await _longPressWord(tester, controller, line: line);
          expect(_getSelectionHandleState(tester, isStart: true).opacity, 1);

          outerScrollController.jumpTo(400 + 80);
          await tester.pumpAndSettle();

          expect(
            _getRenderEditor(tester).selectionStartInViewport.value,
            isFalse,
          );
          expect(_getSelectionHandleState(tester, isStart: true).opacity, 0);
        },
      );
    }
  });

  testWidgets(
    'Selection handles hide when a pinned app bar covers their line',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final (:controller, scrollController: _) =
          await _pumpEditorUnderPinnedAppBar(tester, outerScrollController);
      await _longPressWord(tester, controller, line: 3);
      expect(_getSelectionHandleState(tester, isStart: true).opacity, 1);

      // Scrolls the middle of the line to 30 px below the top of the screen.
      // There, the line is under the app bar. The app bar stays 56 px tall.
      outerScrollController.jumpTo(
        _getCaretCenter(tester, controller.selection.start).dy - 30,
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(AppBar)).bottom,
        greaterThan(_getCaretCenter(tester, controller.selection.start).dy),
      );

      expect(_getRenderEditor(tester).selectionStartInViewport.value, isFalse);
      expect(_getSelectionHandleState(tester, isStart: true).opacity, 0);
    },
  );

  for (final (name, scrollDirection, reverse) in [
    ('at the bottom of a reversed scroll view', Axis.vertical, true),
    ('at the left of a horizontal scroll view', Axis.horizontal, false),
  ]) {
    testWidgets('Selection handles hide when a pinned header $name covers '
        'their line', (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final isHorizontal = scrollDirection == Axis.horizontal;
      final (:controller, scrollController: _) = await _pumpEditor(
        tester,
        _createLinesJson(30),
        config: const QuillEditorConfig(
          padding: EdgeInsets.all(16),
          scrollable: false,
        ),
        buildScreen: (editor) => Scaffold(
          body: CustomScrollView(
            controller: outerScrollController,
            scrollDirection: scrollDirection,
            reverse: reverse,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeaderDelegate(),
              ),
              SliverToBoxAdapter(
                child: isHorizontal
                    ? SizedBox(width: 700, child: editor)
                    : editor,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 2000, width: 2000),
              ),
            ],
          ),
        ),
      );
      final headerFinder = find.descendant(
        of: find.byType(SliverPersistentHeader),
        matching: find.byType(ColoredBox),
      );
      final line = isHorizontal
          ? 4
          : _getFirstLineBelow(tester, controller, 300);
      await _longPressWord(tester, controller, line: line);
      final renderEditor = _getRenderEditor(tester);
      expect(renderEditor.selectionStartInViewport.value, isTrue);

      // Moves the middle of the word 20 px into the header.
      final wordMiddle = _getCaretCenter(tester, controller.selection.start);
      final headerRect = tester.getRect(headerFinder);
      outerScrollController.jumpTo(
        isHorizontal
            ? wordMiddle.dx - (headerRect.right - 20)
            : headerRect.top + 20 - wordMiddle.dy,
      );
      await tester.pumpAndSettle();

      expect(
        headerRect.contains(
          _getCaretCenter(tester, controller.selection.start),
        ),
        isTrue,
      );
      expect(renderEditor.selectionStartInViewport.value, isFalse);
    });
  }

  testWidgets(
    'Selection handles hide at the edge that a pinned header covers when the '
    'header is in the part of a scroll view that grows upward',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final centerKey = UniqueKey();
      final (:controller, scrollController: _) = await _pumpEditor(
        tester,
        _createLinesJson(60),
        config: const QuillEditorConfig(
          padding: EdgeInsets.all(16),
          scrollable: false,
        ),
        buildScreen: (editor) => Scaffold(
          body: CustomScrollView(
            controller: outerScrollController,
            center: centerKey,
            anchor: 0.9,
            slivers: [
              SliverToBoxAdapter(child: editor),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeaderDelegate(),
              ),
              SliverToBoxAdapter(
                key: centerKey,
                child: const SizedBox(height: 2000),
              ),
            ],
          ),
        ),
      );
      // The header moves to the bottom of the screen and stays there.
      outerScrollController.jumpTo(-100);
      await tester.pumpAndSettle();
      final headerRect = tester.getRect(find.byType(ColoredBox).last);

      await _longPressWord(
        tester,
        controller,
        line: _getFirstLineBelow(tester, controller, 30),
      );
      // A line near the top of the screen, far from the header.
      expect(_getRenderEditor(tester).selectionStartInViewport.value, isTrue);

      await _longPressWord(
        tester,
        controller,
        line: _getFirstLineBelow(tester, controller, headerRect.top - 60),
      );
      expect(_getRenderEditor(tester).selectionStartInViewport.value, isTrue);
      // Moves the selected line under the header.
      outerScrollController.jumpTo(-100 - 80);
      await tester.pumpAndSettle();
      expect(
        headerRect.contains(
          _getCaretCenter(tester, controller.selection.start),
        ),
        isTrue,
      );
      expect(_getRenderEditor(tester).selectionStartInViewport.value, isFalse);
    },
  );

  testWidgets(
    'Selection handles hide when a pinned app bar starts to cover their line',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final (
        :controller,
        scrollController: _,
      ) = await _pumpEditorUnderSmallPinnedAppBar(
        tester,
        outerScrollController,
      );
      await _longPressWord(tester, controller, line: 0);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);

      // Moves the middle of the word 5 px under the bottom of the app bar. The
      // list has then scrolled by less than the height of the app bar.
      final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
      outerScrollController.jumpTo(
        _getCaretCenter(tester, controller.selection.start).dy -
            (appBarBottom - 5),
      );
      await tester.pumpAndSettle();
      expect(outerScrollController.offset, lessThan(appBarBottom));
      expect(
        _getCaretCenter(tester, controller.selection.start).dy,
        lessThan(appBarBottom),
      );

      expect(_getRenderEditor(tester).selectionStartInViewport.value, isFalse);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isFalse);
    },
  );

  testWidgets(
    'Selection handles hide when a pinned header in a SliverMainAxisGroup '
    'covers their line',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final (:controller, scrollController: _) = await _pumpEditorInSliverGroup(
        tester,
        outerScrollController,
      );
      await _longPressWord(
        tester,
        controller,
        line: _getFirstLineBelow(tester, controller, 300),
      );
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);

      // Moves the middle of the word 20 px into the header. The header stays at
      // the top of the screen.
      final headerHeight = tester
          .getRect(
            find.descendant(
              of: find.byType(SliverPersistentHeader),
              matching: find.byType(ColoredBox),
            ),
          )
          .height;
      outerScrollController.jumpTo(
        _getCaretCenter(tester, controller.selection.start).dy -
            (headerHeight - 20),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(
              find.descendant(
                of: find.byType(SliverPersistentHeader),
                matching: find.byType(ColoredBox),
              ),
            )
            .contains(_getCaretCenter(tester, controller.selection.start)),
        isTrue,
      );

      expect(_getRenderEditor(tester).selectionStartInViewport.value, isFalse);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isFalse);
    },
  );

  testWidgets(
    'Selection handles stay shown in an editor inside a pinned header below '
    'another pinned header',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final (:controller, scrollController: _) =
          await _pumpEditorInPinnedHeader(tester, outerScrollController);
      await _longPressWord(tester, controller, line: 0);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);

      // Both headers stay at the top of the screen. The word stays below the
      // app bar.
      outerScrollController.jumpTo(500);
      await tester.pumpAndSettle();
      expect(
        _getCaretCenter(tester, controller.selection.start).dy,
        greaterThan(tester.getRect(find.byType(AppBar)).bottom),
      );

      expect(_getRenderEditor(tester).selectionStartInViewport.value, isTrue);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);
    },
  );

  testWidgets(
    'Selection handles stay shown in a horizontal scroll view with a pinned '
    'header inside a vertical scroll view',
    (tester) async {
      final innerScrollController = ScrollController();
      addTearDown(innerScrollController.dispose);
      final (
        :controller,
        scrollController: _,
      ) = await _pumpEditorInHorizontalScrollView(
        tester,
        innerScrollController,
      );
      await _longPressWord(tester, controller, line: 0);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);

      // The horizontal scroll view moves under its header. The header then
      // covers the left part of the scroll view. The word is not in that part.
      innerScrollController.jumpTo(30);
      await tester.pumpAndSettle();
      expect(
        _getCaretCenter(tester, controller.selection.start).dx,
        greaterThan(
          tester
              .getRect(
                find.descendant(
                  of: find.byType(SliverPersistentHeader),
                  matching: find.byType(ColoredBox),
                ),
              )
              .right,
        ),
      );

      expect(_getRenderEditor(tester).selectionStartInViewport.value, isTrue);
      expect(_getSelectionHandleState(tester, isStart: true).isShown, isTrue);
    },
  );

  group('The menu of a caret stays until the caret or the text changes', () {
    testWidgets('when the editor updates its overlay without a change', (
      tester,
    ) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        const [
          {'insert': '\n'},
        ],
        placeholder: 'Start writing your notes',
      );
      await tester.longPressAt(_getCaretCenter(tester, 0));
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      // On a phone, the keyboard that appears after the long press makes the
      // editor update its overlay. A notification of the controller without a
      // change does the same.
      controller.updateSelection(controller.selection, ChangeSource.local);
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      controller.replaceText(
        0,
        0,
        'a',
        const TextSelection.collapsed(offset: 1),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    });

    testWidgets(
      'when a long press on an empty editor moves a little before it ends',
      (tester) async {
        await _pumpEditorWithMenu(tester, const [
          {'insert': '\n'},
        ], placeholder: 'Start writing your notes');
        // A point on the second word of the placeholder.
        final gesture = await tester.startGesture(
          _getCaretCenter(tester, 0) + const Offset(60, 0),
        );
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await gesture.moveBy(const Offset(2, 0));
        await tester.pump();
        // The last move comes in the same frame as the end of the long press.
        await gesture.moveBy(const Offset(2, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      },
    );
    testWidgets('and closes when a format is chosen for the next text', (
      tester,
    ) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(3),
      );
      final lineEnd = controller.document.toPlainText().indexOf('\n');
      // A point to the right of the end of the first line. A long press there
      // leaves only the caret.
      await tester.longPressAt(
        Offset(
          tester.getRect(find.byType(QuillEditor)).right - 30,
          _getCaretCenter(tester, lineEnd).dy,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      // What a format button of a toolbar does.
      controller.formatSelection(Attribute.bold);
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    });

    testWidgets('and moves with its caret when a line above it gets taller', (
      tester,
    ) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(3),
      );
      final lineEnd = controller.document.toPlainText().indexOf(
        '\n',
        _getLineStart(controller, 1),
      );
      // A point to the right of the end of the second line. A long press there
      // leaves only the caret.
      await tester.longPressAt(
        Offset(
          tester.getRect(find.byType(QuillEditor)).right - 30,
          _getCaretCenter(tester, lineEnd).dy,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        (controller.selection.isCollapsed, controller.selection.extentOffset),
        (true, lineEnd),
      );
      final menuRectBefore = _getMenuRect(tester);

      // A change from another user. It does not choose a style for the next
      // text.
      controller.compose(
        Delta()
          ..retain(controller.document.toPlainText().indexOf('\n'))
          ..retain(1, Attribute.h1.toJson()),
        controller.selection,
        ChangeSource.remote,
      );
      await tester.pumpAndSettle();
      final keptMenuRect = _getMenuRect(tester);
      // The menu as it is placed when it is shown again.
      tester.state<QuillRawEditorState>(find.byType(QuillRawEditor))
        ..hideToolbar(false)
        ..showToolbar();
      await tester.pumpAndSettle();

      expect(keptMenuRect, isNot(menuRectBefore));
      expect(keptMenuRect, _getMenuRect(tester));
    });
  });

  testWidgets('The menu moves with its text when the layout moves the editor', (
    tester,
  ) async {
    final isAppBarShown = ValueNotifier(true);
    addTearDown(isAppBarShown.dispose);
    final (
      :controller,
      scrollController: _,
    ) = await _pumpEditorBelowHidableAppBar(
      tester,
      _createLinesJson(30),
      isAppBarShown,
    );
    await _longPressWord(tester, controller, line: 4);
    final menuRectBefore = _getMenuRect(tester);
    final wordMiddleBefore = _getCaretCenter(
      tester,
      controller.selection.start,
    ).dy;

    // Hiding the app bar moves the editor up without any change of the
    // controller.
    isAppBarShown.value = false;
    await tester.pumpAndSettle();

    final wordShift =
        _getCaretCenter(tester, controller.selection.start).dy -
        wordMiddleBefore;
    expect(wordShift, lessThan(0));
    expect(
      _getMenuRect(tester).top,
      moreOrLessEquals(menuRectBefore.top + wordShift),
    );
  });

  testWidgets('The menu of a selection is placed at its text in an editor that '
      'a widget around it scales', (tester) async {
    final editorScale = ValueNotifier<double>(1);
    addTearDown(editorScale.dispose);
    final (:controller, :scrollController) = await _pumpScaledEditor(
      tester,
      editorScale,
    );
    Future<double> getGapBetweenMenuAndWord(int line) async {
      await _longPressWord(tester, controller, line: line);
      final renderEditor = _getRenderEditor(tester);
      final wordTop = renderEditor
          .localToGlobal(
            renderEditor
                .getLocalRectForCaret(
                  TextPosition(offset: controller.selection.start),
                )
                .topLeft,
          )
          .dy;
      final gap = wordTop - _getMenuRect(tester).bottom;
      controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();
      return gap;
    }

    final unscaledGap = await getGapBetweenMenuAndWord(8);

    editorScale.value = 0.75;
    await tester.pumpAndSettle();

    // Line 43 is in the lowest quarter of the visible part of the editor.
    for (final line in [8, 43]) {
      expect(
        await getGapBetweenMenuAndWord(line),
        moreOrLessEquals(unscaledGap),
        reason: 'line $line',
      );
    }

    // Line 58 is in the last quarter of the document. There, a position in the
    // editor is larger than the scaled height of the editor.
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(await getGapBetweenMenuAndWord(58), moreOrLessEquals(unscaledGap));
  });

  testWidgets(
    'The menu of a selection of several lines is placed at the middle '
    'of an editor that a widget around it scales',
    (tester) async {
      final editorScale = ValueNotifier<double>(0.75);
      addTearDown(editorScale.dispose);
      final (:controller, scrollController: _) = await _pumpScaledEditor(
        tester,
        editorScale,
      );
      controller.updateSelection(
        TextSelection(
          baseOffset: _getLineStart(controller, 4),
          extentOffset: _getLineStart(controller, 7),
        ),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();

      tester
          .state<QuillRawEditorState>(find.byType(QuillRawEditor))
          .showToolbar();
      await tester.pumpAndSettle();

      expect(
        _getMenuRect(tester).center.dx,
        moreOrLessEquals(
          tester.getRect(find.byType(QuillEditor)).center.dx,
          epsilon: 1,
        ),
      );
    },
  );

  testWidgets(
    'The buttons of the menu work near the bottom of an editor that a widget '
    'around it scales from its center',
    (tester) async {
      final (:controller, scrollController: _) = await _pumpEditor(
        tester,
        _createLinesJson(40),
        buildScreen: (editor) => Transform.scale(scale: 0.5, child: editor),
      );
      await _longPressWord(tester, controller, line: 29);

      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      expect(
        controller.selection,
        TextSelection(
          baseOffset: 0,
          extentOffset: controller.document.length - 1,
        ),
      );
    },
  );

  testWidgets(
    'The menu of a selection stays in a scroll view around the editor while '
    'only a small part of the editor is in view',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      // Without a Scaffold, a scroll view around the editor does not hide the
      // menu.
      final (:controller, scrollController: _) = await _pumpEditor(
        tester,
        _createLinesJson(10),
        config: const QuillEditorConfig(
          padding: EdgeInsets.all(16),
          scrollable: false,
        ),
        buildScreen: (editor) => Material(
          child: Column(
            children: [
              _toolbarRow,
              Expanded(
                child: SingleChildScrollView(
                  controller: outerScrollController,
                  child: Column(
                    children: [editor, const SizedBox(height: 3000)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await _longPressWord(tester, controller, line: 4);

      // Only 30 px of the editor stay in view.
      outerScrollController.jumpTo(_getRenderEditor(tester).size.height - 30);
      await tester.pumpAndSettle();

      expect(
        _getMenuRect(tester).top,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byWidget(_toolbarRow)).dy,
        ),
      );
    },
  );

  testWidgets(
    'The menu causes no error while a ListView keeps the editor alive out of '
    'view, and is shown again when the editor scrolls into view',
    (tester) async {
      final outerScrollController = ScrollController();
      addTearDown(outerScrollController.dispose);
      final (:controller, scrollController: _) = await _pumpEditor(
        tester,
        _createLinesJson(10),
        config: const QuillEditorConfig(
          padding: EdgeInsets.all(16),
          scrollable: false,
        ),
        buildScreen: (editor) => Scaffold(
          appBar: AppBar(title: const Text('Notes')),
          body: ListView(
            controller: outerScrollController,
            children: [
              editor,
              for (var item = 0; item < 30; item++) const SizedBox(height: 300),
            ],
          ),
        ),
      );
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _longPressWord(tester, controller, line: 4);
      } else {
        await _selectAndRightClickWord(tester, controller, line: 4);
      }
      final menuRectBefore = _getMenuRect(tester);

      // Far enough for the list to keep the editor only because it has focus.
      outerScrollController.jumpTo(5000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // A change of the selection there builds the menu again.
      final selection = controller.selection;
      controller.updateSelection(
        selection.copyWith(extentOffset: selection.extentOffset + 1),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      controller.updateSelection(selection, ChangeSource.local);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      outerScrollController.jumpTo(0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(_getMenuRect(tester), menuRectBefore);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.linux,
    }),
  );

  testWidgets('A context menu of the app that is placed with a Positioned '
      'widget is shown where the app places it', (tester) async {
    late Offset menuAnchor;
    final (:controller, scrollController: _) = await _pumpEditor(
      tester,
      _createLinesJson(30),
      config: QuillEditorConfig(
        padding: const EdgeInsets.all(16),
        contextMenuBuilder: (context, state) {
          menuAnchor = state.contextMenuAnchors.primaryAnchor;
          return Positioned(
            left: menuAnchor.dx,
            top: menuAnchor.dy,
            child: const Material(child: Text('Custom menu')),
          );
        },
      ),
      buildScreen: (editor) => Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        body: editor,
      ),
    );

    await _longPressWord(tester, controller, line: 4);

    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('Custom menu')), menuAnchor);
  });

  group('A context menu opened with a right click', () {
    testWidgets(
      'opens at the pointer, as in a TextField',
      (tester) async {
        // The place where the menu of a TextField opens, measured from the
        // pointer. The field first selects the same word in the same way.
        final textFieldController = TextEditingController(
          text: [
            for (var line = 1; line <= 30; line++)
              'Line $line alpha bravo charlie',
          ].join('\n'),
        );
        final textFieldFocusNode = FocusNode();
        addTearDown(textFieldController.dispose);
        addTearDown(textFieldFocusNode.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Notes')),
              body: TextField(
                controller: textFieldController,
                focusNode: textFieldFocusNode,
                maxLines: null,
                expands: true,
              ),
            ),
          ),
        );
        // With the caret at the start, the field does not scroll to its end
        // when it gets focus.
        textFieldController.selection = const TextSelection.collapsed(
          offset: 0,
        );
        textFieldFocusNode.requestFocus();
        await tester.pumpAndSettle();
        final renderEditable = tester
            .state<EditableTextState>(find.byType(EditableText))
            .renderEditable;
        Offset getTextFieldCaretCenter(int offset) =>
            renderEditable.localToGlobal(
              renderEditable
                  .getLocalRectForCaret(TextPosition(offset: offset))
                  .center,
            );
        final textFieldWordStart = textFieldController.text.indexOf(
          'bravo',
          textFieldController.text.indexOf('Line 5 '),
        );
        await _doubleClickAt(
          tester,
          getTextFieldCaretCenter(textFieldWordStart + 2),
        );
        final textFieldPointer = getTextFieldCaretCenter(
          textFieldWordStart + 1,
        );
        await _rightClickAt(tester, textFieldPointer);
        final textFieldMenuOffset =
            _getMenuRect(tester).topLeft - textFieldPointer;

        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(30),
        );
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: 4,
        );

        expect(
          (controller.selection.start, controller.selection.end),
          (wordStart, wordStart + 5),
        );
        expect(
          _getMenuRect(tester).topLeft - _getCaretCenter(tester, wordStart + 1),
          offsetMoreOrLessEquals(textFieldMenuOffset),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'opens again at the pointer while it is shown',
      (tester) async {
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(30),
        );
        final wordStart = _getWordStart(controller, line: 4);
        await _doubleClickAt(tester, _getCaretCenter(tester, wordStart + 2));
        final firstPointer = _getCaretCenter(tester, wordStart + 4);
        await _rightClickAt(tester, firstPointer);
        final menuOffset = _getMenuRect(tester).topLeft - firstPointer;

        // The menu spreads to the right of the pointer and down. A click to the
        // left of the first click is therefore on the text, not on the menu.
        final secondPointer = _getCaretCenter(tester, wordStart + 1);
        await _rightClickAt(tester, secondPointer);

        expect(
          (controller.selection.start, controller.selection.end),
          (wordStart, wordStart + 5),
        );
        expect(
          _getMenuRect(tester).topLeft - secondPointer,
          offsetMoreOrLessEquals(menuOffset),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays at the clicked text when the layout moves the editor and the '
      'menu is built again',
      (tester) async {
        final isAppBarShown = ValueNotifier(true);
        addTearDown(isAppBarShown.dispose);
        final (
          :controller,
          :scrollController,
        ) = await _pumpEditorBelowHidableAppBar(
          tester,
          _createLinesJson(60),
          isAppBarShown,
        );
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: 4,
        );
        final menuOffset =
            _getMenuRect(tester).topLeft -
            _getCaretCenter(tester, wordStart + 1);

        isAppBarShown.value = false;
        await tester.pumpAndSettle();
        // A scroll of the editor builds the menu again.
        scrollController.jumpTo(10);
        await tester.pumpAndSettle();

        expect(
          _getMenuRect(tester).topLeft - _getCaretCenter(tester, wordStart + 1),
          offsetMoreOrLessEquals(menuOffset),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays in the editor when the clicked text scrolls up out of view',
      (tester) async {
        final (:controller, :scrollController) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(60),
        );
        await _selectAndRightClickWord(tester, controller, line: 4);

        scrollController.jumpTo(300);
        await tester.pumpAndSettle();

        expect(
          _getMenuRect(tester).top,
          greaterThanOrEqualTo(tester.getRect(find.byType(QuillEditor)).top),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    for (final (name, isInListView) in [
      ('SingleChildScrollView', false),
      ('ListView', true),
    ]) {
      testWidgets(
        'stays in the editor when a $name around it scrolls the clicked text '
        'out of view',
        (tester) async {
          final outerScrollController = ScrollController();
          addTearDown(outerScrollController.dispose);
          final (:controller, scrollController: _) = await _pumpEditorWithMenu(
            tester,
            _createLinesJson(60),
            outerScrollController: outerScrollController,
            isInListView: isInListView,
          );
          await _selectAndRightClickWord(tester, controller, line: 4);

          final scrollView = find.byType(
            isInListView ? ListView : SingleChildScrollView,
          );
          final mouse = TestPointer(2, PointerDeviceKind.mouse);
          await tester.sendEventToBinding(
            mouse.hover(tester.getCenter(scrollView)),
          );
          await tester.sendEventToBinding(mouse.scroll(const Offset(0, 300)));
          await tester.pumpAndSettle();

          expect(outerScrollController.offset, 300);
          expect(
            _getMenuRect(tester).top,
            greaterThanOrEqualTo(tester.getTopLeft(scrollView).dy),
          );
        },
        variant: TargetPlatformVariant.desktop(),
      );
    }

    for (final (name, isInListView) in [
      ('SingleChildScrollView', false),
      ('ListView', true),
    ]) {
      testWidgets(
        'stays in a $name around the editor while only a small part of the '
        'editor is in view, and is not shown while no part of it is',
        (tester) async {
          final outerScrollController = ScrollController();
          addTearDown(outerScrollController.dispose);
          final (:controller, scrollController: _) = await _pumpEditor(
            tester,
            _createLinesJson(10),
            config: const QuillEditorConfig(
              padding: EdgeInsets.all(16),
              scrollable: false,
            ),
            buildScreen: (editor) => Scaffold(
              appBar: AppBar(title: const Text('Notes')),
              body: isInListView
                  ? ListView(
                      controller: outerScrollController,
                      children: [editor, const SizedBox(height: 3000)],
                    )
                  : SingleChildScrollView(
                      controller: outerScrollController,
                      child: Column(
                        children: [editor, const SizedBox(height: 3000)],
                      ),
                    ),
            ),
          );
          await _selectAndRightClickWord(tester, controller, line: 4);
          final menuRectBefore = _getMenuRect(tester);
          final scrollViewTop = tester.getTopLeft(find.byType(Scrollable)).dy;
          final editorHeight = _getRenderEditor(tester).size.height;

          // Only 30 px of the editor stay in view.
          outerScrollController.jumpTo(editorHeight - 30);
          await tester.pumpAndSettle();
          expect(
            _getMenuRect(tester).top,
            greaterThanOrEqualTo(scrollViewTop - 0.01),
          );

          outerScrollController.jumpTo(editorHeight + 100);
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

          outerScrollController.jumpTo(0);
          await tester.pumpAndSettle();
          expect(_getMenuRect(tester), menuRectBefore);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    }

    testWidgets(
      'stays in a ListView around an editor that scrolls itself when the '
      'ListView scrolls the clicked text out of view',
      (tester) async {
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final (:controller, scrollController: _) = await _pumpEditor(
          tester,
          _createLinesJson(60),
          buildScreen: (editor) => Scaffold(
            appBar: AppBar(title: const Text('Notes')),
            body: ListView(
              controller: outerScrollController,
              children: [
                SizedBox(height: 400, child: editor),
                const SizedBox(height: 600),
              ],
            ),
          ),
        );
        await _selectAndRightClickWord(tester, controller, line: 4);

        outerScrollController.jumpTo(300);
        await tester.pumpAndSettle();

        expect(
          _getMenuRect(tester).top,
          greaterThanOrEqualTo(
            tester.getTopLeft(find.byType(ListView)).dy - 0.01,
          ),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays below a pinned app bar that covers the clicked text',
      (tester) async {
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final (:controller, scrollController: _) =
            await _pumpEditorUnderPinnedAppBar(tester, outerScrollController);
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: 4,
        );

        // Scrolls the middle of the line to 30 px below the top of the screen.
        // There, the line is under the app bar. The app bar stays 56 px tall.
        outerScrollController.jumpTo(
          _getCaretCenter(tester, wordStart).dy - 30,
        );
        await tester.pumpAndSettle();
        final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
        expect(_getCaretCenter(tester, wordStart).dy, lessThan(appBarBottom));

        expect(
          _getMenuRect(tester).top,
          greaterThanOrEqualTo(appBarBottom - 0.01),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays below a pinned app bar that starts to cover the clicked text',
      (tester) async {
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final (
          :controller,
          scrollController: _,
        ) = await _pumpEditorUnderSmallPinnedAppBar(
          tester,
          outerScrollController,
        );
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: 0,
        );

        // Moves the middle of the word 5 px under the bottom of the app bar.
        // The list has then scrolled by less than the height of the app bar.
        final appBarBottom = tester.getRect(find.byType(AppBar)).bottom;
        outerScrollController.jumpTo(
          _getCaretCenter(tester, wordStart).dy - (appBarBottom - 5),
        );
        await tester.pumpAndSettle();
        expect(outerScrollController.offset, lessThan(appBarBottom));
        expect(_getCaretCenter(tester, wordStart).dy, lessThan(appBarBottom));

        expect(
          _getMenuRect(tester).top,
          greaterThanOrEqualTo(appBarBottom - 0.01),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays below a pinned header in a SliverMainAxisGroup that covers the '
      'clicked text',
      (tester) async {
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final (:controller, scrollController: _) =
            await _pumpEditorInSliverGroup(tester, outerScrollController);
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: _getFirstLineBelow(tester, controller, 300),
        );

        // Moves the middle of the word 20 px into the header. The header stays
        // at the top of the screen.
        final headerFinder = find.descendant(
          of: find.byType(SliverPersistentHeader),
          matching: find.byType(ColoredBox),
        );
        outerScrollController.jumpTo(
          _getCaretCenter(tester, wordStart).dy -
              (tester.getRect(headerFinder).height - 20),
        );
        await tester.pumpAndSettle();
        final headerRect = tester.getRect(headerFinder);
        expect(headerRect.contains(_getCaretCenter(tester, wordStart)), isTrue);

        expect(
          _getMenuRect(tester).top,
          greaterThanOrEqualTo(headerRect.bottom - 0.01),
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'opens at the pointer in an editor inside a pinned header below another '
      'pinned header',
      (tester) async {
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final (:controller, scrollController: _) =
            await _pumpEditorInPinnedHeader(tester, outerScrollController);
        Future<Offset> getMenuOffsetAfterRightClick() async {
          final wordStart = await _selectAndRightClickWord(
            tester,
            controller,
            line: 0,
          );
          return _getMenuRect(tester).topLeft -
              _getCaretCenter(tester, wordStart + 1);
        }

        final menuOffsetBeforeScroll = await getMenuOffsetAfterRightClick();
        // Both headers stay at the top of the screen.
        outerScrollController.jumpTo(500);
        await tester.pumpAndSettle();

        expect(await getMenuOffsetAfterRightClick(), menuOffsetBeforeScroll);
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'stays at the clicked text in a horizontal scroll view with a pinned '
      'header inside a vertical scroll view',
      (tester) async {
        final innerScrollController = ScrollController();
        addTearDown(innerScrollController.dispose);
        final (
          :controller,
          scrollController: _,
        ) = await _pumpEditorInHorizontalScrollView(
          tester,
          innerScrollController,
        );
        final wordStart = await _selectAndRightClickWord(
          tester,
          controller,
          line: 0,
        );
        final menuOffset =
            _getMenuRect(tester).topLeft -
            _getCaretCenter(tester, wordStart + 1);

        // The horizontal scroll view moves under its header. The header then
        // covers the left part of the scroll view. The word is not in that
        // part.
        innerScrollController.jumpTo(30);
        await tester.pumpAndSettle();

        expect(
          _getMenuRect(tester).topLeft - _getCaretCenter(tester, wordStart + 1),
          menuOffset,
        );
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets(
      'opens at the pointer in an editor that a widget around it scales',
      (tester) async {
        final editorScale = ValueNotifier<double>(1);
        addTearDown(editorScale.dispose);
        final (:controller, scrollController: _) = await _pumpScaledEditor(
          tester,
          editorScale,
        );
        Future<Offset> getMenuOffsetAfterRightClick(int line) async {
          final wordStart = await _selectAndRightClickWord(
            tester,
            controller,
            line: line,
          );
          return _getMenuRect(tester).topLeft -
              _getCaretCenter(tester, wordStart + 1);
        }

        final unscaledMenuOffset = await getMenuOffsetAfterRightClick(4);

        editorScale.value = 0.75;
        await tester.pumpAndSettle();

        // Line 43 is in the lowest quarter of the visible part of the editor.
        for (final line in [4, 43]) {
          expect(
            await getMenuOffsetAfterRightClick(line),
            offsetMoreOrLessEquals(unscaledMenuOffset, epsilon: 0.01),
            reason: 'line $line',
          );
        }
      },
      variant: TargetPlatformVariant.desktop(),
    );

    testWidgets('does not move the menu that a later long press opens', (
      tester,
    ) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(30),
      );
      await _longPressWord(tester, controller, line: 4);
      final menuRectBefore = _getMenuRect(tester);
      controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();

      await _rightClickAt(
        tester,
        _getCaretCenter(tester, _getLineStart(controller, 9) + 2),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();
      await _longPressWord(tester, controller, line: 4);

      expect(_getMenuRect(tester), menuRectBefore);
    });
  });

  group('A right click', () {
    testWidgets(
      'outside the selection selects the word under the pointer on macOS and '
      'iOS, as in a TextField',
      (tester) async {
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(30),
        );
        final selectedWordStart = _getWordStart(controller, line: 4);
        await _doubleClickAt(
          tester,
          _getCaretCenter(tester, selectedWordStart + 2),
        );
        final clickedWordStart = _getWordStart(
          controller,
          line: 9,
          word: 'alpha',
        );
        await _rightClickAt(
          tester,
          _getCaretCenter(tester, clickedWordStart + 2),
        );

        // On Windows and Linux, a TextField keeps the selection.
        final expectedWordStart = switch (defaultTargetPlatform) {
          TargetPlatform.macOS || TargetPlatform.iOS => clickedWordStart,
          _ => selectedWordStart,
        };
        expect(
          (controller.selection.start, controller.selection.end),
          (expectedWordStart, expectedWordStart + 5),
        );
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.iOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      }),
    );

    testWidgets(
      'with nothing selected selects the word under the pointer on macOS and '
      'iOS, as in a TextField',
      (tester) async {
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(30),
        );
        final wordStart = _getWordStart(controller, line: 4);

        await _rightClickAt(tester, _getCaretCenter(tester, wordStart + 2));

        expect(
          (controller.selection.start, controller.selection.end),
          (wordStart, wordStart + 5),
        );
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.macOS,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'causes no error when the editor is removed in the same frame',
      (tester) async {
        final isEditorShown = ValueNotifier(true);
        addTearDown(isEditorShown.dispose);
        await _pumpEditor(
          tester,
          _createLinesJson(3),
          buildScreen: (editor) => Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: isEditorShown,
              builder: (context, isShown, child) =>
                  isShown ? child! : const SizedBox(),
              child: editor,
            ),
          ),
        );

        final gesture = await tester.startGesture(
          _getCaretCenter(tester, 2),
          buttons: kSecondaryMouseButton,
          kind: PointerDeviceKind.mouse,
        );
        await gesture.up();
        isEditorShown.value = false;
        await tester.pump(kDoubleTapTimeout);

        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.desktop(),
    );
  });

  group('A long press on an empty editor', () {
    testWidgets('keeps the style chosen for the next text', (tester) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        const [
          {'insert': '\n'},
        ],
        placeholder: 'Start writing your notes',
      );
      controller.formatSelection(Attribute.bold);
      expect(controller.toggledStyle.containsKey(Attribute.bold.key), isTrue);

      await tester.longPressAt(
        _getCaretCenter(tester, 0) + const Offset(60, 0),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      expect(controller.toggledStyle.containsKey(Attribute.bold.key), isTrue);
    });
  });

  group('The menu below a selection does not cover its handles', () {
    // A status bar and no app bar. The menu therefore has no room above the
    // first line and is placed below it.
    void setUpStatusBar(WidgetTester tester) {
      tester.view.padding = FakeViewPadding(
        top: 24 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetPadding);
    }

    for (final (lineCount, textScaleFactor) in [(1, 2.3), (2, 1.0), (3, 1.0)]) {
      testWidgets('when the text has $lineCount line(s) at a text scale of '
          '$textScaleFactor', (tester) async {
        setUpStatusBar(tester);
        tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(lineCount),
          withAppBar: false,
          isBarBelow: true,
        );
        await _longPressWord(tester, controller, line: 0);

        final menuRect = _getMenuRect(tester);
        for (final isStart in [true, false]) {
          final handleRect = _getSelectionHandleState(
            tester,
            isStart: isStart,
          ).drawnRect;
          expect(menuRect.top, greaterThan(handleRect.top));
          // Flutter places the menu 20 px below the line. A handle is 22 px
          // tall. The two therefore overlap by 2 px.
          expect(
            menuRect.top,
            greaterThanOrEqualTo(handleRect.bottom - 2 - 0.01),
          );
        }
      });
    }

    testWidgets('and the menu stays in the editor after Select all', (
      tester,
    ) async {
      setUpStatusBar(tester);
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
        withAppBar: false,
        isBarBelow: true,
      );
      await _longPressWord(tester, controller, line: 0);
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();

      expect(
        controller.selection,
        TextSelection(
          baseOffset: 0,
          extentOffset: controller.document.length - 1,
        ),
      );
      final editorRect = tester.getRect(find.byType(QuillEditor));
      final menuRect = _getMenuRect(tester);
      expect(menuRect.top, greaterThanOrEqualTo(editorRect.top));
      expect(menuRect.bottom, lessThanOrEqualTo(editorRect.bottom));
    });
  });

  group('The menu hides while the editor scrolls', () {
    testWidgets(
      'and is shown again when the scroll ends with the selection in view',
      (tester) async {
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(100),
        );
        await _longPressWord(tester, controller, line: 5);
        expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(QuillEditor)),
        );
        await gesture.moveBy(const Offset(0, -20));
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
        expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

        await gesture.up();
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      },
    );

    testWidgets(
      'and is shown again when a later scroll brings the selection into view',
      (tester) async {
        final (:controller, :scrollController) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(100),
        );
        await _longPressWord(tester, controller, line: 5);
        expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

        scrollController.jumpTo(1000);
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

        scrollController.jumpTo(0);
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
      },
    );

    testWidgets('and is shown again for a caret', (tester) async {
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      final lineEnd = controller.document.toPlainText().indexOf('\n');
      // A point to the right of the end of the first line. A long press there
      // leaves only the caret.
      await tester.longPressAt(
        Offset(
          tester.getRect(find.byType(QuillEditor)).right - 30,
          _getCaretCenter(tester, lineEnd).dy,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        (controller.selection.isCollapsed, controller.selection.extentOffset),
        (true, lineEnd),
      );
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      scrollController.jumpTo(10);
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    });

    testWidgets('but not while a scroll view inside an embed scrolls', (
      tester,
    ) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        const [
          {'insert': 'Line 1 alpha bravo charlie\n'},
          {
            'insert': {_ScrollingEmbedBuilder.embedKey: ''},
          },
          {'insert': '\nLine 3 alpha bravo charlie\n'},
        ],
        embedBuilders: [_ScrollingEmbedBuilder()],
      );
      await _longPressWord(tester, controller, line: 0);
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(_ScrollingEmbed)),
      );
      await gesture.moveBy(const Offset(-30, 0));
      await gesture.moveBy(const Offset(-30, 0));
      await tester.pump();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    });

    testWidgets('and is not shown again after the selection changes', (
      tester,
    ) async {
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      await _longPressWord(tester, controller, line: 5);
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

      scrollController.jumpTo(1000);
      await tester.pumpAndSettle();
      controller.updateSelection(
        TextSelection(
          baseOffset: controller.selection.start,
          extentOffset: controller.selection.end + 1,
        ),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();
      scrollController.jumpTo(0);
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    });

    // A change that makes the editor scroll closes the menu. An example is a
    // paste near the bottom of the editor. The scroll must not show the menu
    // again.
    const platforms = TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    });

    testWidgets('and is not shown again after Cut', (tester) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      await _selectWord(tester, controller, line: 5);
      await tester.tap(find.text(_getSelectAllLabel()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cut'));
      await tester.pumpAndSettle();

      expect(controller.document.toPlainText(), '\n');
      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    }, variant: platforms);

    testWidgets('and is not shown again after Paste', (tester) async {
      _setUpPlainTextClipboard(
        tester,
        [for (var line = 1; line <= 8; line++) 'Pasted $line'].join('\n'),
      );
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      await _openCaretMenuNearBottom(tester, controller);

      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();

      expect(controller.document.toPlainText(), contains('Pasted 8'));
      expect(scrollController.offset, greaterThan(0));
      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    }, variant: platforms);

    testWidgets('and is not shown again after typing', (tester) async {
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      final caretOffset = await _openCaretMenuNearBottom(tester, controller);

      // The keyboard adds three new lines at the caret.
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: controller.document.toPlainText().replaceRange(
            caretOffset,
            caretOffset,
            '\n\n\n',
          ),
          selection: TextSelection.collapsed(offset: caretOffset + 3),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.selection.extentOffset, caretOffset + 3);
      expect(scrollController.offset, greaterThan(0));
      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    }, variant: platforms);

    testWidgets(
      'and is not shown again after a format is chosen for the next text',
      (tester) async {
        final (:controller, :scrollController) = await _pumpEditorWithMenu(
          tester,
          _createLinesJson(100),
        );
        await _openCaretMenuNearBottom(tester, controller, margin: 20);

        // This is what the heading button of the toolbar does. The heading
        // makes the line taller. The editor then scrolls to show the caret.
        controller.formatSelection(Attribute.h1);
        await tester.pumpAndSettle();

        expect(scrollController.offset, greaterThan(0));
        expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
      },
      variant: platforms,
    );

    testWidgets('and is not shown again after Escape', (tester) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      await _selectWord(tester, controller, line: 5);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(QuillEditor)),
      );
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);
    }, variant: platforms);

    testWidgets('and is shown after Select all', (tester) async {
      final (:controller, :scrollController) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(100),
      );
      scrollController.jumpTo(600);
      await tester.pumpAndSettle();
      await _selectWord(
        tester,
        controller,
        line: _getFirstLineBelow(
          tester,
          controller,
          tester.getCenter(find.byType(QuillEditor)).dy,
        ),
      );

      // Select all scrolls the editor to the start of the document.
      await tester.tap(find.text(_getSelectAllLabel()));
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0);
      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    }, variant: platforms);
  });

  group('The menu hides while a scroll view around the editor scrolls', () {
    for (final isListView in [false, true]) {
      final scrollViewName = isListView ? 'ListView' : 'SingleChildScrollView';

      testWidgets(
        'and is shown again when the scroll of a $scrollViewName ends with '
        'the selection in view',
        (tester) async {
          final outerScrollController = ScrollController();
          addTearDown(outerScrollController.dispose);
          final (:controller, scrollController: _) = await _pumpEditorWithMenu(
            tester,
            _createLinesJson(100),
            outerScrollController: outerScrollController,
            isInListView: isListView,
          );
          await _longPressWord(tester, controller, line: 5);
          expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

          final gesture = await tester.startGesture(
            tester.getCenter(find.byType(Scrollable)),
          );
          await gesture.moveBy(const Offset(0, -20));
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump();
          expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

          await gesture.up();
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
        },
      );

      testWidgets(
        'and is shown again when a later scroll of a $scrollViewName brings '
        'the selection into view',
        (tester) async {
          final outerScrollController = ScrollController();
          addTearDown(outerScrollController.dispose);
          final (:controller, scrollController: _) = await _pumpEditorWithMenu(
            tester,
            _createLinesJson(100),
            outerScrollController: outerScrollController,
            isInListView: isListView,
          );
          await _longPressWord(tester, controller, line: 5);
          expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);

          outerScrollController.jumpTo(1000);
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveTextSelectionToolbar), findsNothing);

          outerScrollController.jumpTo(0);
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
        },
      );
    }
  });

  group('Cut and Copy with nothing selected', () {
    testWidgets('are not in the menu', (tester) async {
      await _pumpEditorWithMenu(tester, const [
        {'insert': '\n'},
      ]);
      await tester.longPressAt(_getCaretCenter(tester, 0));
      await tester.pumpAndSettle();

      expect(find.text('Select all'), findsOneWidget);
      expect(find.text('Cut'), findsNothing);
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('are in the menu of a selected word', (tester) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        _createLinesJson(3),
      );
      await _longPressWord(tester, controller, line: 1);

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    for (final isCopy in [true, false]) {
      testWidgets(
        'keep the clipboard and the copied content (${isCopy ? 'Copy' : 'Cut'})',
        (tester) async {
          String? clipboardText;
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async {
              if (call.method == 'Clipboard.setData') {
                clipboardText = (call.arguments as Map)['text'] as String?;
              }
              return null;
            },
          );
          addTearDown(
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(SystemChannels.platform, null),
          );
          final controller = QuillController(
            document: Document.fromJson(const [
              {'insert': 'Plain '},
              {
                'insert': 'bold',
                'attributes': {'bold': true},
              },
              {'insert': ' text\n'},
            ]),
            selection: const TextSelection(baseOffset: 4, extentOffset: 8),
          );
          addTearDown(controller.dispose);
          expect(controller.clipboardSelection(true), isTrue);
          expect(clipboardText, 'n bo');
          final copiedDelta = controller.pasteDelta;

          controller.updateSelection(
            const TextSelection.collapsed(offset: 2),
            ChangeSource.local,
          );
          expect(controller.clipboardSelection(isCopy), isFalse);

          expect(clipboardText, 'n bo');
          expect(controller.pastePlainText, 'n bo');
          expect(controller.pasteDelta, copiedDelta);
          expect(controller.document.toPlainText(), 'Plain bold text\n');
        },
      );
    }
  });

  group('Home and End on a line with text in both directions', () {
    const platforms = TargetPlatformVariant({
      TargetPlatform.linux,
      TargetPlatform.windows,
    });

    for (final (name, lineText, lineAttributes) in [
      ('left-to-right line', 'abc defg אבגד הוזח', <String, Object>{}),
      (
        'right-to-left line',
        'אבגד הוזח abc defg',
        <String, Object>{'direction': 'rtl'},
      ),
      (
        'line with one direction only',
        'abc defg hijk lmno',
        <String, Object>{},
      ),
    ]) {
      testWidgets('move the caret to the ends of a $name', (tester) async {
        final (:controller, scrollController: _) = await _pumpEditorWithMenu(
          tester,
          [
            {'insert': lineText},
            {
              'insert': '\n',
              if (lineAttributes.isNotEmpty) 'attributes': lineAttributes,
            },
            {'insert': 'Next line\n'},
          ],
        );
        for (final caretOffset in [0, 2, 12, 16]) {
          for (final (key, expectedOffset) in [
            (LogicalKeyboardKey.end, lineText.length),
            (LogicalKeyboardKey.home, 0),
          ]) {
            controller.updateSelection(
              TextSelection.collapsed(offset: caretOffset),
              ChangeSource.local,
            );
            await tester.pumpAndSettle();
            await tester.sendKeyEvent(key);
            await tester.pumpAndSettle();
            expect(
              controller.selection.isCollapsed,
              isTrue,
              reason: '$key from $caretOffset',
            );
            expect(
              controller.selection.extentOffset,
              expectedOffset,
              reason: '$key from $caretOffset',
            );
          }
        }
        expect(
          _getRenderEditor(
            tester,
          ).selectLineAtPosition(const TextPosition(offset: 2)),
          TextSelection(baseOffset: 0, extentOffset: lineText.length),
        );
      }, variant: platforms);
    }

    testWidgets('move the caret to the ends of each part of a line that '
        'wraps', (tester) async {
      // An editor narrow enough for the line to wrap inside its right-to-left
      // text.
      tester.view.physicalSize = Size(
        260 * tester.view.devicePixelRatio,
        600 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetPhysicalSize);
      const lineText = 'abc defg אבגד הוזח';
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        const [
          {'insert': '$lineText\n'},
        ],
      );
      // The ends of each part of the line after the text engine wraps it.
      final paragraph = tester.renderObject<RenderParagraph>(
        find
            .descendant(
              of: find.byType(QuillEditor),
              matching: find.byType(RichText),
            )
            .first,
      );
      final painter = TextPainter(
        text: paragraph.text,
        textAlign: paragraph.textAlign,
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
        locale: paragraph.locale,
        strutStyle: paragraph.strutStyle,
        textWidthBasis: paragraph.textWidthBasis,
        textHeightBehavior: paragraph.textHeightBehavior,
      )..layout(maxWidth: paragraph.constraints.maxWidth);
      addTearDown(painter.dispose);
      expect(painter.computeLineMetrics(), hasLength(2));

      for (var caretOffset = 0; caretOffset <= lineText.length; caretOffset++) {
        final lineRange = painter.getLineBoundary(
          TextPosition(offset: caretOffset),
        );
        for (final (key, expectedOffset) in [
          (LogicalKeyboardKey.end, lineRange.end),
          (LogicalKeyboardKey.home, lineRange.start),
        ]) {
          controller.updateSelection(
            TextSelection.collapsed(offset: caretOffset),
            ChangeSource.local,
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(key);
          await tester.pumpAndSettle();
          expect(
            controller.selection.extentOffset,
            expectedOffset,
            reason: '$key from $caretOffset',
          );
        }
      }
    }, variant: platforms);

    testWidgets('do not move the caret on an empty line', (tester) async {
      final (:controller, scrollController: _) = await _pumpEditorWithMenu(
        tester,
        const [
          {'insert': 'First line\n\nThird line\n'},
        ],
      );
      for (final key in [LogicalKeyboardKey.end, LogicalKeyboardKey.home]) {
        controller.updateSelection(
          const TextSelection.collapsed(offset: 11),
          ChangeSource.local,
        );
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          (controller.selection.isCollapsed, controller.selection.extentOffset),
          (true, 11),
        );
      }
    }, variant: platforms);
  });
}

/// A bar as tall as a row of the toolbar.
const _toolbarRow = SizedBox(
  height: 48,
  width: double.infinity,
  child: ColoredBox(color: Colors.blue),
);

/// Creates a document of [lineCount] lines of the same short text.
List<Map<String, Object>> _createLinesJson(int lineCount) => [
  {
    'insert':
        '${[for (var line = 1; line <= lineCount; line++) 'Line $line alpha bravo charlie'].join('\n')}\n',
  },
];

/// Builds and shows an editor with the default context menu, as in the example
/// app. The editor is below an app bar and next to a bar as tall as a toolbar
/// row.
///
/// With [outerScrollController], the editor does not scroll itself. It is then
/// in a [ListView] when [isInListView] is true, and in a
/// [SingleChildScrollView] otherwise. [onBarTap] is called when the bar is
/// tapped.
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorWithMenu(
  WidgetTester tester,
  List<Map<String, Object>> documentJson, {
  bool withAppBar = true,
  bool isBarBelow = false,
  ScrollController? outerScrollController,
  bool isInListView = false,
  String? placeholder,
  VoidCallback? onBarTap,
  List<EmbedBuilder> embedBuilders = const [],
}) {
  final bar = GestureDetector(onTap: onBarTap, child: _toolbarRow);
  return _pumpEditor(
    tester,
    documentJson,
    config: QuillEditorConfig(
      padding: const EdgeInsets.all(16),
      scrollable: outerScrollController == null,
      placeholder: placeholder,
      embedBuilders: embedBuilders,
    ),
    buildScreen: (editor) => Scaffold(
      appBar: withAppBar ? AppBar(title: const Text('Notes')) : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!isBarBelow) bar,
            Expanded(
              child: outerScrollController == null
                  ? editor
                  : isInListView
                  ? ListView(
                      controller: outerScrollController,
                      children: [editor],
                    )
                  : SingleChildScrollView(
                      controller: outerScrollController,
                      child: editor,
                    ),
            ),
            if (isBarBelow) bar,
          ],
        ),
      ),
    ),
  );
}

/// Builds and shows an editor of 60 lines below a pinned app bar. The editor
/// does not scroll itself. It is inside a scroll view that uses
/// [outerScrollController].
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorUnderPinnedAppBar(
  WidgetTester tester,
  ScrollController outerScrollController,
) => _pumpEditor(
  tester,
  _createLinesJson(60),
  config: const QuillEditorConfig(
    padding: EdgeInsets.all(16),
    scrollable: false,
  ),
  buildScreen: (editor) => Scaffold(
    body: CustomScrollView(
      controller: outerScrollController,
      slivers: [
        const SliverAppBar(
          pinned: true,
          expandedHeight: 150,
          title: Text('Notes'),
        ),
        SliverToBoxAdapter(child: editor),
      ],
    ),
  ),
);

/// Builds and shows an editor of 60 lines below a pinned app bar of the
/// smallest height. The editor does not scroll itself. It is inside a scroll
/// view that uses [outerScrollController].
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorUnderSmallPinnedAppBar(
  WidgetTester tester,
  ScrollController outerScrollController,
) => _pumpEditor(
  tester,
  _createLinesJson(60),
  config: const QuillEditorConfig(
    padding: EdgeInsets.all(16),
    scrollable: false,
  ),
  buildScreen: (editor) => Scaffold(
    body: CustomScrollView(
      controller: outerScrollController,
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Notes')),
        SliverToBoxAdapter(child: editor),
      ],
    ),
  ),
);

/// Builds and shows an editor of 60 lines below a pinned header. Both are in a
/// [SliverMainAxisGroup]. The editor does not scroll itself. It is inside a
/// scroll view that uses [outerScrollController].
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorInSliverGroup(
  WidgetTester tester,
  ScrollController outerScrollController,
) => _pumpEditor(
  tester,
  _createLinesJson(60),
  config: const QuillEditorConfig(
    padding: EdgeInsets.all(16),
    scrollable: false,
  ),
  buildScreen: (editor) => Scaffold(
    body: CustomScrollView(
      controller: outerScrollController,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(),
            ),
            SliverToBoxAdapter(child: editor),
          ],
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 2000)),
      ],
    ),
  ),
);

/// Builds and shows an editor of 2 lines in a pinned header below a pinned app
/// bar. The editor does not scroll itself. It is inside a scroll view that uses
/// [outerScrollController].
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorInPinnedHeader(
  WidgetTester tester,
  ScrollController outerScrollController,
) => _pumpEditor(
  tester,
  _createLinesJson(2),
  config: const QuillEditorConfig(
    padding: EdgeInsets.all(16),
    scrollable: false,
  ),
  buildScreen: (editor) => Scaffold(
    body: CustomScrollView(
      controller: outerScrollController,
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Notes')),
        SliverPersistentHeader(
          pinned: true,
          delegate: _EditorHeaderDelegate(editor),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 2000)),
      ],
    ),
  ),
);

/// Builds and shows an editor of 6 lines after a header in a horizontal scroll
/// view. The header is pinned at the left. The horizontal scroll view uses
/// [innerScrollController] and is inside a vertical scroll view. The editor
/// does not scroll itself.
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorInHorizontalScrollView(
  WidgetTester tester,
  ScrollController innerScrollController,
) => _pumpEditor(
  tester,
  _createLinesJson(6),
  config: const QuillEditorConfig(
    padding: EdgeInsets.all(16),
    scrollable: false,
  ),
  buildScreen: (editor) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 400,
            child: CustomScrollView(
              controller: innerScrollController,
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedHeaderDelegate(),
                ),
                SliverToBoxAdapter(child: SizedBox(width: 600, child: editor)),
                const SliverToBoxAdapter(child: SizedBox(width: 2000)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 2000)),
      ],
    ),
  ),
);

/// Builds and shows an editor below an app bar that is shown while
/// [isAppBarShown] is true. A test can then move the editor without any change
/// of its controller.
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditorBelowHidableAppBar(
  WidgetTester tester,
  List<Map<String, Object>> documentJson,
  ValueNotifier<bool> isAppBarShown,
) => _pumpEditor(
  tester,
  documentJson,
  buildScreen: (editor) => ValueListenableBuilder<bool>(
    valueListenable: isAppBarShown,
    builder: (context, isShown, child) => Scaffold(
      appBar: isShown ? AppBar(title: const Text('Notes')) : null,
      body: child,
    ),
    child: editor,
  ),
);

/// Builds and shows an editor of 60 lines that a widget scales by [editorScale]
/// from its top-left corner. The view is tall enough for each tested menu to
/// fit where it is placed.
Future<({QuillController controller, ScrollController scrollController})>
_pumpScaledEditor(WidgetTester tester, ValueNotifier<double> editorScale) {
  tester.view.physicalSize = Size(
    800 * tester.view.devicePixelRatio,
    1000 * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.resetPhysicalSize);
  return _pumpEditor(
    tester,
    _createLinesJson(60),
    buildScreen: (editor) => ValueListenableBuilder<double>(
      valueListenable: editorScale,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: child,
      ),
      child: editor,
    ),
  );
}

/// Builds and shows an editor with the default context menu and gives it focus.
/// [buildScreen] places widgets around the editor.
Future<({QuillController controller, ScrollController scrollController})>
_pumpEditor(
  WidgetTester tester,
  List<Map<String, Object>> documentJson, {
  required Widget Function(Widget editor) buildScreen,
  QuillEditorConfig config = const QuillEditorConfig(
    padding: EdgeInsets.all(16),
  ),
}) async {
  final controller = QuillController(
    document: Document.fromJson(documentJson),
    selection: const TextSelection.collapsed(offset: 0),
  );
  final focusNode = FocusNode();
  final scrollController = ScrollController();
  addTearDown(controller.dispose);
  addTearDown(focusNode.dispose);
  addTearDown(scrollController.dispose);
  await tester.pumpWidget(
    QuillTestApp.home(
      buildScreen(
        QuillEditor(
          controller: controller,
          focusNode: focusNode,
          scrollController: scrollController,
          config: config,
        ),
      ),
    ),
  );
  focusNode.requestFocus();
  await tester.pumpAndSettle();
  return (controller: controller, scrollController: scrollController);
}

RenderEditor _getRenderEditor(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byType(QuillEditor))
    .editableTextKey
    .currentState!
    .renderEditor;

/// Returns the middle of the caret at [offset], in global coordinates.
///
/// The x comes from a collapsed selection. `RenderEditor.getLocalRectForCaret`
/// ignores the line's horizontal offset.
Offset _getCaretCenter(WidgetTester tester, int offset) {
  final renderEditor = _getRenderEditor(tester);
  final position = TextPosition(offset: offset);
  return renderEditor.localToGlobal(
    Offset(
      renderEditor
          .getEndpointsForSelection(TextSelection.fromPosition(position))
          .first
          .point
          .dx,
      renderEditor.getLocalRectForCaret(position).center.dy,
    ),
  );
}

int _getLineStart(QuillController controller, int line) {
  final text = controller.document.toPlainText();
  return [0, for (final newline in '\n'.allMatches(text)) newline.end][line];
}

/// Returns the offset at which [word] first occurs on [line] or after it.
int _getWordStart(
  QuillController controller, {
  required int line,
  String word = 'bravo',
}) => controller.document.toPlainText().indexOf(
  word,
  _getLineStart(controller, line),
);

/// Returns the first line whose middle is not above [y], in global
/// coordinates.
int _getFirstLineBelow(
  WidgetTester tester,
  QuillController controller,
  double y,
) {
  var line = 0;
  while (_getCaretCenter(tester, _getLineStart(controller, line)).dy < y) {
    line++;
  }
  return line;
}

/// Selects [word] on [line] with a long press.
Future<void> _longPressWord(
  WidgetTester tester,
  QuillController controller, {
  required int line,
  String word = 'bravo',
}) async {
  final wordStart = _getWordStart(controller, line: line, word: word);
  await tester.longPressAt(
    _getCaretCenter(tester, wordStart + word.length ~/ 2),
  );
  await tester.pumpAndSettle();
  expect(
    (controller.selection.start, controller.selection.end),
    (wordStart, wordStart + word.length),
  );
}

/// Selects [word] on [line] as a user does. On Android, a long press selects
/// it. On iOS, a double tap selects it, because a long press there only places
/// the caret.
Future<void> _selectWord(
  WidgetTester tester,
  QuillController controller, {
  required int line,
  String word = 'bravo',
}) async {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    await _longPressWord(tester, controller, line: line, word: word);
    return;
  }
  final wordStart = _getWordStart(controller, line: line, word: word);
  final wordMiddle = _getCaretCenter(tester, wordStart + word.length ~/ 2);
  await tester.tapAt(wordMiddle);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tapAt(wordMiddle);
  await tester.pumpAndSettle();
  expect(
    (controller.selection.start, controller.selection.end),
    (wordStart, wordStart + word.length),
  );
}

/// Returns three values for the start or end selection handle: its opacity, the
/// rectangle in which it is drawn and whether it is shown at all. The rectangle
/// is in global coordinates.
({double opacity, Rect drawnRect, bool isShown}) _getSelectionHandleState(
  WidgetTester tester, {
  required bool isStart,
}) {
  final handles = find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString() == '_TextSelectionHandleOverlay',
  );
  expect(handles, findsNWidgets(2));
  final handle = handles.at(isStart ? 0 : 1);
  return (
    opacity: tester
        .widget<FadeTransition>(
          find.descendant(of: handle, matching: find.byType(FadeTransition)),
        )
        .opacity
        .value,
    drawnRect: tester.getRect(
      find.descendant(of: handle, matching: find.byType(CustomPaint)).first,
    ),
    // A handle is shown only while the editor paints the layer that it
    // follows.
    isShown:
        tester
            .renderObject<RenderFollowerLayer>(
              find.descendant(
                of: handle,
                matching: find.byType(CompositedTransformFollower),
              ),
            )
            .link
            .leader !=
        null,
  );
}

/// Returns the rectangle that holds the buttons of the context menu, in global
/// coordinates.
Rect _getMenuRect(WidgetTester tester) {
  final buttons = find.byWidgetPredicate(
    (widget) =>
        widget is TextSelectionToolbarTextButton ||
        widget is CupertinoTextSelectionToolbarButton ||
        widget is DesktopTextSelectionToolbarButton ||
        widget is CupertinoDesktopTextSelectionToolbarButton,
  );
  expect(buttons, findsWidgets);
  return [
    for (final button in buttons.evaluate())
      tester.getRect(find.byWidget(button.widget)),
  ].reduce((rect, other) => rect.expandToInclude(other));
}

/// Double-clicks at [position] with a mouse. It then waits until a later click
/// can no longer be part of the double click.
Future<void> _doubleClickAt(WidgetTester tester, Offset position) async {
  await tester.tapAt(position, kind: PointerDeviceKind.mouse);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tapAt(position, kind: PointerDeviceKind.mouse);
  await tester.pump(kDoubleTapTimeout);
  await tester.pumpAndSettle();
}

/// Clicks at [position] with the secondary mouse button, as a right click. It
/// then waits until a later click can no longer be part of a double click.
Future<void> _rightClickAt(WidgetTester tester, Offset position) async {
  await tester.tapAt(
    position,
    buttons: kSecondaryMouseButton,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump(kDoubleTapTimeout);
  await tester.pumpAndSettle();
}

/// Selects "bravo" on [line] with a double click. It then right-clicks the word
/// after its first character. Returns the offset at which the word starts.
Future<int> _selectAndRightClickWord(
  WidgetTester tester,
  QuillController controller, {
  required int line,
}) async {
  final wordStart = _getWordStart(controller, line: line);
  await _doubleClickAt(tester, _getCaretCenter(tester, wordStart + 2));
  await _rightClickAt(tester, _getCaretCenter(tester, wordStart + 1));
  return wordStart;
}

/// Opens the menu of a caret with a long press and returns the offset of the
/// caret. The long press is to the right of the last line whose middle is at
/// least [margin] above the bottom of the editor.
Future<int> _openCaretMenuNearBottom(
  WidgetTester tester,
  QuillController controller, {
  double margin = 40,
}) async {
  final editorRect = tester.getRect(find.byType(QuillEditor));
  final line =
      _getFirstLineBelow(tester, controller, editorRect.bottom - margin) - 1;
  final lineEnd = _getLineStart(controller, line + 1) - 1;
  await tester.longPressAt(
    Offset(editorRect.right - 30, _getCaretCenter(tester, lineEnd).dy),
  );
  await tester.pumpAndSettle();
  expect(
    (controller.selection.isCollapsed, controller.selection.extentOffset),
    (true, lineEnd),
  );
  expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
  return lineEnd;
}

/// Returns the label of the Select all button of the default context menu.
String _getSelectAllLabel() =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'Select All' : 'Select all';

/// Makes the system clipboard hold [text] and no rich content until the end
/// of the test.
void _setUpPlainTextClipboard(WidgetTester tester, String text) {
  ClipboardServiceProvider.setInstance(_PlainTextClipboardService());
  addTearDown(ClipboardServiceProvider.setInstanceToDefault);
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => switch (call.method) {
      'Clipboard.getData' => {'text': text},
      'Clipboard.hasStrings' => {'value': true},
      _ => null,
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

/// A clipboard service without rich content. A paste then uses the plain text
/// of the system clipboard.
class _PlainTextClipboardService extends ClipboardService {
  @override
  Future<String?> getHtmlText() async => null;

  @override
  Future<String?> getHtmlFile() async => null;

  @override
  Future<String?> getMarkdownFile() async => null;

  @override
  Future<Uint8List?> getImageFile() async => null;

  @override
  Future<Uint8List?> getGifFile() async => null;

  @override
  Future<void> copyImage(Uint8List imageBytes) async {}
}

/// A header of 80 px that stays in view when it is pinned.
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 80;

  @override
  double get maxExtent => 80;

  @override
  bool shouldRebuild(_PinnedHeaderDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => const SizedBox.expand(child: ColoredBox(color: Colors.blue));
}

/// A header of 120 px that holds [editor] and stays in view when it is pinned.
class _EditorHeaderDelegate extends SliverPersistentHeaderDelegate {
  _EditorHeaderDelegate(this.editor);

  final Widget editor;

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  bool shouldRebuild(_EditorHeaderDelegate oldDelegate) =>
      editor != oldDelegate.editor;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(
    child: ColoredBox(color: Colors.white, child: editor),
  );
}

/// A block embed that holds a horizontal list with its own scroll view.
class _ScrollingEmbedBuilder extends EmbedBuilder {
  static const embedKey = 'scrolling';

  @override
  String get key => embedKey;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const _ScrollingEmbed();
}

class _ScrollingEmbed extends StatelessWidget {
  const _ScrollingEmbed();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var item = 0; item < 30; item++)
            SizedBox(
              width: 50,
              child: ColoredBox(color: item.isEven ? Colors.red : Colors.green),
            ),
        ],
      ),
    );
  }
}

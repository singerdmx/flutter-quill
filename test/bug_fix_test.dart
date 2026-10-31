import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  group('The editor can be removed before its context menu is shown', () {
    Future<Offset> pumpEditorAndFindPointRightOfText(
      WidgetTester tester,
    ) async {
      final controller = await _pumpEditor(tester, const [
        {'insert': 'alpha bravo\n'},
      ]);
      final renderEditor = _getRenderEditor(tester);
      // A point to the right of the end of the line. A word selection at this
      // point selects no text and leaves only the caret.
      return renderEditor.localToGlobal(
        renderEditor
                .getLocalRectForCaret(
                  TextPosition(
                    offset: controller.document.toPlainText().length - 1,
                  ),
                )
                .centerLeft +
            const Offset(200, 0),
      );
    }

    testWidgets('after a double tap', (tester) async {
      final pointRightOfText = await pumpEditorAndFindPointRightOfText(tester);
      await tester.tapAt(pointRightOfText);
      await tester.pump(const Duration(milliseconds: 50));
      // The second tap does not change the selection, so it does not request a
      // frame. The code that shows the toolbar therefore runs in the next
      // frame, which removes the editor.
      await tester.tapAt(pointRightOfText);
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });

    testWidgets('after a right click', (tester) async {
      final pointRightOfText = await pumpEditorAndFindPointRightOfText(tester);
      await tester.tapAt(
        pointRightOfText,
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });
  });

  group('Selection handles stay on their line wherever they are touched', () {
    // One line in each format. Each line is short enough to fit in the width
    // of the test screen.
    const documentJson = [
      {'insert': 'Heading alpha bravo'},
      {
        'insert': '\n',
        'attributes': {'header': 1},
      },
      {'insert': 'First paragraph charlie delta'},
      {'insert': '\n'},
      {'insert': 'Second paragraph echo foxtrot'},
      {'insert': '\n'},
      {'insert': 'Bullet golf hotel india'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
      {'insert': 'Last paragraph juliet kilo'},
      {'insert': '\n'},
    ];
    const formatNamesByLine = {0: 'heading', 2: 'paragraph', 3: 'bullet'};

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final MapEntry(key: line, value: formatName)
          in formatNamesByLine.entries) {
        for (final isStart in [true, false]) {
          final startOrEnd = isStart ? 'start' : 'end';
          testWidgets(
            '${platform.name}: the $startOrEnd handle of a word on the '
            '$formatName line, dragged horizontally from different points of '
            'its touch area',
            (tester) async {
              debugDefaultTargetPlatformOverride = platform;
              try {
                // Positions from near the top to near the bottom of the touch
                // area.
                for (final heightFraction in [0.05, 0.25, 0.5, 0.75, 0.95]) {
                  final controller = await _pumpEditor(tester, documentJson);
                  final before = await _selectMiddleWord(
                    tester,
                    controller,
                    line,
                  );
                  final touchArea = _getSelectionHandleTouchArea(
                    tester,
                    isStart: isStart,
                  );
                  await tester.timedDragFrom(
                    Offset(
                      touchArea.center.dx,
                      touchArea.top + touchArea.height * heightFraction,
                    ),
                    Offset(isStart ? -100 : 100, 0),
                    const Duration(milliseconds: 500),
                  );
                  await tester.pumpAndSettle();

                  _expectDraggedEndMovedOnLine(
                    controller,
                    before,
                    isStart: isStart,
                    line: line,
                    reason:
                        'touched at $heightFraction of the height of the '
                        'touch area',
                  );
                }
              } finally {
                debugDefaultTargetPlatformOverride = null;
              }
            },
          );
        }
      }
    }

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final isStart in [true, false]) {
        testWidgets('${platform.name}: the ${isStart ? 'start' : 'end'} handle '
            'of a word on a right-to-left line, dragged horizontally from '
            'different points of its touch area', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            for (final heightFraction in [0.05, 0.25, 0.5, 0.75, 0.95]) {
              final controller = await _pumpEditor(tester, const [
                {'insert': 'First line\n'},
                {'insert': 'אבג דהו זחט יכל'},
                {
                  'insert': '\n',
                  'attributes': {'direction': 'rtl', 'align': 'right'},
                },
                {'insert': 'Next line\n'},
              ]);
              final before = await _selectMiddleWord(
                tester,
                controller,
                1,
                wordPattern: RegExp(r'\S+'),
              );
              final touchArea = _getSelectionHandleTouchArea(
                tester,
                isStart: isStart,
              );
              await tester.timedDragFrom(
                Offset(
                  touchArea.center.dx,
                  touchArea.top + touchArea.height * heightFraction,
                ),
                Offset(isStart ? 60 : -60, 0),
                const Duration(milliseconds: 500),
              );
              await tester.pumpAndSettle();

              _expectDraggedEndMovedOnLine(
                controller,
                before,
                isStart: isStart,
                line: 1,
                reason:
                    'touched at $heightFraction of the height of the '
                    'touch area',
              );
            }
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }
    }

    testWidgets('a horizontal drag with small vertical movements stays on its '
        'line', (tester) async {
      for (final verticalMovementInLines in [-0.8, 0.8]) {
        final controller = await _pumpEditor(tester, documentJson);
        final before = await _selectMiddleWord(tester, controller, 2);
        final lineHeight = _getRenderEditor(
          tester,
        ).preferredLineHeight(TextPosition(offset: before.end));
        final touchArea = _getSelectionHandleTouchArea(tester, isStart: false);
        await tester.timedDragFrom(
          touchArea.center,
          Offset(100, verticalMovementInLines * lineHeight),
          const Duration(milliseconds: 500),
        );
        await tester.pumpAndSettle();

        _expectDraggedEndMovedOnLine(
          controller,
          before,
          isStart: false,
          line: 2,
          reason: 'vertical movement of $verticalMovementInLines line heights',
        );
      }
    });

    testWidgets('dragging the end handle down from a heading moves it to the '
        'next line, although the two lines have different heights', (
      tester,
    ) async {
      final controller = await _pumpEditor(tester, documentJson);
      await _selectMiddleWord(tester, controller, 0);
      final renderEditor = _getRenderEditor(tester);
      double getLocalLineMiddleY(int line) => renderEditor
          .getLocalRectForCaret(
            TextPosition(offset: _getLineStart(controller, line)),
          )
          .center
          .dy;
      final touchArea = _getSelectionHandleTouchArea(tester, isStart: false);
      // To a quarter of a line below the middle of the next line.
      await tester.timedDragFrom(
        touchArea.center,
        Offset(0, 1.25 * (getLocalLineMiddleY(1) - getLocalLineMiddleY(0))),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();

      expect(_getLineIndex(controller, controller.selection.end - 1), 1);
    });
  });

  group(
    'Selection handles move onto an embed as soon as a drag reaches it',
    () {
      const documentJson = [
        {'insert': 'alpha bravo charlie\n'},
        {
          'insert': {_TallEmbedBuilder.type: ''},
        },
        {'insert': '\ndelta echo foxtrot\ngolf hotel india\n'},
      ];

      // `flutter_quill_extensions` shows images and videos inline, as part of
      // a line of text. By default, other embeds are shown as separate blocks.
      for (final (expanded, embedDescription) in [
        (false, 'an inline embed'),
        (true, 'a block embed'),
      ]) {
        for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
          testWidgets(
            '${platform.name}: the end handle moves onto $embedDescription '
            'below it, and then to the line after the embed',
            (tester) async {
              debugDefaultTargetPlatformOverride = platform;
              try {
                final controller = await _pumpEditor(
                  tester,
                  documentJson,
                  embedBuilders: [_TallEmbedBuilder(expanded: expanded)],
                );
                final before = await _selectMiddleWord(tester, controller, 0);
                final embedRect = tester.getRect(
                  find.byKey(_TallEmbedBuilder.boxKey),
                );
                final embedOffset = _getLineStart(controller, 1);

                // To a quarter of the embed's height below its top.
                await tester.timedDragFrom(
                  _getSelectionHandleTouchArea(tester, isStart: false).center,
                  Offset(
                    0,
                    embedRect.top +
                        embedRect.height / 4 -
                        _getLineMiddleAtHandle(
                          tester,
                          controller,
                          isStart: false,
                        ).dy,
                  ),
                  const Duration(milliseconds: 500),
                );
                await tester.pumpAndSettle();

                expect(controller.selection.start, before.start);
                expect(
                  controller.selection.end,
                  inInclusiveRange(embedOffset, embedOffset + 1),
                );

                // From the embed to a quarter of a line below the middle of the
                // next line.
                final renderEditor = _getRenderEditor(tester);
                final nextLineStart = TextPosition(
                  offset: _getLineStart(controller, 2),
                );
                final nextLineMiddleY = renderEditor
                    .localToGlobal(
                      renderEditor.getLocalRectForCaret(nextLineStart).center,
                    )
                    .dy;
                await tester.timedDragFrom(
                  _getSelectionHandleTouchArea(tester, isStart: false).center,
                  Offset(
                    0,
                    nextLineMiddleY +
                        renderEditor.preferredLineHeight(nextLineStart) / 4 -
                        _getLineMiddleAtHandle(
                          tester,
                          controller,
                          isStart: false,
                        ).dy,
                  ),
                  const Duration(milliseconds: 500),
                );
                await tester.pumpAndSettle();

                expect(controller.selection.start, before.start);
                expect(_getLineIndex(controller, controller.selection.end), 2);
              } finally {
                debugDefaultTargetPlatformOverride = null;
              }
            },
          );

          testWidgets(
            '${platform.name}: the start handle moves onto $embedDescription '
            'above it',
            (tester) async {
              debugDefaultTargetPlatformOverride = platform;
              try {
                final controller = await _pumpEditor(
                  tester,
                  documentJson,
                  embedBuilders: [_TallEmbedBuilder(expanded: expanded)],
                );
                final before = await _selectMiddleWord(tester, controller, 2);
                final embedRect = tester.getRect(
                  find.byKey(_TallEmbedBuilder.boxKey),
                );
                final embedOffset = _getLineStart(controller, 1);

                // To a quarter of the embed's height above its bottom.
                await tester.timedDragFrom(
                  _getSelectionHandleTouchArea(tester, isStart: true).center,
                  Offset(
                    0,
                    embedRect.bottom -
                        embedRect.height / 4 -
                        _getLineMiddleAtHandle(
                          tester,
                          controller,
                          isStart: true,
                        ).dy,
                  ),
                  const Duration(milliseconds: 500),
                );
                await tester.pumpAndSettle();

                expect(controller.selection.end, before.end);
                expect(
                  controller.selection.start,
                  inInclusiveRange(embedOffset, embedOffset + 1),
                );
              } finally {
                debugDefaultTargetPlatformOverride = null;
              }
            },
          );
        }
      }
    },
  );

  group('Gestures in the touch area of a selection handle', () {
    // Long enough for the editor to scroll.
    final documentJson = [
      for (var i = 1; i <= 40; i++) {'insert': 'Line $i alpha bravo charlie\n'},
    ];
    const platforms = TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    });

    testWidgets('a drag down that starts just below the drawn handle moves '
        'the handle instead of scrolling the editor', (tester) async {
      final controller = await _pumpEditor(tester, documentJson);
      final before = await _selectMiddleWord(tester, controller, 4);
      final touchArea = _getSelectionHandleTouchArea(tester, isStart: false);
      await tester.timedDragFrom(
        Offset(touchArea.center.dx, touchArea.bottom - 3),
        const Offset(0, 60),
        const Duration(milliseconds: 500),
      );
      await tester.pumpAndSettle();

      expect(controller.selection.start, before.start);
      expect(
        _getLineIndex(controller, controller.selection.end - 1),
        greaterThan(4),
      );
    });

    testWidgets('a long press just below the drawn handle, followed by a '
        'drag, moves the handle instead of selecting a word', (tester) async {
      final controller = await _pumpEditor(tester, documentJson);
      final before = await _selectMiddleWord(tester, controller, 4);
      final touchArea = _getSelectionHandleTouchArea(tester, isStart: false);
      final gesture = await tester.startGesture(
        Offset(touchArea.center.dx, touchArea.bottom - 3),
      );
      // Longer than the delay after which the editor detects a long press.
      await tester.pump(const Duration(milliseconds: 800));
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      _expectDraggedEndMovedOnLine(controller, before, isStart: false, line: 4);
    });

    // "bravo" is selected. "alpha" and "charlie" are next to its handles.
    for (final (isStart, word) in [(false, 'charlie'), (true, 'alpha')]) {
      for (final gestureName in ['tap', 'double tap', 'long press']) {
        testWidgets('a $gestureName on "$word" in the touch area of the '
            "${isStart ? 'start' : 'end'} handle, on the selected line, is "
            'handled by the editor', (tester) async {
          final controller = await _pumpEditor(tester, documentJson);
          await _selectMiddleWord(tester, controller, 4);
          final renderEditor = _getRenderEditor(tester);
          final text = controller.document.toPlainText();
          final wordStart = text.indexOf(word, _getLineStart(controller, 4));
          // A point a quarter of the way into the letter of `word` that is
          // nearest to the selection, so that it is inside the word and not
          // on its edge. Vertically, it is in the middle of the line.
          final letterOffset = isStart
              ? wordStart + word.length - 1
              : wordStart;
          final [left, right] = renderEditor.getEndpointsForSelection(
            TextSelection(
              baseOffset: letterOffset,
              extentOffset: letterOffset + 1,
            ),
          );
          final lineHeight = renderEditor.preferredLineHeight(
            TextPosition(offset: letterOffset),
          );
          final gesturePoint = renderEditor.localToGlobal(
            Offset(
              left.point.dx + (right.point.dx - left.point.dx) / 4,
              left.point.dy - lineHeight / 2,
            ),
          );
          expect(
            _getSelectionHandleTouchArea(
              tester,
              isStart: isStart,
            ).contains(gesturePoint),
            isTrue,
          );

          switch (gestureName) {
            case 'tap':
              await tester.tapAt(gesturePoint);
            case 'double tap':
              await tester.tapAt(gesturePoint);
              await tester.pump(const Duration(milliseconds: 50));
              await tester.tapAt(gesturePoint);
            default:
              await tester.longPressAt(gesturePoint);
          }
          await tester.pumpAndSettle();

          final selection = controller.selection;
          if (gestureName == 'tap') {
            expect(selection.isCollapsed, isTrue);
            expect(
              selection.start,
              inInclusiveRange(wordStart, wordStart + word.length),
            );
          } else {
            expect(
              (selection.start, selection.end),
              (wordStart, wordStart + word.length),
            );
          }
        });
      }
    }

    testWidgets('a stylus drags a selection handle as a finger does, and the '
        'handles stay', (tester) async {
      final controller = await _pumpEditor(tester, documentJson);
      final before = await _selectMiddleWord(tester, controller, 4);
      final gesture = await _beginDraggingHandle(
        tester,
        isStart: false,
        kind: PointerDeviceKind.stylus,
      );

      _expectDraggedEndMovedOnLine(controller, before, isStart: false, line: 4);
      // `_getSelectionHandleTouchArea` also checks that both handles are
      // still shown.
      _getSelectionHandleTouchArea(tester, isStart: false);
      await gesture.up();
    }, variant: platforms);

    testWidgets('a touch on a selection handle is not a tap outside the '
        'editor', (tester) async {
      var tapsOutside = 0;
      final controller = await _pumpEditor(
        tester,
        documentJson,
        onTapOutside: (_, _) => tapsOutside++,
      );
      await _selectMiddleWord(tester, controller, 4);
      final gesture = await _beginDraggingHandle(tester, isStart: false);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapsOutside, 0);
    }, variant: platforms);
  });

  group('The magnifier shows the line that is being selected', () {
    const documentJson = [
      {
        'insert':
            'First line alpha bravo charlie\nSecond line delta echo foxtrot\n'
            '\nFourth line golf hotel india\n',
      },
    ];
    const platforms = TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    });

    testWidgets(
      'dragging a handle magnifies the middle of its line, wherever the handle '
      'is touched',
      (tester) async {
        for (final isStart in [true, false]) {
          for (final heightFraction in [0.05, 0.5, 0.95]) {
            final reason =
                '${isStart ? 'start' : 'end'} handle touched at '
                '$heightFraction of the height of its touch area';
            final magnifierPoints = <Offset>[];
            final controller = await _pumpEditor(
              tester,
              documentJson,
              quillMagnifierBuilder: _createRecordingMagnifierBuilder(
                magnifierPoints,
              ),
            );
            await _selectMiddleWord(tester, controller, 1);
            final gesture = await _beginDraggingHandle(
              tester,
              isStart: isStart,
              heightFraction: heightFraction,
            );

            expect(magnifierPoints, isNotEmpty, reason: reason);
            expect(
              magnifierPoints.last.dy,
              moreOrLessEquals(
                _getLineMiddleY(tester, controller, 1),
                epsilon: 0.5,
              ),
              reason: reason,
            );
            final lineEnds = _getLineEnds(tester, controller, 1);
            expect(
              magnifierPoints.last.dx,
              inInclusiveRange(lineEnds.left, lineEnds.right),
              reason: reason,
            );

            await gesture.up();
            await tester.pumpAndSettle();
            expect(find.byType(QuillMagnifier), findsNothing, reason: reason);
          }
        }
      },
      variant: platforms,
    );

    testWidgets(
      'the magnifier follows the end of the selection to the next line',
      (tester) async {
        final magnifierPoints = <Offset>[];
        final controller = await _pumpEditor(
          tester,
          documentJson,
          quillMagnifierBuilder: _createRecordingMagnifierBuilder(
            magnifierPoints,
          ),
        );
        await _selectMiddleWord(tester, controller, 0);
        final gesture = await _beginDraggingHandle(tester, isStart: false);
        final distanceToNextLine =
            _getLineMiddleY(tester, controller, 1) -
            _getLineMiddleY(tester, controller, 0);
        await gesture.moveBy(Offset(0, 1.25 * distanceToNextLine));
        await tester.pump(const Duration(milliseconds: 16));

        expect(_getLineIndex(controller, controller.selection.end - 1), 1);
        expect(
          magnifierPoints.last.dy,
          moreOrLessEquals(
            _getLineMiddleY(tester, controller, 1),
            epsilon: 0.5,
          ),
        );
        await gesture.up();
      },
      variant: platforms,
    );

    testWidgets(
      'a drag after a long press magnifies the line under the finger, '
      'between the ends of that line',
      (tester) async {
        final magnifierPoints = <Offset>[];
        final controller = await _pumpEditor(
          tester,
          documentJson,
          quillMagnifierBuilder: _createRecordingMagnifierBuilder(
            magnifierPoints,
          ),
        );
        final longPressPoint = Offset(
          _getLineEnds(tester, controller, 0).left + 50,
          _getLineMiddleY(tester, controller, 0),
        );
        // A point slightly below the middle of the next line, to the right of
        // the end of its text.
        final pointAfterDrag = Offset(
          longPressPoint.dx + 600,
          _getLineMiddleY(tester, controller, 1) + 5,
        );
        final gesture = await tester.startGesture(longPressPoint);
        // Longer than the delay after which the editor detects a long press.
        await tester.pump(const Duration(milliseconds: 600));
        for (var i = 1; i <= 4; i++) {
          await gesture.moveTo(
            Offset.lerp(longPressPoint, pointAfterDrag, i / 4)!,
          );
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(
          magnifierPoints.last.dy,
          moreOrLessEquals(
            _getLineMiddleY(tester, controller, 1),
            epsilon: 0.5,
          ),
        );
        expect(
          magnifierPoints.last.dx,
          moreOrLessEquals(
            _getLineEnds(tester, controller, 1).right,
            epsilon: 0.5,
          ),
        );
        await gesture.up();
        await tester.pumpAndSettle();
      },
      variant: platforms,
    );

    testWidgets('on the first line, the magnifier stays inside the screen and '
        'still magnifies that line', (tester) async {
      final magnifierPoints = <Offset>[];
      final controller = await _pumpEditor(
        tester,
        documentJson,
        quillMagnifierBuilder: _createRecordingMagnifierBuilder(
          magnifierPoints,
        ),
      );
      await _selectMiddleWord(tester, controller, 0);
      final gesture = await _beginDraggingHandle(tester, isStart: false);

      final magnifier = find.byType(RawMagnifier);
      final magnifierRect = tester.getRect(magnifier);
      final screenRect =
          Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(
        magnifierRect.left >= screenRect.left &&
            magnifierRect.top >= screenRect.top &&
            magnifierRect.right <= screenRect.right &&
            magnifierRect.bottom <= screenRect.bottom,
        isTrue,
        reason: '$magnifierRect is not inside $screenRect',
      );
      expect(
        magnifierPoints.last.dy,
        moreOrLessEquals(_getLineMiddleY(tester, controller, 0), epsilon: 0.5),
      );
      expect(
        magnifierRect.center +
            tester.widget<RawMagnifier>(magnifier).focalPointOffset,
        offsetMoreOrLessEquals(magnifierPoints.last, epsilon: 0.5),
      );
      await gesture.up();
    }, variant: platforms);

    testWidgets('the magnifier stays inside a root overlay that is smaller '
        'than the screen, and still magnifies the selected line', (
      tester,
    ) async {
      final magnifierPoints = <Offset>[];
      final controller = await _pumpEditor(
        tester,
        [
          {'insert': 'alpha bravo charlie\n'},
        ],
        quillMagnifierBuilder: _createRecordingMagnifierBuilder(
          magnifierPoints,
        ),
        // So narrow that each word is on a line of its own, which ends near
        // the right edge of the overlay.
        appBuilder: (context, child) => Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 150, height: 400, child: child),
        ),
      );
      await _selectMiddleWord(tester, controller, 0);
      final gesture = await _beginDraggingHandle(tester, isStart: false);

      final overlayRect = tester.getRect(find.byType(Overlay).first);
      final magnifier = find.byType(RawMagnifier);
      final magnifierRect = tester.getRect(magnifier);
      expect(
        magnifierRect.left >= overlayRect.left &&
            magnifierRect.top >= overlayRect.top &&
            magnifierRect.right <= overlayRect.right &&
            magnifierRect.bottom <= overlayRect.bottom,
        isTrue,
        reason: '$magnifierRect is not inside $overlayRect',
      );
      expect(
        magnifierRect.center +
            tester.widget<RawMagnifier>(magnifier).focalPointOffset,
        offsetMoreOrLessEquals(magnifierPoints.last, epsilon: 0.5),
      );
      await gesture.up();
    }, variant: platforms);

    testWidgets('dragging onto an empty line magnifies it', (tester) async {
      final magnifierPoints = <Offset>[];
      final controller = await _pumpEditor(
        tester,
        documentJson,
        quillMagnifierBuilder: _createRecordingMagnifierBuilder(
          magnifierPoints,
        ),
      );
      await _selectMiddleWord(tester, controller, 1);
      final gesture = await _beginDraggingHandle(tester, isStart: false);
      final distanceToNextLine =
          _getLineMiddleY(tester, controller, 2) -
          _getLineMiddleY(tester, controller, 1);
      await gesture.moveBy(Offset(0, 1.25 * distanceToNextLine));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
      expect(controller.selection.end, _getLineStart(controller, 2));
      expect(
        magnifierPoints.last.dy,
        moreOrLessEquals(_getLineMiddleY(tester, controller, 2), epsilon: 0.5),
      );
      await gesture.up();
    }, variant: platforms);

    testWidgets(
      'on a line with text in both directions, the magnifier follows the '
      'handle over the text in the other direction',
      (tester) async {
        const lineText = 'abc defg אבגד הוזח';
        // A paragraph, and an item of a list. The editor shows a list as a
        // block of lines.
        for (final lineAttributes in [
          null,
          {'list': 'bullet'},
        ]) {
          final reason = lineAttributes == null ? 'paragraph' : 'list item';
          final magnifierPoints = <Offset>[];
          final controller = await _pumpEditor(
            tester,
            [
              {'insert': lineText},
              {
                'insert': '\n',
                if (lineAttributes != null) 'attributes': lineAttributes,
              },
            ],
            quillMagnifierBuilder: _createRecordingMagnifierBuilder(
              magnifierPoints,
            ),
          );
          await _selectMiddleWord(tester, controller, 0);
          // The middle of the Hebrew text, between its left and right ends.
          // The ends are measured from the carets between its letters.
          final hebrewStart = lineText.indexOf('א');
          final hebrewCaretXs = [
            for (var offset = hebrewStart; offset <= lineText.length; offset++)
              _getCaretCenter(tester, offset).dx,
          ];
          final hebrewMiddleX =
              (hebrewCaretXs.reduce(math.min) +
                  hebrewCaretXs.reduce(math.max)) /
              2;
          // A dragged end moves as far as the finger, from the middle of its
          // line at the handle.
          final distanceToHebrewMiddle =
              hebrewMiddleX -
              _getLineMiddleAtHandle(tester, controller, isStart: false).dx;
          final gesture = await tester.startGesture(
            _getSelectionHandleTouchArea(tester, isStart: false).center,
          );
          for (var i = 0; i < 5; i++) {
            await gesture.moveBy(Offset(distanceToHebrewMiddle / 5, 0));
            await tester.pump(const Duration(milliseconds: 16));
          }

          expect(
            controller.selection.end,
            greaterThan(hebrewStart),
            reason: reason,
          );
          expect(
            magnifierPoints.last.dx,
            moreOrLessEquals(hebrewMiddleX, epsilon: 0.5),
            reason: reason,
          );
          await gesture.up();
          await tester.pumpAndSettle();
        }
      },
      variant: platforms,
    );

    testWidgets('the magnifier is hidden while the selected line is outside '
        'the visible part of the editor', (tester) async {
      final controller = await _pumpEditor(
        tester,
        [
          {'insert': 'alpha bravo charlie\n'},
          {
            'insert': {_TallEmbedBuilder.type: ''},
          },
          {'insert': '\ndelta echo foxtrot\n'},
        ],
        embedBuilders: [const _TallEmbedBuilder(expanded: false)],
        quillMagnifierBuilder: defaultQuillMagnifierBuilder,
        editorHeight: 150,
      );
      await _selectMiddleWord(tester, controller, 0);
      final gesture = await _beginDraggingHandle(tester, isStart: false);
      expect(find.byType(QuillMagnifier), findsOneWidget);

      // To a quarter of the embed's height below its top. The caret of the
      // embed's line is at the bottom of that line, which is below the visible
      // part of the editor.
      final embedRect = tester.getRect(find.byKey(_TallEmbedBuilder.boxKey));
      await gesture.moveBy(
        Offset(
          0,
          embedRect.top +
              embedRect.height / 4 -
              _getLineMiddleAtHandle(tester, controller, isStart: false).dy,
        ),
      );
      await tester.pump();

      expect(
        controller.selection.end,
        inInclusiveRange(
          _getLineStart(controller, 1),
          _getLineStart(controller, 1) + 1,
        ),
      );
      expect(find.byType(QuillMagnifier), findsNothing);
      await gesture.up();
    }, variant: platforms);

    testWidgets(
      'the magnifier is hidden while the selected line is scrolled out of view '
      'by a scroll view around an editor that does not scroll itself',
      (tester) async {
        final magnifierPoints = <Offset>[];
        final outerScrollController = ScrollController();
        addTearDown(outerScrollController.dispose);
        final controller = await _pumpEditor(
          tester,
          [
            {
              'insert':
                  '${[for (var i = 1; i <= 40; i++) 'Line $i alpha bravo'].join('\n')}\n',
            },
          ],
          quillMagnifierBuilder: _createRecordingMagnifierBuilder(
            magnifierPoints,
          ),
          withAppBar: true,
          outerScrollController: outerScrollController,
        );
        outerScrollController.jumpTo(200);
        await tester.pumpAndSettle();
        // The first line that is fully visible below the app bar.
        final scrollViewTop = tester
            .getRect(find.byType(SingleChildScrollView))
            .top;
        final lineHeight = _getRenderEditor(
          tester,
        ).preferredLineHeight(const TextPosition(offset: 0));
        var line = 0;
        while (_getLineMiddleY(tester, controller, line) <
            scrollViewTop + lineHeight) {
          line++;
        }
        await _selectMiddleWord(tester, controller, line);
        final gesture = await _beginDraggingHandle(tester, isStart: true);
        expect(find.byType(QuillMagnifier), findsOneWidget);

        // Up, over the app bar. The lines there are scrolled out of view.
        for (var i = 0; i < 20; i++) {
          await gesture.moveBy(const Offset(0, -4));
          await tester.pump(const Duration(milliseconds: 16));
        }

        expect(
          controller.selection.start,
          lessThan(_getLineStart(controller, line)),
        );
        expect(
          magnifierPoints.where((point) => point.dy < scrollViewTop),
          isEmpty,
        );
        await gesture.up();
        await tester.pumpAndSettle();
      },
      variant: platforms,
    );

    testWidgets('the magnifier is removed together with the editor', (
      tester,
    ) async {
      final controller = await _pumpEditor(
        tester,
        documentJson,
        quillMagnifierBuilder: defaultQuillMagnifierBuilder,
      );
      await _selectMiddleWord(tester, controller, 1);
      final gesture = await _beginDraggingHandle(tester, isStart: false);
      expect(find.byType(QuillMagnifier), findsOneWidget);

      // The same app, but without the editor.
      await tester.pumpWidget(QuillTestApp.withScaffold(const SizedBox()));
      await tester.pump();

      expect(find.byType(QuillMagnifier), findsNothing);
      expect(tester.takeException(), isNull);
      await gesture.up();
    }, variant: platforms);

    testWidgets('the magnifier is shown above an app bar, not inside the '
        'editor', (tester) async {
      final controller = await _pumpEditor(
        tester,
        documentJson,
        quillMagnifierBuilder: defaultQuillMagnifierBuilder,
        withAppBar: true,
      );
      await _selectMiddleWord(tester, controller, 0);
      final gesture = await _beginDraggingHandle(tester, isStart: false);

      expect(find.byType(QuillMagnifier), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(QuillEditor),
          matching: find.byType(QuillMagnifier),
        ),
        findsNothing,
      );
      expect(
        tester.getRect(find.byType(RawMagnifier)).top,
        lessThan(tester.getRect(find.byType(AppBar)).bottom),
      );
      await gesture.up();
    }, variant: platforms);

    testWidgets('the magnifier is removed when a mouse drag ends', (
      tester,
    ) async {
      final controller = await _pumpEditor(
        tester,
        documentJson,
        quillMagnifierBuilder: defaultQuillMagnifierBuilder,
      );
      final gesture = await tester.startGesture(
        Offset(
          _getLineEnds(tester, controller, 0).left + 2,
          _getLineMiddleY(tester, controller, 0),
        ),
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(15, 0));
        await tester.pump(const Duration(milliseconds: 30));
      }
      // The editor handles mouse drag updates after a short delay. Wait until
      // that delay has passed.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(QuillMagnifier), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(QuillMagnifier), findsNothing);
    }, variant: platforms);
  });
}

/// Builds and shows a focused [QuillEditor] for [documentJson], without a
/// context menu. The context menu would otherwise cover part of the touch area
/// of a selection handle.
///
/// If [withAppBar] is `true`, an [AppBar] is shown above the editor. If
/// [editorHeight] is given, the editor has that height and is at the top of
/// the screen. If [outerScrollController] is given, the editor does not scroll
/// itself. Instead, it is inside a [SingleChildScrollView] that
/// [outerScrollController] scrolls. If [appBuilder] is given, it wraps the
/// app's [Navigator], as [MaterialApp.builder] does. [onTapOutside] is passed
/// to the editor's configuration.
Future<QuillController> _pumpEditor(
  WidgetTester tester,
  List<Map<String, Object>> documentJson, {
  Iterable<EmbedBuilder>? embedBuilders,
  QuillMagnifierBuilder? quillMagnifierBuilder,
  bool withAppBar = false,
  double? editorHeight,
  ScrollController? outerScrollController,
  TransitionBuilder? appBuilder,
  void Function(PointerDownEvent event, FocusNode focusNode)? onTapOutside,
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
  final quillEditor = QuillEditor(
    controller: controller,
    focusNode: focusNode,
    scrollController: scrollController,
    config: QuillEditorConfig(
      padding: const EdgeInsets.all(16),
      scrollable: outerScrollController == null,
      contextMenuBuilder: (_, _) => const SizedBox.shrink(),
      embedBuilders: embedBuilders,
      quillMagnifierBuilder: quillMagnifierBuilder,
      onTapOutside: onTapOutside,
    ),
  );
  final editor = outerScrollController == null
      ? quillEditor
      : SingleChildScrollView(
          controller: outerScrollController,
          child: quillEditor,
        );
  final body = editorHeight == null
      ? editor
      : Column(
          children: [
            SizedBox(
              height: editorHeight,
              width: double.infinity,
              child: editor,
            ),
          ],
        );
  // Remove any earlier editor first, so that each call of this function
  // creates a new editor.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    withAppBar
        ? QuillTestApp.home(
            Scaffold(
              appBar: AppBar(title: const Text('Notes')),
              body: body,
            ),
            builder: appBuilder,
          )
        : QuillTestApp.withScaffold(body, builder: appBuilder),
  );
  focusNode.requestFocus();
  await tester.pumpAndSettle();
  return controller;
}

RenderEditor _getRenderEditor(WidgetTester tester) => tester
    .state<QuillEditorState>(find.byType(QuillEditor))
    .editableTextKey
    .currentState!
    .renderEditor;

/// Returns the middle of the caret at [offset], in global coordinates.
///
/// The x is taken from the end point of a collapsed selection, because
/// `RenderEditor.getLocalRectForCaret` leaves out the horizontal offset of the
/// line, such as the editor's padding.
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

int _getLineIndex(QuillController controller, int offset) => '\n'
    .allMatches(controller.document.toPlainText().substring(0, offset))
    .length;

/// Selects the middle word of [line] with the usual gesture of the platform.
/// This is a long press, or a double tap on iOS, where a long press only moves
/// the caret. Selecting the word in code would not show the selection
/// handles.
///
/// [wordPattern] finds the words of the line. By default, it finds runs of
/// Latin letters.
Future<TextSelection> _selectMiddleWord(
  WidgetTester tester,
  QuillController controller,
  int line, {
  RegExp? wordPattern,
}) async {
  final lineStart = _getLineStart(controller, line);
  final text = controller.document.toPlainText();
  final wordMatches = (wordPattern ?? RegExp('[A-Za-z]+'))
      .allMatches(text.substring(lineStart, text.indexOf('\n', lineStart)))
      .toList();
  final middleWordMatch = wordMatches[wordMatches.length ~/ 2];
  final wordCenter = _getCaretCenter(
    tester,
    lineStart + (middleWordMatch.start + middleWordMatch.end) ~/ 2,
  );
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await tester.tapAt(wordCenter);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(wordCenter);
  } else {
    await tester.longPressAt(wordCenter);
  }
  await tester.pumpAndSettle();
  expect(
    (controller.selection.start, controller.selection.end),
    (lineStart + middleWordMatch.start, lineStart + middleWordMatch.end),
  );
  return controller.selection;
}

/// Returns the touch area of the start or end selection handle. The touch area
/// is larger than the handle that is drawn.
Rect _getSelectionHandleTouchArea(
  WidgetTester tester, {
  required bool isStart,
}) {
  final handles = find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString() == '_TextSelectionHandleOverlay',
  );
  expect(handles, findsNWidgets(2));
  return tester.getRect(
    find
        .descendant(
          of: handles.at(isStart ? 0 : 1),
          matching: find.byType(GestureDetector),
        )
        .first,
  );
}

/// Returns the middle of the line at the start or end of the selection, in
/// global coordinates. When that handle is dragged, the selection moves from
/// this point, wherever the finger is placed on the handle.
Offset _getLineMiddleAtHandle(
  WidgetTester tester,
  QuillController controller, {
  required bool isStart,
}) {
  final renderEditor = _getRenderEditor(tester);
  final selection = controller.selection;
  final endpoints = renderEditor.getEndpointsForSelection(selection);
  final lineHeight = renderEditor.preferredLineHeight(
    TextPosition(offset: isStart ? selection.start : selection.end),
  );
  return renderEditor.localToGlobal(
    (isStart ? endpoints.first : endpoints.last).point.translate(
      0,
      -lineHeight / 2,
    ),
  );
}

/// Builds a tall box for an embed, either inline or as a block.
class _TallEmbedBuilder extends EmbedBuilder {
  const _TallEmbedBuilder({required this.expanded});

  static const type = 'tall';
  static const boxKey = ValueKey('tall-embed');

  @override
  final bool expanded;

  @override
  String get key => type;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const SizedBox(key: boxKey, width: 160, height: 200);
}

/// Checks that the dragged end of [before] has moved away from the other end
/// and is still on [line], and that the other end has not changed.
void _expectDraggedEndMovedOnLine(
  QuillController controller,
  TextSelection before, {
  required bool isStart,
  required int line,
  String? reason,
}) {
  final after = controller.selection;
  if (isStart) {
    expect(after.end, before.end, reason: reason);
    expect(after.start, lessThan(before.start), reason: reason);
    expect(_getLineIndex(controller, after.start), line, reason: reason);
  } else {
    expect(after.start, before.start, reason: reason);
    expect(after.end, greaterThan(before.end), reason: reason);
    expect(_getLineIndex(controller, after.end - 1), line, reason: reason);
  }
}

/// A magnifier builder that adds each point it receives to [magnifierPoints].
QuillMagnifierBuilder _createRecordingMagnifierBuilder(
  List<Offset> magnifierPoints,
) => (point) {
  magnifierPoints.add(point);
  return defaultQuillMagnifierBuilder(point);
};

/// Begins dragging the start or end handle, and keeps the finger on the
/// screen. The finger starts at [heightFraction] of the height of the handle's
/// touch area. It then moves along the line, away from the other handle, far
/// enough for the drag to be recognized. [kind] is the kind of pointer that
/// drags, such as a stylus instead of a finger.
Future<TestGesture> _beginDraggingHandle(
  WidgetTester tester, {
  required bool isStart,
  double heightFraction = 0.5,
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  final touchArea = _getSelectionHandleTouchArea(tester, isStart: isStart);
  final gesture = await tester.startGesture(
    Offset(
      touchArea.center.dx,
      touchArea.top + touchArea.height * heightFraction,
    ),
    kind: kind,
  );
  for (var i = 0; i < 5; i++) {
    await gesture.moveBy(Offset(isStart ? -10 : 10, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  return gesture;
}

/// Returns the vertical middle of [line], in global coordinates. It is
/// measured from the caret at the start of the line.
double _getLineMiddleY(
  WidgetTester tester,
  QuillController controller,
  int line,
) {
  final renderEditor = _getRenderEditor(tester);
  final position = TextPosition(offset: _getLineStart(controller, line));
  final caretBottom = renderEditor
      .getEndpointsForSelection(TextSelection.fromPosition(position))
      .first
      .point;
  return renderEditor
      .localToGlobal(
        caretBottom.translate(
          0,
          -renderEditor.preferredLineHeight(position) / 2,
        ),
      )
      .dy;
}

/// Returns the left and right ends of the text of [line], in global
/// coordinates. The line must not be empty, and its text must fit on one line
/// on the screen.
({double left, double right}) _getLineEnds(
  WidgetTester tester,
  QuillController controller,
  int line,
) {
  final renderEditor = _getRenderEditor(tester);
  final lineStart = _getLineStart(controller, line);
  final [left, right] = renderEditor.getEndpointsForSelection(
    TextSelection(
      baseOffset: lineStart,
      extentOffset: controller.document.toPlainText().indexOf('\n', lineStart),
    ),
  );
  return (
    left: renderEditor.localToGlobal(left.point).dx,
    right: renderEditor.localToGlobal(right.point).dx,
  );
}

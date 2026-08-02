import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show BoxParentData;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/editor/widgets/text/text_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final platform in TargetPlatform.values) {
    testWidgets('caret prototype matches Flutter on $platform', (tester) async {
      final harness = await _pumpEditor(
        tester,
        text: 'Latin 中文\n',
        platform: platform,
      );
      addTearDown(harness.dispose);

      final line = harness.lines.single;
      const position = TextPosition(offset: 2);
      final preferredHeight = line.preferredLineHeight(position);
      final prototype = line.getCaretPrototype(position);

      expect(prototype.width, 2);
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          expect(prototype.top, 0);
          expect(prototype.height, preferredHeight + 2);
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          expect(prototype.top, 2);
          expect(prototype.height, preferredHeight - 4);
      }
    });
  }

  for (final devicePixelRatio in <double>[1, 2]) {
    testWidgets(
      'macOS final caret rect uses the stable insertion boundary at DPR $devicePixelRatio',
      (tester) async {
        final harness = await _pumpEditor(
          tester,
          text: 'A中B\n',
          platform: TargetPlatform.macOS,
          devicePixelRatio: devicePixelRatio,
          config: const QuillEditorConfig(
            cursorWidth: 1,
            cursorOffset: Offset.zero,
            cursorRadius: Radius.zero,
          ),
        );
        addTearDown(harness.dispose);

        final line = harness.lines.single;
        for (final position in const <TextPosition>[
          TextPosition(offset: 1),
          TextPosition(offset: 2),
          TextPosition(offset: 3),
        ]) {
          final preferredHeight = line.preferredLineHeight(position);
          final rawCaretOffset = line.getOffsetForCaret(position);
          final unsnappedRect = Rect.fromLTWH(
            rawCaretOffset.dx,
            rawCaretOffset.dy - 1,
            1,
            preferredHeight + 2,
          );
          final expectedRect = unsnappedRect.shift(
            _pixelSnap(line, unsnappedRect.topLeft, devicePixelRatio),
          );

          final actualRect = line.getLocalRectForCaret(position);
          expect(actualRect, _rectCloseTo(expectedRect));
          if (position.offset == 3) {
            expect(rawCaretOffset.dx, 48);
            expect(actualRect, const Rect.fromLTRB(48, -1, 49, 19));
          }
          final globalTopLeft = line.localToGlobal(actualRect.topLeft);
          expect(
            globalTopLeft.dx * devicePixelRatio,
            closeTo((globalTopLeft.dx * devicePixelRatio).round(), 1e-9),
          );
          expect(
            globalTopLeft.dy * devicePixelRatio,
            closeTo((globalTopLeft.dy * devicePixelRatio).round(), 1e-9),
          );
        }
      },
    );
  }

  testWidgets('macOS platform cursor offset remains device-pixel based', (
    tester,
  ) async {
    for (final devicePixelRatio in <double>[1, 2]) {
      final harness = await _pumpEditor(
        tester,
        text: 'ABC\n',
        platform: TargetPlatform.macOS,
        devicePixelRatio: devicePixelRatio,
      );

      final line = harness.lines.single;
      const position = TextPosition(offset: 2);
      final preferredHeight = line.preferredLineHeight(position);
      final rawCaretOffset = line.getOffsetForCaret(position);
      final unsnappedRect = Rect.fromLTWH(
        rawCaretOffset.dx - 2 / devicePixelRatio,
        rawCaretOffset.dy - 1,
        2,
        preferredHeight + 2,
      );
      final expectedRect = unsnappedRect.shift(
        _pixelSnap(line, unsnappedRect.topLeft, devicePixelRatio),
      );

      expect(line.getLocalRectForCaret(position), _rectCloseTo(expectedRect));
      harness.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('non-Apple final caret rect honors an explicit height', (
    tester,
  ) async {
    final harness = await _pumpEditor(
      tester,
      text: 'Latin 中文\n',
      platform: TargetPlatform.windows,
      devicePixelRatio: 2,
      config: const QuillEditorConfig(
        cursorWidth: 3,
        cursorHeight: 11,
        cursorOffset: Offset(0.25, 1.5),
      ),
    );
    addTearDown(harness.dispose);

    final line = harness.lines.single;
    const position = TextPosition(offset: 3);
    final preferredHeight = line.preferredLineHeight(position);
    final prototype = line.getCaretPrototype(position);
    expect(prototype, const Rect.fromLTWH(0, 2, 3, 7));

    final rawCaretOffset = line.getOffsetForCaret(position);
    final unsnappedRect = Rect.fromLTWH(
      rawCaretOffset.dx + 0.25,
      rawCaretOffset.dy + 1.5 + (preferredHeight - 11) / 2,
      3,
      11,
    );
    final expectedRect = unsnappedRect.shift(
      _pixelSnap(line, unsnappedRect.topLeft, 2),
    );
    expect(line.getLocalRectForCaret(position), _rectCloseTo(expectedRect));
  });

  testWidgets(
    'macOS cursorHeight 16 reports exactly the vertically centered painted rect',
    (tester) async {
      const cursorColor = Color(0xFFFF5722);
      final harness = await _pumpEditor(
        tester,
        text: 'ABC\n',
        platform: TargetPlatform.macOS,
        devicePixelRatio: 2,
        selection: const TextSelection.collapsed(offset: 3),
        config: const QuillEditorConfig(
          cursorWidth: 1,
          cursorHeight: 16,
          cursorRadius: Radius.zero,
          cursorOffset: Offset.zero,
          textSelectionThemeData: TextSelectionThemeData(
            cursorColor: cursorColor,
          ),
        ),
      );
      addTearDown(harness.dispose);

      final line = harness.lines.single;
      const position = TextPosition(offset: 3);
      final fullHeight = line.preferredLineHeight(position);
      final rawCaretOffset = line.getOffsetForCaret(position);
      final unsnappedRect = Rect.fromLTWH(
        rawCaretOffset.dx,
        rawCaretOffset.dy + (fullHeight - 18) / 2,
        1,
        18,
      );
      final expectedRect = unsnappedRect.shift(
        _pixelSnap(line, unsnappedRect.topLeft, 2),
      );
      final actualRect = line.getLocalRectForCaret(position);

      expect(actualRect, _rectCloseTo(expectedRect));
      expect(fullHeight, 18);
      expect(rawCaretOffset.dx, 48);
      expect(actualRect, const Rect.fromLTRB(48, 0, 49, 18));
      expect(
        line,
        paints..rrect(
          color: cursorColor,
          rrect: RRect.fromRectAndRadius(
            actualRect.shift(line.localToGlobal(Offset.zero)),
            Radius.zero,
          ),
        ),
      );
    },
  );

  testWidgets(
    'reported caret rect is the painted rect for Latin, CJK, empty and multiline positions',
    (tester) async {
      const cursorColor = Color(0xFFFF5722);
      const text = 'Latin 中文\n\nSecond 行\n';
      final editorKey = GlobalKey<EditorState>();
      final harness = await _pumpEditor(
        tester,
        text: text,
        platform: TargetPlatform.windows,
        editorKey: editorKey,
        config: const QuillEditorConfig(
          textSelectionThemeData: TextSelectionThemeData(
            cursorColor: cursorColor,
          ),
        ),
      );
      addTearDown(harness.dispose);

      final renderEditor = editorKey.currentState!.renderEditor;
      final editorGlobalOffset = renderEditor.localToGlobal(Offset.zero);
      final positions = List<int>.generate(text.length, (index) => index)
          .expand(
            (offset) => <TextPosition>[
              TextPosition(offset: offset, affinity: TextAffinity.upstream),
              TextPosition(offset: offset),
            ],
          );

      for (final position in positions) {
        harness.controller.updateSelection(
          TextSelection.fromPosition(position),
          ChangeSource.local,
        );
        await tester.pump();

        final localRect = renderEditor.getLocalRectForCaret(position);
        expect(localRect.isFinite, isTrue, reason: '$position');
        expect(localRect.width, 2, reason: '$position');
        expect(localRect.height, greaterThan(0), reason: '$position');
        expect(
          renderEditor,
          paints..rect(
            color: cursorColor,
            rect: localRect.shift(editorGlobalOffset),
          ),
          reason: '$position',
        );
      }
    },
  );

  testWidgets('updated configuration changes the final caret rectangle', (
    tester,
  ) async {
    final document = Document.fromDelta(Delta()..insert('ABC\n'));
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 2),
    );
    final focusNode = FocusNode();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    addTearDown(scrollController.dispose);

    Widget build(QuillEditorConfig config) => MaterialApp(
      theme: ThemeData(platform: TargetPlatform.macOS),
      home: QuillEditor(
        controller: controller,
        focusNode: focusNode,
        scrollController: scrollController,
        config: config,
      ),
    );

    await tester.pumpWidget(
      build(
        const QuillEditorConfig(
          cursorWidth: 1,
          cursorHeight: 12,
          cursorOffset: Offset.zero,
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    final firstLine = tester.renderObject<RenderEditableTextLine>(
      find.byType(EditableTextLine).first,
    );
    final firstRect = firstLine.getLocalRectForCaret(
      const TextPosition(offset: 2),
    );
    expect(firstRect.size, const Size(1, 14));

    await tester.pumpWidget(
      build(
        const QuillEditorConfig(
          cursorWidth: 3,
          cursorHeight: 20,
          cursorOffset: Offset.zero,
        ),
      ),
    );
    await tester.pump();
    final updatedLine = tester.renderObject<RenderEditableTextLine>(
      find.byType(EditableTextLine).first,
    );
    final updatedRect = updatedLine.getLocalRectForCaret(
      const TextPosition(offset: 2),
    );
    expect(updatedRect.size, const Size(3, 22));
    expect(updatedRect, isNot(firstRect));
  });

  testWidgets(
    'inactive multiline caret derives geometry from the latest cursor style',
    (tester) async {
      const cursorColor = Color(0xFFFF5722);
      final editorKey = GlobalKey<EditorState>();
      final document = Document.fromDelta(Delta()..insert('first\nsecond\n'));
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 2),
      );
      final focusNode = FocusNode();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      addTearDown(scrollController.dispose);

      Widget build(QuillEditorConfig config) => MaterialApp(
        theme: ThemeData(platform: TargetPlatform.macOS),
        home: SizedBox(
          width: 420,
          height: 500,
          child: QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: config.copyWith(editorKey: editorKey),
          ),
        ),
      );

      await tester.pumpWidget(
        build(
          const QuillEditorConfig(
            cursorWidth: 1,
            cursorHeight: 12,
            cursorRadius: Radius.zero,
            cursorOffset: Offset.zero,
            cursorOpacityAnimates: false,
            textSelectionThemeData: TextSelectionThemeData(
              cursorColor: cursorColor,
            ),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();

      final initialLines = find
          .byType(EditableTextLine)
          .evaluate()
          .map((element) => element.renderObject! as RenderEditableTextLine)
          .toList(growable: false);
      final previouslyInactiveLine = initialLines[1];
      const localPosition = TextPosition(offset: 3);
      expect(previouslyInactiveLine.containsCursor(), isFalse);
      expect(
        previouslyInactiveLine.getCaretPrototype(localPosition),
        const Rect.fromLTWH(0, 0, 1, 14),
      );

      await tester.pumpWidget(
        build(
          const QuillEditorConfig(
            cursorWidth: 3,
            cursorHeight: 20,
            cursorRadius: Radius.circular(4),
            cursorOffset: Offset(5, 6),
            cursorOpacityAnimates: true,
            textSelectionThemeData: TextSelectionThemeData(
              cursorColor: cursorColor,
            ),
          ),
        ),
      );
      await tester.pump();

      final updatedLines = find
          .byType(EditableTextLine)
          .evaluate()
          .map((element) => element.renderObject! as RenderEditableTextLine)
          .toList(growable: false);
      expect(identical(updatedLines[1], previouslyInactiveLine), isTrue);
      expect(previouslyInactiveLine.containsCursor(), isFalse);
      expect(
        previouslyInactiveLine.getCaretPrototype(localPosition),
        const Rect.fromLTWH(0, 0, 3, 22),
      );

      controller.updateSelection(
        const TextSelection.collapsed(offset: 9),
        ChangeSource.local,
      );
      await tester.pump();

      expect(previouslyInactiveLine.containsCursor(), isTrue);
      final lineRect = previouslyInactiveLine.getLocalRectForCaret(
        localPosition,
      );
      expect(lineRect.size, const Size(3, 22));

      final renderEditor = editorKey.currentState!.renderEditor;
      final editorRect = renderEditor.getLocalRectForCaret(
        const TextPosition(offset: 9),
      );
      final editorGlobalRect = editorRect.shift(
        renderEditor.localToGlobal(Offset.zero),
      );
      final paintedGlobalRect = lineRect.shift(
        previouslyInactiveLine.localToGlobal(Offset.zero),
      );
      expect(editorGlobalRect, _rectCloseTo(paintedGlobalRect));
      expect(
        renderEditor,
        paints..rrect(
          color: cursorColor,
          rrect: RRect.fromRectAndRadius(
            paintedGlobalRect,
            const Radius.circular(4),
          ),
        ),
      );
    },
  );

  testWidgets(
    'editor caret rect includes centered child x offset and equals painted rect',
    (tester) async {
      const cursorColor = Color(0xFFFF5722);
      final editorKey = GlobalKey<EditorState>();
      final harness = await _pumpEditor(
        tester,
        text: 'ABC\n',
        platform: TargetPlatform.macOS,
        devicePixelRatio: 2,
        editorKey: editorKey,
        selection: const TextSelection.collapsed(offset: 3),
        config: const QuillEditorConfig(
          padding: EdgeInsets.fromLTRB(24, 8, 12, 0),
          maxContentWidth: 220,
          cursorWidth: 1,
          cursorHeight: 16,
          cursorRadius: Radius.zero,
          cursorOffset: Offset.zero,
          textSelectionThemeData: TextSelectionThemeData(
            cursorColor: cursorColor,
          ),
        ),
      );
      addTearDown(harness.dispose);

      final renderEditor = editorKey.currentState!.renderEditor;
      final line = harness.lines.single;
      const globalPosition = TextPosition(offset: 3);
      const localPosition = TextPosition(offset: 3);
      final childOffset = (line.parentData! as BoxParentData).offset;
      final lineRect = line.getLocalRectForCaret(localPosition);
      final editorRect = renderEditor.getLocalRectForCaret(globalPosition);

      expect(childOffset, const Offset(314, 8));
      expect(lineRect, const Rect.fromLTRB(48, 0, 49, 18));
      expect(editorRect, lineRect.shift(childOffset));
      expect(editorRect, const Rect.fromLTRB(362, 8, 363, 26));

      final editorGlobalRect = editorRect.shift(
        renderEditor.localToGlobal(Offset.zero),
      );
      final paintedGlobalRect = lineRect.shift(line.localToGlobal(Offset.zero));
      expect(editorGlobalRect, _rectCloseTo(paintedGlobalRect));
      expect(
        renderEditor,
        paints..rrect(
          color: cursorColor,
          rrect: RRect.fromRectAndRadius(paintedGlobalRect, Radius.zero),
        ),
      );
    },
  );
}

class _EditorHarness {
  _EditorHarness({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.lines,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final List<RenderEditableTextLine> lines;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
    scrollController.dispose();
  }
}

Future<_EditorHarness> _pumpEditor(
  WidgetTester tester, {
  required String text,
  required TargetPlatform platform,
  double devicePixelRatio = 1,
  QuillEditorConfig config = const QuillEditorConfig(),
  GlobalKey<EditorState>? editorKey,
  TextSelection selection = const TextSelection.collapsed(offset: 0),
}) async {
  assert(text.endsWith('\n'));
  final controller = QuillController(
    document: Document.fromDelta(Delta()..insert(text)),
    selection: selection,
  );
  final focusNode = FocusNode();
  final scrollController = ScrollController();

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: MediaQuery(
        data: MediaQueryData(devicePixelRatio: devicePixelRatio),
        child: SizedBox(
          width: 420,
          height: 500,
          child: QuillEditor(
            controller: controller,
            focusNode: focusNode,
            scrollController: scrollController,
            config: config.copyWith(
              autoFocus: false,
              showCursor: true,
              editorKey: editorKey,
            ),
          ),
        ),
      ),
    ),
  );
  focusNode.requestFocus();
  await tester.pump();

  final lines = find
      .byType(EditableTextLine)
      .evaluate()
      .map((element) => element.renderObject! as RenderEditableTextLine)
      .toList(growable: false);
  return _EditorHarness(
    controller: controller,
    focusNode: focusNode,
    scrollController: scrollController,
    lines: lines,
  );
}

Offset _pixelSnap(
  RenderBox renderBox,
  Offset localPosition,
  double devicePixelRatio,
) {
  final globalPosition = renderBox.localToGlobal(localPosition);
  final pixelMultiple = 1 / devicePixelRatio;
  return Offset(
    (globalPosition.dx / pixelMultiple).round() * pixelMultiple -
        globalPosition.dx,
    (globalPosition.dy / pixelMultiple).round() * pixelMultiple -
        globalPosition.dy,
  );
}

Matcher _rectCloseTo(Rect expected) => isA<Rect>()
    .having((rect) => rect.left, 'left', closeTo(expected.left, 1e-9))
    .having((rect) => rect.top, 'top', closeTo(expected.top, 1e-9))
    .having((rect) => rect.width, 'width', closeTo(expected.width, 1e-9))
    .having((rect) => rect.height, 'height', closeTo(expected.height, 1e-9));

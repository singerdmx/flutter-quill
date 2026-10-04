import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic();
  });

  tearDown(() {
    controller.dispose();
  });

  Future<QuillRawEditorState> pumpEditor(
    WidgetTester tester, {
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double? maxContentWidth,
    double? height,
    ScrollController? scrollController,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: height,
            child: QuillEditor.basic(
              controller: controller,
              scrollController: scrollController,
              config: QuillEditorConfig(
                autoFocus: true,
                padding: padding,
                maxContentWidth: maxContentWidth,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.state<QuillRawEditorState>(find.byType(QuillRawEditor));
  }

  group('Caret rect', () {
    testWidgets('includes the horizontal offset of the child', (tester) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(
        tester,
        padding: const EdgeInsets.only(left: 40),
      );
      final renderEditor = editorState.renderEditor;

      const position = TextPosition(offset: 3);
      final caretRect = renderEditor.getLocalRectForCaret(position);
      final endpoint = renderEditor
          .getEndpointsForSelection(TextSelection.fromPosition(position))
          .single;

      expect(caretRect.left, moreOrLessEquals(endpoint.point.dx));
      expect(caretRect.left, greaterThanOrEqualTo(40));
    });

    testWidgets('includes padding and centered content offsets', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      const position = TextPosition(offset: 3);
      final unpadded = await pumpEditor(tester);
      final originalRect = unpadded.renderEditor.getLocalRectForCaret(position);
      final padded = await pumpEditor(
        tester,
        padding: const EdgeInsets.only(left: 24, top: 16),
        maxContentWidth: 400,
      );
      final rect = padded.renderEditor.getLocalRectForCaret(position);
      final centeringOffset = (padded.renderEditor.size.width - 400) / 2;

      expect(rect, originalRect.shift(Offset(24 + centeringOffset, 16)));
    });
  });

  group('Floating cursor', () {
    testWidgets('commits the selection once when the gesture ends', (
      tester,
    ) async {
      controller
        ..document.insert(0, 'Hello world')
        ..updateSelection(
          const TextSelection.collapsed(offset: 0),
          ChangeSource.local,
        );
      final editorState = await pumpEditor(tester);
      var selectionChanges = 0;
      controller.addListener(() {
        selectionChanges++;
      });

      editorState
        ..updateFloatingCursor(
          RawFloatingCursorPoint(
            offset: Offset.zero,
            state: FloatingCursorDragState.Start,
          ),
        )
        ..updateFloatingCursor(
          RawFloatingCursorPoint(
            offset: const Offset(60, 0),
            state: FloatingCursorDragState.Update,
          ),
        );
      await tester.pump();

      // The selection is not updated while the gesture is in progress.
      expect(controller.selection, const TextSelection.collapsed(offset: 0));
      expect(selectionChanges, 0);
      final finalPosition = editorState.renderEditor.floatingCursorTextPosition;

      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pumpAndSettle();

      expect(controller.selection.isCollapsed, isTrue);
      expect(controller.selection, TextSelection.fromPosition(finalPosition));
      expect(controller.selection.baseOffset, greaterThan(0));
      expect(selectionChanges, 1);
    });

    testWidgets('ending the gesture without any update keeps the selection', (
      tester,
    ) async {
      controller
        ..document.insert(0, 'Hello world')
        ..updateSelection(
          const TextSelection.collapsed(offset: 5),
          ChangeSource.local,
        );
      final editorState = await pumpEditor(tester);

      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: Offset.zero,
          state: FloatingCursorDragState.Start,
        ),
      );
      expect(editorState.renderEditor, paints..rrect());
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      expect(editorState.renderEditor, isNot(paints..rrect()));
      expect(editorState.floatingCursorResetController.isAnimating, isFalse);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.selection, const TextSelection.collapsed(offset: 5));
      expect(editorState.renderEditor, isNot(paints..rrect()));
    });

    testWidgets('uses the long-press start location and text position', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      final renderEditor = editorState.renderEditor;
      const position = TextPosition(offset: 6, affinity: TextAffinity.upstream);
      final startCenter = renderEditor.getLocalRectForCaret(position).center;
      const origin = Offset(10, 20);

      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: origin,
          startLocation: (startCenter, position),
          state: FloatingCursorDragState.Start,
        ),
      );
      expect(renderEditor.floatingCursorTextPosition, position);
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: origin,
          state: FloatingCursorDragState.Update,
        ),
      );
      expect(renderEditor.floatingCursorTextPosition.offset, position.offset);
      expect(controller.selection.baseOffset, 0);
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pumpAndSettle();
      expect(controller.selection.baseOffset, position.offset);
    });

    testWidgets('preserves the two-finger selection sent by the engine', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: Offset.zero,
          state: FloatingCursorDragState.Start,
        ),
      );
      const selection = TextSelection(baseOffset: 8, extentOffset: 2);
      editorState.updateEditingValue(
        controller.plainTextEditingValue.copyWith(selection: selection),
      );
      await tester.pump();
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: const Offset(60, 0),
          state: FloatingCursorDragState.Update,
        ),
      );
      expect(controller.selection, selection);
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pumpAndSettle();
      expect(controller.selection, selection);
      expect(editorState.renderEditor, isNot(paints..rrect()));
    });

    testWidgets(
      'scrolls the floating position into view without selecting it',
      (tester) async {
        controller.document.insert(0, List.filled(40, 'Hello world\n').join());
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);
        final editorState = await pumpEditor(
          tester,
          height: 150,
          scrollController: scrollController,
        );
        editorState
          ..updateFloatingCursor(
            RawFloatingCursorPoint(
              offset: Offset.zero,
              state: FloatingCursorDragState.Start,
            ),
          )
          ..updateFloatingCursor(
            RawFloatingCursorPoint(
              offset: const Offset(0, 400),
              state: FloatingCursorDragState.Update,
            ),
          );
        await tester.pumpAndSettle();
        expect(scrollController.offset, greaterThan(0));
        expect(controller.selection, const TextSelection.collapsed(offset: 0));
        final position = editorState.renderEditor.floatingCursorTextPosition;
        final rect = editorState.renderEditor.getLocalRectForCaret(position);
        expect(rect.top, greaterThanOrEqualTo(scrollController.offset));
        expect(rect.bottom, lessThanOrEqualTo(scrollController.offset + 150));
        editorState.updateFloatingCursor(
          RawFloatingCursorPoint(state: FloatingCursorDragState.End),
        );
        await tester.pumpAndSettle();
        expect(controller.selection, TextSelection.fromPosition(position));
      },
    );

    testWidgets('clears the left-edge origin before the next gesture', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      final renderEditor = editorState.renderEditor;
      const position = TextPosition(offset: 0);
      renderEditor
        ..setFloatingCursor(
          FloatingCursorDragState.Start,
          Offset.zero,
          position,
        )
        ..calculateBoundedFloatingCursorOffset(const Offset(10, 10), 20)
        ..calculateBoundedFloatingCursorOffset(const Offset(-20, 10), 20)
        ..setFloatingCursor(FloatingCursorDragState.End, Offset.zero, position)
        ..setFloatingCursor(
          FloatingCursorDragState.Start,
          Offset.zero,
          position,
        )
        ..calculateBoundedFloatingCursorOffset(const Offset(20, 10), 20);
      expect(
        renderEditor
            .calculateBoundedFloatingCursorOffset(const Offset(30, 10), 20)
            .dx,
        30,
      );
      renderEditor.setFloatingCursor(
        FloatingCursorDragState.End,
        Offset.zero,
        position,
      );
    });

    testWidgets('paints the floating cursor at the editor paint offset', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      final renderEditor = editorState.renderEditor;
      const position = TextPosition(offset: 3);
      const boundedOffset = Offset(40, 10);
      const paintOffset = Offset(25, 75);
      renderEditor.setFloatingCursor(
        FloatingCursorDragState.Start,
        boundedOffset,
        position,
      );
      final child = renderEditor.childAtPosition(position);
      final prototype = child.getCaretPrototype(
        child.globalToLocalPosition(position),
      );
      final floatingRect = const EdgeInsets.fromLTRB(
        0.5,
        1,
        0.5,
        1,
      ).inflateRect(prototype).shift(boundedOffset + paintOffset);
      expect(
        (PaintingContext context, Offset offset) =>
            renderEditor.paint(context, paintOffset),
        paints..rrect(
          rrect: RRect.fromRectAndRadius(
            floatingRect,
            const Radius.circular(1),
          ),
        ),
      );
      renderEditor.setFloatingCursor(
        FloatingCursorDragState.End,
        Offset.zero,
        position,
      );
    });

    testWidgets('accepts a start without an offset', (tester) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      editorState
        ..updateFloatingCursor(
          RawFloatingCursorPoint(state: FloatingCursorDragState.Start),
        )
        ..updateFloatingCursor(
          RawFloatingCursorPoint(
            offset: const Offset(60, 0),
            state: FloatingCursorDragState.Update,
          ),
        );
      final position = editorState.renderEditor.floatingCursorTextPosition;
      expect(position.offset, greaterThan(0));
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pumpAndSettle();
      expect(controller.selection, TextSelection.fromPosition(position));
    });

    testWidgets('a new gesture cancels the previous reset animation', (
      tester,
    ) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);
      editorState
        ..updateFloatingCursor(
          RawFloatingCursorPoint(
            offset: Offset.zero,
            state: FloatingCursorDragState.Start,
          ),
        )
        ..updateFloatingCursor(
          RawFloatingCursorPoint(
            offset: const Offset(60, 0),
            state: FloatingCursorDragState.Update,
          ),
        )
        ..updateFloatingCursor(
          RawFloatingCursorPoint(state: FloatingCursorDragState.End),
        );
      expect(editorState.floatingCursorResetController.isAnimating, isTrue);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: Offset.zero,
          state: FloatingCursorDragState.Start,
        ),
      );
      expect(editorState.floatingCursorResetController.isAnimating, isFalse);
      expect(editorState.renderEditor.floatingCursorTextPosition.offset, 0);
      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pumpAndSettle();

      expect(controller.selection, const TextSelection.collapsed(offset: 0));
      expect(editorState.renderEditor, isNot(paints..rrect()));
    });

    testWidgets('ignores an update without a start', (tester) async {
      controller.document.insert(0, 'Hello world');
      final editorState = await pumpEditor(tester);

      editorState.updateFloatingCursor(
        RawFloatingCursorPoint(
          offset: const Offset(20, 0),
          state: FloatingCursorDragState.Update,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

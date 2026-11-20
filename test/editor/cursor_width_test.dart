import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cursorWidth preserves the default and copyWith override', () {
    const config = QuillEditorConfig();
    expect(config.cursorWidth, 2.0);
    expect(config.copyWith(cursorWidth: 1).cursorWidth, 1.0);
    expect(config.copyWith(cursorWidth: 1).copyWith().cursorWidth, 1.0);
    expect(config.copyWith(cursorWidth: 0).cursorWidth, 0);
  });

  test('cursorWidth rejects negative and non-finite values', () {
    for (final width in [
      -1.0,
      double.infinity,
      double.negativeInfinity,
      double.nan,
    ]) {
      expect(() => QuillEditorConfig(cursorWidth: width), throwsAssertionError);
      expect(
        () => const QuillEditorConfig().copyWith(cursorWidth: width),
        throwsAssertionError,
      );
    }
  });

  for (final direction in TextDirection.values) {
    testWidgets(
      '$direction applies and updates caret geometry across lines',
      (tester) async {
        final controller = QuillController.basic();
        final focusNode = FocusNode();
        final scrollController = ScrollController();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);
        addTearDown(scrollController.dispose);
        controller.document.insert(0, 'Sample\nטקסט');

        Widget editor(double width) => MaterialApp(
          localizationsDelegates:
              FlutterQuillLocalizations.localizationsDelegates,
          home: Directionality(
            textDirection: direction,
            child: QuillEditor(
              controller: controller,
              focusNode: focusNode,
              scrollController: scrollController,
              config: QuillEditorConfig(cursorWidth: width),
            ),
          ),
        );

        for (final width in [2.0, 1.0, 0.0]) {
          controller.updateSelection(
            const TextSelection.collapsed(offset: 2),
            ChangeSource.local,
          );
          await tester.pump();
          await tester.pumpWidget(editor(width));
          focusNode.requestFocus();
          await tester.pump();
          expect(focusNode.hasFocus, isTrue);
          final rawEditor = tester.widget<QuillRawEditor>(
            find.byType(QuillRawEditor),
          );
          expect(rawEditor.config.cursorStyle.width, width);
          final state = tester.state<QuillRawEditorState>(
            find.byType(QuillRawEditor),
          );
          for (final offset in [2, 9]) {
            controller.updateSelection(
              TextSelection.collapsed(offset: offset),
              ChangeSource.local,
            );
            await tester.pump();
            final position = TextPosition(offset: offset);
            final line = state.renderEditor.childAtPosition(position);
            final prototype = line.getCaretPrototype(
              line.globalToLocalPosition(position),
            );
            expect(prototype.width, width);
            expect(prototype.height, greaterThan(0));
            final caret = state.renderEditor.getLocalRectForCaret(position);
            final nextCaret = state.renderEditor.getLocalRectForCaret(
              TextPosition(offset: offset + 1),
            );
            expect(caret.width, closeTo(width, 1e-10));
            expect(caret.isFinite, isTrue);
            expect(
              nextCaret.left,
              offset == 2 ? greaterThan(caret.left) : lessThan(caret.left),
            );
          }
        }

        await tester.pumpWidget(const SizedBox.shrink());
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.iOS,
      }),
    );
  }
}

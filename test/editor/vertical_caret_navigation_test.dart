import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression tests for vertical caret navigation (arrow up/down).
//
// Covered fixes:
//  1. TextAffinity used to be dropped while walking up/down through
//     RenderEditor/RenderEditableTextBlock, so at a soft line-wrap boundary
//     the caret started from (or landed on) the wrong visual line.
//  2. QuillVerticalCaretMovementRun did not remember the "goal column":
//     crossing a short or empty line permanently clamped the caret to that
//     line's column, instead of restoring the original column on the next
//     line (the behavior of Flutter's TextField and of every major editor).
//  3. The cached vertical movement run was never invalidated on the web
//     (early return in _didChangeTextEditingValue), so after repositioning
//     the caret with a mouse click the next arrow key would continue from
//     the stale position.
void main() {
  late QuillController controller;

  Future<void> pumpEditor(WidgetTester tester, Document document) async {
    controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(autoFocus: true),
          ),
        ),
      ),
    );
    // Let the editor's autofocus zero-duration timer fire.
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> pressArrow(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  group('goal column is kept across short and empty lines', () {
    testWidgets('arrow down through an empty line restores the column',
        (tester) async {
      // Three paragraphs: long / empty / long. Caret at column 10.
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'first long paragraph\n\nthird long paragraph\n'},
        ]),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 10),
        ChangeSource.local,
      );
      await tester.pump();

      // Down: the empty line (offset 21, its only position).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 21,
          reason: 'first arrow down should stop on the empty line');

      // Down again: must RETURN to column 10 of the third line
      // (offset 22 + 10 = 32), not stay clamped to column 0.
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 32,
          reason: 'the goal column must survive crossing an empty line');
    });

    testWidgets('arrow up through an empty line restores the column',
        (tester) async {
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'first long paragraph\n\nthird long paragraph\n'},
        ]),
      );
      // Caret at column 10 of the third line (offset 22 + 10 = 32).
      controller.updateSelection(
        const TextSelection.collapsed(offset: 32),
        ChangeSource.local,
      );
      await tester.pump();

      await pressArrow(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selection.baseOffset, 21,
          reason: 'first arrow up should stop on the empty line');

      await pressArrow(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selection.baseOffset, 10,
          reason: 'the goal column must survive crossing an empty line');
    });

    testWidgets('arrow down through a shorter line restores the column',
        (tester) async {
      // "abcdefghijklmno" (15) / "xy" (2) / "abcdefghijklmno" (15)
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'abcdefghijklmno\nxy\nabcdefghijklmno\n'},
        ]),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 12),
        ChangeSource.local,
      );
      await tester.pump();

      // Down: "xy" is shorter, the caret clamps to its end (offset 18).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 18,
          reason: 'on the short line the caret clamps to the line end');

      // Down again: back to column 12 of the third line (19 + 12 = 31).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 31,
          reason: 'the goal column must survive crossing a shorter line');
    });

    testWidgets('arrow down through an empty list item restores the column',
        (tester) async {
      // Bullet list: "list item one" / empty item / "list item two".
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'list item one'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {'insert': 'list item two'},
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
        ]),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 8),
        ChangeSource.local,
      );
      await tester.pump();

      // Down: the empty item (offset 14).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 14,
          reason: 'first arrow down should stop on the empty list item');

      // Down again: column 8 of the third item (15 + 8 = 23).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 23,
          reason: 'the goal column must survive crossing an empty list item');
    });
  });

  group('repositioning the caret during an arrow-key sequence', () {
    testWidgets(
        'after a selection change the next arrow starts from the new position',
        (tester) async {
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'line number one\nline number two\nline number three\n'},
        ]),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 5),
        ChangeSource.local,
      );
      await tester.pump();

      // Start a vertical movement run (the action caches it).
      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 21); // 16 + 5

      // Simulate a tap elsewhere: the selection changes outside the run.
      controller.updateSelection(
        const TextSelection.collapsed(offset: 40), // line three, column 8
        ChangeSource.local,
      );
      await tester.pump();

      // Arrow up must start from offset 40 (line three) and land on line
      // two, column 8 = 16 + 8 = 24. With a stale cached run it would
      // continue from offset 21 instead.
      await pressArrow(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selection.baseOffset, 24,
          reason: 'a selection change must invalidate the cached run');
    });
  });

  group('plain vertical navigation (sanity)', () {
    testWidgets('down and up between equal-length lines keeps the column',
        (tester) async {
      await pumpEditor(
        tester,
        Document.fromJson([
          {'insert': 'line number one\nline number two\n'},
        ]),
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 5),
        ChangeSource.local,
      );
      await tester.pump();

      await pressArrow(tester, LogicalKeyboardKey.arrowDown);
      expect(controller.selection.baseOffset, 21); // 16 + 5

      await pressArrow(tester, LogicalKeyboardKey.arrowUp);
      expect(controller.selection.baseOffset, 5);
    });
  });
}

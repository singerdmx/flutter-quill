import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterCursorMovementExtension on WidgetTester {
  /// Updates the text editing value to move the cursor to the specified [index],
  /// as if it had been provided by the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// await tester.quillMoveCursorTo(find.byType(QuillEditor), 5); // Move cursor to index 5
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillMoveCursorTo(Finder finder, int index) async {
    final editor = findRawEditor(finder);
    return TestAsyncUtils.guard(() async {
      testTextInput.updateEditingValue(
        TextEditingValue(
          text: editor.textEditingValue.text,
          selection: TextSelection.collapsed(
            offset: index,
          ),
        ),
      );
      await idle();
    });
  }

  /// Updates the text editing value to expand the current selection to the specified
  /// [index], as if it had been provided by the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// await quillExpandSelectionTo(find.byType(QuillEditor), 10); // Expand selection to index 10
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillExpandSelectionTo(Finder finder, int index) async {
    final editor = findRawEditor(finder);
    return TestAsyncUtils.guard(() async {
      testTextInput.updateEditingValue(
        TextEditingValue(
          text: editor.textEditingValue.text,
          selection: editor.textEditingValue.selection.expandTo(
            TextPosition(offset: index),
          ),
        ),
      );
      await idle();
    });
  }

  /// Updates the [selection] of the current text editing value to the range
  /// specified by [from] and [to], as if it had been provided by the onscreen
  /// keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// await quillUpdateSelection(
  ///   find.byType(QuillEditor),
  ///   5, // Start of selection
  ///   10, // End of selection
  /// );
  /// ```
  Future<void> quillUpdateSelection(Finder finder, int from, int to) async {
    final editor = findRawEditor(finder);
    expect(from, isNonNegative);
    expect(to, isNonNegative);
    return TestAsyncUtils.guard(() async {
      testTextInput.updateEditingValue(
        TextEditingValue(
          text: editor.textEditingValue.text,
          selection: TextSelection(baseOffset: from, extentOffset: to),
        ),
      );
      await idle();
    });
  }
}

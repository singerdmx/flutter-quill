import 'package:flutter/material.dart'
    show TextEditingValue, TextPosition, TextSelection;
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterCursorMovementExtension on WidgetTester {
  /// Update the text editing value to modify just the [selection], as if it had been
  /// provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
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

  /// Update the text editing value to modify just the [selection] to expand it until the index passed,
  /// as if it had been provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
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

  /// Update the [selection] of the current text editing value,
  /// with the given [from] and [to] values, as if it had
  /// been provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
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

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterReplaceExt on WidgetTester {
  /// Replaces the text within the specified [selection] with the [replacement] text.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillReplaceTextWithSelection(
  ///   find.byType(QuillEditor),
  ///   'new text',
  ///   TextSelection(baseOffset: 5, extentOffset: 10),
  /// );
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillReplaceTextWithSelection(
      Finder finder, String replacement, TextSelection selection) async {
    final editor = findRawEditor(finder);
    expect(selection.isValid, isTrue,
        reason: 'The selection in the editor is not valid');
    final effectivePlainText = editor.controller.document
        .toPlainText()
        .replaceRange(
            selection.baseOffset, selection.extentOffset, replacement);
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValueWithSelection(
        finder,
        effectivePlainText,
        TextSelection.collapsed(
          offset: selection.baseOffset + replacement.length,
        ),
      );
      await idle();
    });
  }

  /// Replaces the text within the current selection with the [replacement] text.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillReplaceText(
  ///   find.byType(QuillEditor),
  ///   'new text',
  /// );
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillReplaceText(Finder finder, String replacement) async {
    final editor = findRawEditor(finder);
    final selection = editor.controller.selection;
    expect(selection.isValid, isTrue,
        reason: 'The selection in the editor is not valid');
    final effectivePlainText = editor.controller.document
        .toPlainText()
        .replaceRange(
            selection.baseOffset, selection.extentOffset, replacement);
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValueWithSelection(
        finder,
        effectivePlainText,
        TextSelection.collapsed(
          offset: selection.baseOffset + replacement.length,
        ),
      );
      await idle();
    });
  }
}

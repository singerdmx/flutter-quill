import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_test/flutter_test.dart';
import 'widget_tester_extension.dart';

extension QuillWidgetTesterReplaceExt on WidgetTester {
  /// Give the QuillEditor widget specified by [finder] the focus and replace current the current text
  /// in the document with the [selection] passed.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
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

  /// Give the QuillEditor widget specified by [finder] the focus and replace current text
  /// in document with the current [selection] in the QuillEditor.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
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

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterRemoveExt on WidgetTester {
  /// Give the QuillEditor widget specified by [finder] the focus and remove current text
  /// in document with the current [selection] in the QuillEditor.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
  Future<void> quillRemoveTextInSelection(Finder finder) async {
    final editor = findRawEditor(finder);
    final selection = editor.controller.selection;
    // we cannot removed selected text is there's not selection
    expect(selection.isCollapsed, isFalse);
    expect(selection.isValid, isTrue);
    final plainTextRemoved = editor.controller.document
        .toPlainText()
        .replaceRange(selection.baseOffset, selection.extentOffset, '');
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValueWithSelection(
        finder,
        plainTextRemoved,
        TextSelection.collapsed(
          offset: selection.baseOffset,
        ),
      );
      await idle();
    });
  }

  /// Give the QuillEditor widget specified by [finder] the focus and removed current its
  /// editing value with [selection], as if it had been provided by the onscreen
  /// keyboard.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
  Future<void> quillRemoveText(Finder finder, TextSelection selection) async {
    expect(selection.isValid, isTrue,
        reason: 'the selection passed for remove text is not valid to be used');
    final editor = findRawEditor(finder);
    final plainTextRemoved = editor.controller.document
        .toPlainText()
        .replaceRange(selection.baseOffset, selection.extentOffset, '');
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValueWithSelection(
        finder,
        plainTextRemoved,
        TextSelection.collapsed(offset: selection.baseOffset),
      );
      await idle();
    });
  }
}

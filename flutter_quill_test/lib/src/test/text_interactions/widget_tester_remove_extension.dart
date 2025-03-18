import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterRemoveExt on WidgetTester {
  /// Removes the text currently selected in the document.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillRemoveTextInSelection(find.byType(QuillEditor));
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillRemoveTextInSelection(Finder finder) async {
    final editor = findRawEditor(finder);
    final selection = editor.controller.selection;
    // We cannot remove selected text if there's no selection
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

  /// Removes the text specified by [selection], as if it had been deleted
  /// using the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillRemoveText(
  ///   find.byType(QuillEditor),
  ///   TextSelection(baseOffset: 5, extentOffset: 10),
  /// );
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillRemoveText(Finder finder, TextSelection selection) async {
    expect(selection.isValid, isTrue,
        reason: 'The selection passed for removing text is not valid');
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

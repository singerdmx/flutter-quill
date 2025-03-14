import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterInsertionExt on WidgetTester {
  /// Give the QuillEditor widget specified by [finder] the focus and update its
  /// editing value with [text], as if it had been provided by the onscreen
  /// keyboard.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
  Future<void> quillEnterText(Finder finder, String text) async {
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValue(finder, text);
      await idle();
    });
  }

  /// Give the QuillEditor widget specified by [finder] the focus and insert the text
  /// at the [index] passed, updating its editing value with [text], as if it
  /// had been provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  ///
  Future<void> quillEnterTextAtPosition(
      Finder finder, String textInsert, int index) async {
    expect(index, isNonNegative,
        reason: 'Index passed cannot be less than zero');
    final editor = findRawEditor(finder);
    final plainText = editor.controller.document
        .toPlainText()
        .replaceRange(index, index, textInsert);
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValueWithSelection(
        finder,
        plainText,
        TextSelection.collapsed(offset: index + textInsert.length),
      );
      await idle();
    });
  }
}

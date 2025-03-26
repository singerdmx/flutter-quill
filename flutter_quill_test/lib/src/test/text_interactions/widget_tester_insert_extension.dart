import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import '../widget_tester_extension.dart';

extension QuillWidgetTesterInsertionExt on WidgetTester {
  /// Updates its editing value with the provided [text], as if it had been
  /// entered via the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillEnterText(find.byType(QuillEditor), 'Hello, world!');
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillEnterText(Finder finder, String text) async {
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValue(finder, text);
      await idle();
    });
  }

  /// Inserts [textInsert] at the specified [index], updating its editing value
  /// as if it had been provided by the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillEnterTextAtPosition(
  ///   find.byType(QuillEditor),
  ///   'inserted text',
  ///   5, // Insert at index 5
  /// );
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
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

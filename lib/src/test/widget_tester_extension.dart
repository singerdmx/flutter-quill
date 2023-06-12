import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widgets/editor.dart';
import '../widgets/raw_editor.dart';

/// Extends
extension QuillEnterText on WidgetTester {
  /// Give the QuillEditor widget specified by [finder] the focus.
  Future<void> quillGiveFocus(Finder finder) {
    return TestAsyncUtils.guard(() async {
      final editor = state<QuillEditorState>(
        find.descendant(
            of: finder,
            matching:
                find.byType(QuillEditor, skipOffstage: finder.skipOffstage),
            matchRoot: true),
      );
      editor.widget.focusNode.requestFocus();
      await pump();
      expect(editor.widget.focusNode.hasFocus, isTrue);
    });
  }

  /// Give the QuillEditor widget specified by [finder] the focus and update its
  /// editing value with [text], as if it had been provided by the onscreen
  /// keyboard.
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or have a
  /// [QuillEditor] descendant. For example `find.byType(QuillEditor)`.
  Future<void> quillEnterText(Finder finder, String text) async {
    return TestAsyncUtils.guard(() async {
      await quillGiveFocus(finder);
      await quillUpdateEditingValue(finder, text);
      await idle();
    });
  }

  /// Update the text editing value of the QuillEditor widget specified by
  /// [finder] with [text], as if it had been provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  Future<void> quillUpdateEditingValue(Finder finder, String text) async {
    return TestAsyncUtils.guard(() async {
      final editor = state<RawEditorState>(
        find.descendant(
            of: finder,
            matching: find.byType(RawEditor, skipOffstage: finder.skipOffstage),
            matchRoot: true),
      );
      testTextInput.updateEditingValue(TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
              offset: editor.textEditingValue.text.length)));
      await idle();
    });
  }
}

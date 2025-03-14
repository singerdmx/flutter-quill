import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extensions on [WidgetTester] that have utilities that help
/// simplify interacting with the editor in test cases.
extension QuillWidgetTesterExt on WidgetTester {
  /// Give the QuillEditor widget specified by [finder] the focus.
  ///
  Future<void> quillGiveFocus(Finder finder) {
    return TestAsyncUtils.guard(() async {
      final editor = findEditor(finder);
      editor.widget.focusNode.requestFocus();
      await pump();
      expect(
        editor.widget.focusNode.hasFocus,
        isTrue,
      );
    });
  }

  /// Checks if the editor has focus.
  ///
  Future<bool> quillHasFocusEditor(Finder finder) {
    return TestAsyncUtils.guard(() async {
      final editor = findEditor(finder);
      return editor.widget.focusNode.hasFocus;
    });
  }

  /// Update the text editing value of the QuillEditor widget specified by
  /// [finder] with [text] and [selection], as if it had been
  /// provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  Future<void> quillUpdateEditingValueWithSelection(
      Finder finder, String text, TextSelection selection) async {
    expect(selection.isValid, isTrue,
        reason:
            'The TextSelection passed is not valid to be used for text editing values');
    return TestAsyncUtils.guard(() async {
      testTextInput.updateEditingValue(
        TextEditingValue(
          text: text,
          selection: selection,
        ),
      );
      await idle();
    });
  }

  /// Update the text editing value of the QuillEditor widget specified by
  /// [finder] with [text], as if it had been provided by the onscreen keyboard.
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  Future<void> quillUpdateEditingValue(Finder finder, String text) async {
    return TestAsyncUtils.guard(() async {
      final editor = findRawEditor(finder);
      testTextInput.updateEditingValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
              offset: editor.textEditingValue.text.length),
        ),
      );
      await idle();
    });
  }

  /// Find the QuillRawEditorState
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  QuillRawEditorState findRawEditor([Finder? finder]) {
    return state<QuillRawEditorState>(
      find.descendant(
        of: finder ?? find.byType(QuillEditor),
        matching:
            find.byType(QuillRawEditor, skipOffstage: finder?.skipOffstage ?? true),
        matchRoot: true,
      ),
    );
  }

  /// Find the QuillEditorState
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  QuillEditorState findEditor([Finder? finder]) {
    return state<QuillEditorState>(
      find.descendant(
        of: finder ?? find.byType(QuillEditor),
        matching: find.byType(
          QuillEditor,
          skipOffstage: finder?.skipOffstage ?? true,
        ),
        matchRoot: true,
      ),
    );
  }
}

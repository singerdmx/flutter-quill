import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extensions on [WidgetTester] that have utilities that help
/// simplify interacting with the editor in test cases.
extension QuillWidgetTesterExt on WidgetTester {
  /// Gives focus to the [QuillEditor] widget specified by [finder].
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// ```
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

  /// Checks if the [QuillEditor] widget specified by [finder] currently has focus.
  ///
  /// Example:
  /// ```dart
  /// final hasFocus = await tester.quillHasFocusEditor(find.byType(QuillEditor));
  /// ```
  Future<bool> quillHasFocusEditor(Finder finder) {
    return TestAsyncUtils.guard(() async {
      final editor = findEditor(finder);
      return editor.widget.focusNode.hasFocus;
    });
  }

  /// Retrieves the current text editing value from the [QuillRawEditor].
  ///
  /// Example:
  /// ```dart
  /// final value = await tester.getTextEditingValue(find.byType(QuillEditor));
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<TextEditingValue> getTextEditingValue([Finder? finder]) async {
    final editor = findRawEditor(finder);
    return editor.textEditingValue.copyWith();
  }

  /// Simulates the user hiding the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillHideKeyboard(find.byType(QuillEditor));
  /// ```
  ///
  /// The widget specified by [finder] must be a [QuillEditor] or
  /// have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  Future<void> quillHideKeyboard(Finder finder) async {
    return TestAsyncUtils.guard<void>(() async {
      await quillGiveFocus(finder);
      testTextInput.hide();
      await idle();
    });
  }

  /// Updates the text editing value of the [QuillEditor] widget specified by
  /// [finder] with the provided [text] and [selection], as if it had been
  /// entered via the onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// await tester.quillUpdateEditingValueWithSelection(
  ///   find.byType(QuillEditor),
  ///   'Hello, world!',
  ///   TextSelection.collapsed(offset: 13),
  /// );
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
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

  /// Updates the text editing value of the [QuillEditor] widget specified by
  /// [finder] with the provided [text], as if it had been entered via the
  /// onscreen keyboard.
  ///
  /// Example:
  /// ```dart
  /// await tester.quillGiveFocus(find.byType(QuillEditor));
  /// await tester.quillUpdateEditingValue(find.byType(QuillEditor), 'Hello, world!');
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
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

  /// Finds and returns the [QuillRawEditorState] associated with the [QuillEditor]
  /// widget specified by [finder].
  ///
  /// Example:
  /// ```dart
  /// final rawEditorState = tester.findRawEditor(find.byType(QuillEditor));
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
  QuillRawEditorState findRawEditor([Finder? finder]) {
    return state<QuillRawEditorState>(
      find.descendant(
        of: finder ?? find.byType(QuillEditor),
        matching: find.byType(QuillRawEditor,
            skipOffstage: finder?.skipOffstage ?? true),
        matchRoot: true,
      ),
    );
  }

  /// Finds and returns the [QuillEditorState] associated with the [QuillEditor]
  /// widget specified by [finder].
  ///
  /// Example:
  /// ```dart
  /// final editorState = tester.findEditor(find.byType(QuillEditor));
  /// ```
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example:
  /// ```dart
  /// find.byType(QuillEditor)
  /// ```
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

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../flutter_quill_test.dart';

extension QuillWidgetTesterToolbarExtension on WidgetTester {
  Future<void> pressBoldToolbarOption(Finder editorFinder) async {
    final toolbar = find.byType(QuillSimpleToolbar);
    expect(toolbar, findsAtLeast(1));
    final button = await _getButtonOption(
      Attribute.bold,
    );
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      await _ensureEditorContainsNonCollapsedSelection(editorFinder);
    });
    expect(button, findsOneWidget);
    await tap(button.last);
    await pumpAndSettle();
  }

  Future<void> pressItalicToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      await _ensureEditorContainsNonCollapsedSelection(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.italic,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressUnderlineToolbarOption(Finder editorFinder,
      [Finder? buttonFinder]) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      await _ensureEditorContainsNonCollapsedSelection(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.underline,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressStrikethroughToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      await _ensureEditorContainsNonCollapsedSelection(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.strikeThrough,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressFontFamilyToolbarOption(
      Finder editorFinder, String fontFamily) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      await _ensureEditorContainsNonCollapsedSelection(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        FontAttribute(fontFamily),
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressHeaderToolbarOption(
      Finder editorFinder, int? header) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        HeaderAttribute(level: header),
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressAlignmentToolbarOption(
      Finder editorFinder, String? align) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        AlignAttribute(align),
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressIndentToolbarOption(
      Finder editorFinder, int? indent) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        IndentAttribute(level: indent),
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressCodeblockToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.codeBlock,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressBlockquoteToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.blockQuote,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressOrderedListToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.ol,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressBulletListToolbarOption(Finder editorFinder) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        Attribute.ul,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  Future<void> pressCheckListToolbarOption(
      Finder editorFinder, bool checked) async {
    await TestAsyncUtils.guard(() async {
      await quillGiveFocus(editorFinder);
      final toolbar = find.byType(QuillSimpleToolbar);
      expect(toolbar, findsAtLeast(1));
      final button = await _getButtonOption(
        checked ? Attribute.checked : Attribute.unchecked,
      );
      expect(button, findsOneWidget);
      await tap(button);
      await pumpAndSettle();
    });
  }

  /// Find the correct button for the passed Attribute
  Future<Finder> _getButtonOption(Attribute matchAttribute) async {
    final buttonWidget = find.byWidgetPredicate((widget) {
      final isToggleButton = widget is QuillToolbarToggleStyleButton &&
          (widget.attribute == matchAttribute ||
              widget.attribute.key == matchAttribute.key);
      if (isToggleButton) {
        return true;
      }
      if (widget is QuillToolbarFontFamilyButton) {}
      return false;
    });
    return buttonWidget;
  }

  Future<void> _ensureEditorContainsNonCollapsedSelection(
      Finder editorFinder) async {
    final editor = findRawEditor(editorFinder);
    expect(
      editor.textEditingValue.selection.isValid,
      isTrue,
      reason:
          'The selection cannot be used to format text segments since is not valid',
    );
    expect(
      editor.textEditingValue.selection.isCollapsed,
      isFalse,
      reason: 'The current selection must not be collapsed',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('copy', () {
    const testDocumentContents = 'data';
    late QuillController controller;

    setUp(() {
      controller = QuillController.basic()
        ..compose(Delta()..insert(testDocumentContents),
            const TextSelection.collapsed(offset: 0), ChangeSource.local);
    });

    test('clipboardSelection empty', () {
      expect(controller.clipboardSelection(true), false,
          reason: 'No effect when no selection');
      expect(controller.clipboardSelection(false), false);
    });

    test('clipboardSelection', () {
      controller
        ..replaceText(0, 4, 'bold plain italic', null)
        ..formatText(0, 4, Attribute.bold)
        ..formatText(11, 17, Attribute.italic)
        ..updateSelection(const TextSelection(baseOffset: 2, extentOffset: 14),
            ChangeSource.local);
      //
      expect(controller.clipboardSelection(true), true);
      expect(controller.document.length, 18,
          reason: 'Copy does not change the document');
      expect(controller.clipboardSelection(false), true);
      expect(controller.document.length, 6, reason: 'Cut changes the document');
      //
      controller
        ..readOnly = true
        ..updateSelection(const TextSelection(baseOffset: 2, extentOffset: 4),
            ChangeSource.local);
      expect(controller.selection.isCollapsed, false);
      expect(controller.clipboardSelection(true), true);
      expect(controller.document.length, 6);
      expect(controller.clipboardSelection(false), false);
      expect(controller.document.length, 6,
          reason: 'Cut not permitted on readOnly document');
    });
  });

  group('paste', () {
    test('Plain', () async {
      final controller = QuillController.basic()
        ..compose(Delta()..insert('[]'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(
            const TextSelection.collapsed(offset: 1), ChangeSource.local);
      //
      expect(controller.document.toPlainText(), '[]\n');
      expect(controller.pasteUsingPlainOrDelta('insert'), true);
      expect(controller.document.toPlainText(), '[insert]\n');
    });

    test('Plain lines', () async {
      final controller = QuillController.basic()
        ..compose(Delta()..insert('[]'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(
            const TextSelection.collapsed(offset: 1), ChangeSource.local);
      //
      expect(controller.document.toPlainText(), '[]\n');
      expect(controller.pasteUsingPlainOrDelta('1\n2\n3\n'), true);
      expect(controller.document.toPlainText(), '[1\n2\n3\n]\n');
    });

    test('Paste from external', () async {
      final source = QuillController.basic()
        ..compose(Delta()..insert('Plain text'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(const TextSelection(baseOffset: 4, extentOffset: 8),
            ChangeSource.local);
      assert(source.clipboardSelection(true));
      expect(source.pastePlainText, 'n te');
      //
      final controller = QuillController.basic()
        ..compose(Delta()..insert('[]'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(
            const TextSelection.collapsed(offset: 1), ChangeSource.local);
      //
      expect(controller.pasteUsingPlainOrDelta('insert'), true,
          reason: 'External paste');
      expect(controller.document.toPlainText(), '[insert]\n');
    });

    test('Delta simple', () async {
      final source = QuillController.basic()
        ..compose(Delta()..insert('Plain text'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..formatText(6, 8, Attribute.bold)
        ..updateSelection(const TextSelection(baseOffset: 4, extentOffset: 8),
            ChangeSource.local);
      assert(source.clipboardSelection(true));
      expect(source.pastePlainText, 'n te');
      expect(
          source.pasteDelta,
          Delta()
            ..insert('n ')
            ..insert('te', {'bold': true}));
      //
      final controller = QuillController.basic()
        ..compose(Delta()..insert('[]'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(
            const TextSelection.collapsed(offset: 1), ChangeSource.local);
      //
      expect(controller.pasteUsingPlainOrDelta('n te'), true,
          reason: 'Internal paste');
      expect(controller.document.toPlainText(), '[n te]\n');
      expect(
          controller.document.toDelta(),
          Delta()
            ..insert('[n ')
            ..insert('te', {'bold': true})
            ..insert(']\n'));
      expect(controller.selection, const TextSelection.collapsed(offset: 5));
    });

    test('Delta multi line', () async {
      const blockAttribute = Attribute.ol;
      const plainSelection = 'BC\nDEF\nGHI\nJK';
      final source = QuillController.basic()
        ..compose(Delta()..insert('ABC\nDEF\nGHI\nJKL'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..formatText(1, 1, Attribute.underline) // ABC with B underlined
        ..formatText(4, 0, blockAttribute) // 1. DEF with E in italic
        ..formatText(5, 1, Attribute.italic)
        ..formatText(8, 0, blockAttribute) // 2. GHI with H as inline code
        ..formatText(9, 1, Attribute.inlineCode)
        ..formatText(13, 1, Attribute.strikeThrough) // JKL with K strikethrough
        ..updateSelection(const TextSelection(baseOffset: 1, extentOffset: 14),
            ChangeSource.local);
      //
      assert(source.clipboardSelection(true));
      expect(source.pastePlainText, plainSelection);
      expect(
          source.pasteDelta,
          Delta()
            ..insert('B', {'underline': true})
            ..insert('C\nD')
            ..insert('E', {'italic': true})
            ..insert('F')
            ..insert('\n', {'list': 'ordered'})
            ..insert('G')
            ..insert('H', {'code': true})
            ..insert('I')
            ..insert('\n', {'list': 'ordered'})
            ..insert('J')
            ..insert('K', {'strike': true}));
      //
      final controller = QuillController.basic()
        ..compose(Delta()..insert('[]'),
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..updateSelection(
            const TextSelection.collapsed(offset: 1), ChangeSource.local);
      //
      expect(controller.pasteUsingPlainOrDelta(plainSelection), true,
          reason: 'Internal paste');
      expect(controller.document.toPlainText(), '[$plainSelection]\n');
      expect(
          controller.document.toDelta(),
          Delta()
            ..insert('[')
            ..insert('B', {'underline': true})
            ..insert('C\nD')
            ..insert('E', {'italic': true})
            ..insert('F')
            ..insert('\n', {'list': 'ordered'})
            ..insert('G')
            ..insert('H', {'code': true})
            ..insert('I')
            ..insert('\n', {'list': 'ordered'})
            ..insert('J')
            ..insert('K', {'strike': true})
            ..insert(']\n'));
      expect(controller.selection, const TextSelection.collapsed(offset: 14));
    });
  });
}

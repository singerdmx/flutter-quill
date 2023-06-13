import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testDocumentContents = 'data';
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic()
      ..compose(Delta()..insert(testDocumentContents),
          const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL);
  });

  group('controller', () {
    test('set document', () {
      const replacementContents = 'replacement\n';
      final newDocument =
          Document.fromDelta(Delta()..insert(replacementContents));
      var listenerCalled = false;
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..document = newDocument;
      expect(listenerCalled, isTrue);
      expect(controller.document.toPlainText(), replacementContents);
    });

    test('getSelectionStyle', () {
      controller
        ..formatText(0, 5, Attribute.h1)
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 4),
            ChangeSource.LOCAL);

      expect(controller.getSelectionStyle().values, [Attribute.h1]);
    });

    test('indentSelection with single line document', () {
      var listenerCalled = false;
      // With selection range
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 4),
            ChangeSource.LOCAL)
        ..addListener(() {
          listenerCalled = true;
        })
        ..indentSelection(true);
      expect(listenerCalled, isTrue);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);
      controller.indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL2]);
      controller.indentSelection(false);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);
      controller.indentSelection(false);
      expect(controller.getSelectionStyle().values, []);

      // With collapsed selection
      controller
        ..updateSelection(
            const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL)
        ..indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);
      controller
        ..updateSelection(
            const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL)
        ..indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL2]);
      controller.indentSelection(false);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);
      controller.indentSelection(false);
      expect(controller.getSelectionStyle().values, []);
    });

    test('indentSelection with multiline document', () {
      controller
        ..compose(Delta()..insert('line1\nline2\nline3\n'),
            const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL)
        // Indent first line
        ..updateSelection(
            const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL)
        ..indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);

      // Indent first two lines
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 11),
            ChangeSource.LOCAL)
        ..indentSelection(true);

      // Should have both L1 and L2 indent attributes in selection.
      expect(controller.getAllSelectionStyles(),
          contains(Style().put(Attribute.indentL1).put(Attribute.indentL2)));

      // Remaining lines should have no attributes.
      controller.updateSelection(
          TextSelection(
              baseOffset: 12,
              extentOffset: controller.document.toPlainText().length - 1),
          ChangeSource.LOCAL);
      expect(controller.getAllSelectionStyles(), everyElement(Style()));
    });

    test('getAllIndividualSelectionStyles', () {
      controller.formatText(0, 2, Attribute.bold);
      final result = controller.getAllIndividualSelectionStyles();
      expect(result.length, 1);
      expect(result[0].offset, 0);
      expect(result[0].value, Style().put(Attribute.bold));
    });

    test('getPlainText', () {
      controller.updateSelection(
          const TextSelection(baseOffset: 0, extentOffset: 4),
          ChangeSource.LOCAL);

      expect(controller.getPlainText(), testDocumentContents);
    });

    test('getAllSelectionStyles', () {
      controller.formatText(0, 2, Attribute.bold);
      expect(controller.getAllSelectionStyles(),
          contains(Style().put(Attribute.bold)));
    });

    test('undo', () {
      var listenerCalled = false;
      controller.updateSelection(
          const TextSelection.collapsed(offset: 4), ChangeSource.LOCAL);

      expect(controller.document.toDelta(), Delta()..insert('data\n'));
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..undo();
      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(), Delta()..insert('\n'));
    });

    test('redo', () {
      var listenerCalled = false;
      controller.updateSelection(
          const TextSelection.collapsed(offset: 4), ChangeSource.LOCAL);

      expect(controller.document.toDelta(), Delta()..insert('data\n'));
      controller.undo();
      expect(controller.document.toDelta(), Delta()..insert('\n'));
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..redo();
      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(), Delta()..insert('data\n'));
    });
    test('clear', () {
      var listenerCalled = false;
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..clear();

      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(), Delta()..insert('\n'));
    });

    test('replaceText', () {
      var listenerCalled = false;
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..replaceText(1, 2, '11', const TextSelection.collapsed(offset: 0));

      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(), Delta()..insert('d11a\n'));
    });

    test('formatTextStyle', () {
      var listenerCalled = false;
      final style = Style().put(Attribute.bold).put(Attribute.italic);
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..formatTextStyle(0, 2, style);
      expect(listenerCalled, isTrue);
      expect(controller.document.collectAllStyles(0, 2), contains(style));
      expect(controller.document.collectAllStyles(2, 4), everyElement(Style()));
    });

    test('formatText', () {
      var listenerCalled = false;
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..formatText(0, 2, Attribute.bold);
      expect(listenerCalled, isTrue);
      expect(controller.document.collectAllStyles(0, 2),
          contains(Style().put(Attribute.bold)));
      expect(controller.document.collectAllStyles(2, 4), everyElement(Style()));
    });

    test('formatSelection', () {
      var listenerCalled = false;
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 2),
            ChangeSource.LOCAL)
        ..addListener(() {
          listenerCalled = true;
        })
        ..formatSelection(Attribute.bold);
      expect(listenerCalled, isTrue);
      expect(controller.document.collectAllStyles(0, 2),
          contains(Style().put(Attribute.bold)));
      expect(controller.document.collectAllStyles(2, 4), everyElement(Style()));
    });

    test('moveCursorToStart', () {
      var listenerCalled = false;
      controller
        ..updateSelection(
            const TextSelection.collapsed(offset: 4), ChangeSource.LOCAL)
        ..addListener(() {
          listenerCalled = true;
        });
      expect(controller.selection, const TextSelection.collapsed(offset: 4));

      controller.moveCursorToStart();
      expect(listenerCalled, isTrue);
      expect(controller.selection, const TextSelection.collapsed(offset: 0));
    });

    test('moveCursorToPosition', () {
      var listenerCalled = false;
      controller.addListener(() {
        listenerCalled = true;
      });
      expect(controller.selection, const TextSelection.collapsed(offset: 0));

      controller.moveCursorToPosition(2);
      expect(listenerCalled, isTrue);
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
    });

    test('moveCursorToEnd', () {
      var listenerCalled = false;
      controller.addListener(() {
        listenerCalled = true;
      });
      expect(controller.selection, const TextSelection.collapsed(offset: 0));

      controller.moveCursorToEnd();
      expect(listenerCalled, isTrue);
      expect(controller.selection,
          TextSelection.collapsed(offset: controller.document.length - 1));
    });

    test('updateSelection', () {
      var listenerCalled = false;
      const selection = TextSelection.collapsed(offset: 0);
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..updateSelection(selection, ChangeSource.LOCAL);

      expect(listenerCalled, isTrue);
      expect(controller.selection, selection);
    });

    test('compose', () {
      var listenerCalled = false;
      final originalContents = controller.document.toPlainText();
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..compose(Delta()..insert('test '),
            const TextSelection.collapsed(offset: 0), ChangeSource.LOCAL);

      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(),
          Delta()..insert('test $originalContents'));
    });
  });
}

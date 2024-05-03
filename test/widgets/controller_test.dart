import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:test/test.dart';

void main() {
  const testDocumentContents = 'data';
  late QuillController controller;
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    controller = QuillController.basic()
      ..compose(Delta()..insert(testDocumentContents),
          const TextSelection.collapsed(offset: 0), ChangeSource.local);
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
            ChangeSource.local);

      expect(controller.getSelectionStyle().values, [Attribute.h1]);
    });

    test('indentSelection with single line document', () {
      var listenerCalled = false;
      // With selection range
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 4),
            ChangeSource.local)
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
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);
      controller
        ..updateSelection(
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
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
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        // Indent first line
        ..updateSelection(
            const TextSelection.collapsed(offset: 0), ChangeSource.local)
        ..indentSelection(true);
      expect(controller.getSelectionStyle().values, [Attribute.indentL1]);

      // Indent first two lines
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 11),
            ChangeSource.local)
        ..indentSelection(true);

      // Should have both L1 and L2 indent attributes in selection.
      expect(
        controller.getAllSelectionStyles(),
        contains(
          const Style().put(Attribute.indentL1).put(Attribute.indentL2),
        ),
      );

      // Remaining lines should have no attributes.
      controller.updateSelection(
          TextSelection(
              baseOffset: 12,
              extentOffset: controller.document.toPlainText().length - 1),
          ChangeSource.local);
      expect(controller.getAllSelectionStyles(), everyElement(const Style()));
    });

    test('getAllIndividualSelectionStylesAndEmbed', () {
      controller
        ..formatText(0, 2, Attribute.bold)
        ..replaceText(2, 2, BlockEmbed.image('/test'), null)
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 4),
            ChangeSource.remote);
      final result = controller.getAllIndividualSelectionStylesAndEmbed();
      expect(result.length, 2);
      expect(result[0].offset, 0);
      expect(result[0].value, const Style().put(Attribute.bold));
      expect((result[1].value as Embeddable).type, BlockEmbed.imageType);
    });

    test('getAllIndividualSelectionStylesAndEmbed mixed', () {
      controller
        ..replaceText(0, 4, 'bold plain italic', null)
        ..formatText(0, 4, Attribute.bold)
        ..formatText(11, 17, Attribute.italic)
        ..updateSelection(const TextSelection(baseOffset: 2, extentOffset: 14),
            ChangeSource.local);
      expect(controller.getPlainText(), 'ld plain ita',
          reason: 'Selection spans 3 styles');
      //
      final result = controller.getAllIndividualSelectionStylesAndEmbed();
      expect(result.length, 2);
      expect(result[0].offset, 0);
      expect(result[0].length, 2, reason: 'First style is 2 characters bold');
      expect(result[0].value, const Style().put(Attribute.bold));
      expect(result[1].offset, 9);
      expect(result[1].length, 3, reason: 'Last style is 3 characters italic');
      expect(result[1].value, const Style().put(Attribute.italic));
    });

    test('getPlainText', () {
      controller.updateSelection(
          const TextSelection(baseOffset: 0, extentOffset: 4),
          ChangeSource.local);

      expect(controller.getPlainText(), testDocumentContents);
    });

    test('getAllSelectionStyles', () {
      controller.formatText(0, 2, Attribute.bold);
      expect(controller.getAllSelectionStyles(),
          contains(const Style().put(Attribute.bold)));
    });

    test('undo', () {
      var listenerCalled = false;
      controller.updateSelection(
          const TextSelection.collapsed(offset: 4), ChangeSource.local);

      expect(
        controller.document.toDelta(),
        Delta()..insert('data\n'),
      );
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
          const TextSelection.collapsed(offset: 4), ChangeSource.local);

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
      final style = const Style().put(Attribute.bold).put(Attribute.italic);
      controller
        ..addListener(() {
          listenerCalled = true;
        })
        ..formatTextStyle(0, 2, style);
      expect(listenerCalled, isTrue);
      expect(controller.document.collectAllStyles(0, 2), contains(style));
      expect(controller.document.collectAllStyles(2, 4),
          everyElement(const Style()));
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
          contains(const Style().put(Attribute.bold)));
      expect(controller.document.collectAllStyles(2, 4),
          everyElement(const Style()));
    });

    test('formatSelection', () {
      var listenerCalled = false;
      controller
        ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 2),
            ChangeSource.local)
        ..addListener(() {
          listenerCalled = true;
        })
        ..formatSelection(Attribute.bold);
      expect(listenerCalled, isTrue);
      expect(controller.document.collectAllStyles(0, 2),
          contains(const Style().put(Attribute.bold)));
      expect(controller.document.collectAllStyles(2, 4),
          everyElement(const Style()));
    });

    test('moveCursorToStart', () {
      var listenerCalled = false;
      controller
        ..updateSelection(
            const TextSelection.collapsed(offset: 4), ChangeSource.local)
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
        ..updateSelection(selection, ChangeSource.local);

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
            const TextSelection.collapsed(offset: 0), ChangeSource.local);

      expect(listenerCalled, isTrue);
      expect(controller.document.toDelta(),
          Delta()..insert('test $originalContents'));
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
}

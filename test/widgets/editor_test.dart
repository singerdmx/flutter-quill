import 'package:flutter/material.dart';
import 'package:flutter_quill/src/widgets/controller.dart';
import 'package:flutter_quill/src/widgets/editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget_tester_extension.dart';

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic();
  });

  tearDown(() {
    controller.dispose();
  });

  group('QuillEditor', () {
    testWidgets('Keyboard entered text is stored in document', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor.basic(controller: controller, readOnly: false),
        ),
      );
      await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

      expect(controller.document.toPlainText(), 'test\n');
    });
  });
}

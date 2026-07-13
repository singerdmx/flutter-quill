import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter/material.dart' show MaterialTextSelectionToolbar;
import 'package:flutter/cupertino.dart' show CupertinoTextSelectionToolbar;

void main() {
  group('Double Tap Toolbar Test', () {
    late QuillController controller;

    setUp(() {
      controller = QuillController.basic();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should show toolbar on double tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(),
            ),
          ),
        ),
      );

      // Add some text to the editor
      controller.document = Document.fromDelta(
        Delta()..insert('Hello World\n'),
      );
      await tester.pumpAndSettle();

      // Double tap on the text
      await tester.tap(find.byType(QuillEditor));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(QuillEditor));
      await tester.pumpAndSettle();

      // Check for any known toolbar widget by type name
      final toolbarTypeNames = [
        'AdaptiveTextSelectionToolbar',
        'MaterialTextSelectionToolbar',
        'CupertinoTextSelectionToolbar',
      ];
      final foundToolbar = tester.allWidgets.any(
        (widget) => toolbarTypeNames.contains(widget.runtimeType.toString()),
      );
      expect(foundToolbar, isTrue, reason: 'Toolbar should be shown on double tap');
    });
  });
} 
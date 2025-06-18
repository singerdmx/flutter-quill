import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/utils/quill_test_app.dart';

void main() {
  group('QuillToolbarToggleStyleButton', () {
    testWidgets('should not toggle toolbar state when formatting single character',
        (tester) async {
      final controller = QuillController.basic();
      controller.document.insert(0, 'Hello World');

      await tester.pumpWidget(
        QuillTestApp.withScaffold(
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.bold,
          ),
        ),
      );

      // Format a single character
      controller.formatText(0, 1, Attribute.bold);

      // Verify the toolbar button is not toggled
      final button = tester.widget<QuillToolbarIconButton>(
        find.byType(QuillToolbarIconButton),
      );
      expect(button.isSelected, false);

      // Format multiple characters
      controller.formatText(0, 5, Attribute.bold);

      // Verify the toolbar button is now toggled
      await tester.pump();
      final buttonAfterMultiFormat = tester.widget<QuillToolbarIconButton>(
        find.byType(QuillToolbarIconButton),
      );
      expect(buttonAfterMultiFormat.isSelected, true);
    });

    testWidgets('should maintain formatting for single character',
        (tester) async {
      final controller = QuillController.basic();
      controller.document.insert(0, 'Hello World');

      await tester.pumpWidget(
        QuillTestApp.withScaffold(
          QuillToolbarToggleStyleButton(
            controller: controller,
            attribute: Attribute.bold,
          ),
        ),
      );

      // Format a single character
      controller.formatText(0, 1, Attribute.bold);

      // Verify the character is bold
      final style = controller.document.collectStyle(0, 1);
      expect(style.attributes.containsKey(Attribute.bold.key), true);

      // Type new text after the bold character
      controller.replaceText(1, 0, 'New text', null);

      // Verify the new text is not bold
      final newStyle = controller.document.collectStyle(1, 9);
      expect(newStyle.attributes.containsKey(Attribute.bold.key), false);
    });
  });
} 
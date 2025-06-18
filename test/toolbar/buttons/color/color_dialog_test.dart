import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/editor_toolbar_shared/color.dart';
import 'package:flutter_quill/src/toolbar/buttons/color/color_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../common/utils/quill_test_app.dart';

void main() {
  group('$ColorPickerDialog', () {
    testWidgets(
        'hexController is initialized correctly after selectedColor when isToggledColor is true',
        (tester) async {
      for (final isBackground in {true, false}) {
        const exampleColor = Colors.red;
        final colorHex = colorToHex(exampleColor);

        final selectionStyle = const Style().put(
          Attribute(
            isBackground ? Attribute.background.key : Attribute.color.key,
            AttributeScope.inline,
            colorHex,
          ),
        );
        final widget = ColorPickerDialog(
          isBackground: isBackground,
          onRequestChangeColor: (context, color) {},
          isToggledColor: true,
          selectionStyle: selectionStyle,
        );

        await tester.pumpWidget(QuillTestApp.withScaffold(widget));

        expect(find.widgetWithText(TextFormField, colorHex), findsOneWidget);

        final state = tester.state(find.byType(ColorPickerDialog))
            as ColorPickerDialogState;

        final selectedColor = hexToColor(state.hexController.text);

        expect(state.selectedColor, equals(selectedColor));
        expect(state.hexController.text, equals(colorToHex(selectedColor)));
      }
    });
  });
}

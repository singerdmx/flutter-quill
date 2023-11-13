import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart'
    show BlockEmbed, EmbedBuilder, QuillController;
import 'package:math_keyboard/math_keyboard.dart';

class QuillEditorFormulaEmbedBuilder extends EmbedBuilder {
  const QuillEditorFormulaEmbedBuilder();
  @override
  String get key => BlockEmbed.formulaType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    base.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    assert(!kIsWeb, 'Please provide formula EmbedBuilder for Web');

    final mathController = MathFieldEditingController();
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // If the MathField is tapped, hides the built in keyboard
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          debugPrint(mathController.currentEditingValue());
        }
      },
      child: MathField(
        controller: mathController,
        variables: const ['x', 'y', 'z'],
        onChanged: (value) {},
        onSubmitted: (value) {},
      ),
    );
  }
}

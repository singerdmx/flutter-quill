import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show BlockEmbed, Embed, EmbedBuilder, QuillController;

class QuillEditorFormulaEmbedBuilder extends EmbedBuilder {
  const QuillEditorFormulaEmbedBuilder();
  @override
  String get key => BlockEmbed.formulaType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    throw UnsupportedError(
      'The formula EmbedBuilder is not supported for now.',
    );
    // assert(!kIsWeb, 'Please provide formula EmbedBuilder for Web');

    // final mathController = MathFieldEditingController();
    // return Focus(
    //   onFocusChange: (hasFocus) {
    //     if (hasFocus) {
    //       // If the MathField is tapped, hides the built in keyboard
    //       SystemChannels.textInput.invokeMethod('TextInput.hide');
    //       debugPrint(mathController.currentEditingValue());
    //     }
    //   },
    //   child: MathField(
    //     controller: mathController,
    //     variables: const ['x', 'y', 'z'],
    //     onChanged: (value) {},
    //     onSubmitted: (value) {},
    //   ),
    // );
  }
}

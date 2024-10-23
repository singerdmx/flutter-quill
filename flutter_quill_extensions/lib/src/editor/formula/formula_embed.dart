import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

// TODO: Remove the formula embed

class QuillEditorFormulaEmbedBuilder extends EmbedBuilder {
  const QuillEditorFormulaEmbedBuilder();
  @override
  String get key => BlockEmbed.formulaType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
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

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillEditorUnknownEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    return const Text('Unknown embed builder');
  }

  @override
  String get key => 'unknown';
}

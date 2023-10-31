import 'package:flutter_quill/flutter_quill.dart';

import '../../presentation/embeds/editor/webview.dart';

extension QuillControllerExt on QuillController {
  int get index => selection.baseOffset;
  int get length => selection.extentOffset - index;
  void insertWebViewBlock({
    required String initialUrl,
  }) {
    final block = BlockEmbed.custom(
      QuillEditorWebViewBlockEmbed(
        initialUrl,
      ),
    );

    this
      ..skipRequestKeyboard = true
      ..replaceText(
        index,
        length,
        block,
        null,
      );
  }

  void insertImageBlock({
    required String imageUrl,
  }) {
    this
      ..skipRequestKeyboard = true
      ..replaceText(
        index,
        length,
        BlockEmbed.image(imageUrl),
        null,
      );
  }
}

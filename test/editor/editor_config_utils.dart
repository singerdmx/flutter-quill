import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:material_ui/material_ui.dart';

QuillRawEditorConfig createFakeRawEditorConfig({
  Brightness? keyboardAppearance,
}) => QuillRawEditorConfig(
  focusNode: FocusNode(),
  scrollController: ScrollController(),
  selectionColor: Colors.transparent,
  selectionCtrls: cupertinoTextSelectionControls,
  embedBuilder: (node) {
    throw UnimplementedError();
  },
  textSpanBuilder: (context, node, nodeOffset, text, style, recognizer) {
    throw UnimplementedError();
  },
  autoFocus: false,
  cursorStyle: const CursorStyle(
    color: Colors.black,
    backgroundColor: Colors.transparent,
  ),
  scrollBottomInset: -1,
  keyboardAppearance: keyboardAppearance,
);

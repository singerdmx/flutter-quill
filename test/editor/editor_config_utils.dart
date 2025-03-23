import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

QuillRawEditorConfig createFakeRawEditorConfig(
        {Brightness? keyboardAppearance}) =>
    QuillRawEditorConfig(
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
          color: Colors.black, backgroundColor: Colors.transparent),
      scrollBottomInset: -1,
      keyboardAppearance: keyboardAppearance,
    );

import 'package:flutter/cupertino.dart';

import 'editor.dart';

abstract class EditorTextSelectionGestureDetectorBuilderDelegate {
  GlobalKey<EditorState> getEditableTextKey();

  bool getForcePressEnabled();

  bool getSelectionEnabled();
}

class EditorTextSelectionGestureDetectorBuilder {
  final EditorTextSelectionGestureDetectorBuilderDelegate delegate;
  bool shouldShowSelectionToolbar = true;

  EditorTextSelectionGestureDetectorBuilder(this.delegate)
      : assert(delegate != null);

  EditorState getEditor() {
    return delegate.getEditableTextKey().currentState;
  }

  RenderEditor getRenderEditor() {
    return this.getEditor().getRenderEditor();
  }

  onTapDown(TapDownDetails details) {
//    getRenderEditor().handleTapDown(details);
  }
}

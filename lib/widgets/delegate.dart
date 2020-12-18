import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart';

import 'editor.dart';

typedef EmbedBuilder = Widget Function(BuildContext context, Embed node);

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

  onForcePressStart(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    shouldShowSelectionToolbar = true;
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectWordsInRange(
        details.globalPosition,
        null,
        SelectionChangedCause.forcePress,
      );
    }
  }

  Widget build(HitTestBehavior behavior, Widget child) {
    // TODO
    return null;
  }
}

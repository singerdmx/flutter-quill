import 'package:flutter/widgets.dart';

import '../editor.dart';

mixin RawEditorStateSelectionDelegateMixin on EditorState
    implements TextSelectionDelegate {
  @override
  TextEditingValue get textEditingValue {
    return getTextEditingValue();
  }

  @override
  set textEditingValue(TextEditingValue value) {
    setTextEditingValue(value);
  }

  @override
  void bringIntoView(TextPosition position) {
    // TODO: implement bringIntoView
  }

  @override
  void hideToolbar([bool hideHandles = true]) {
    if (getSelectionOverlay()?.toolbar != null) {
      getSelectionOverlay()?.hideToolbar();
    }
  }

  @override
  void userUpdateTextEditingValue(
    TextEditingValue value,
    SelectionChangedCause cause,
  ) {
    setTextEditingValue(value);
  }

  @override
  bool get cutEnabled => widget.toolbarOptions.cut && !widget.readOnly;

  @override
  bool get copyEnabled => widget.toolbarOptions.copy;

  @override
  bool get pasteEnabled => widget.toolbarOptions.paste && !widget.readOnly;

  @override
  bool get selectAllEnabled => widget.toolbarOptions.selectAll;
}

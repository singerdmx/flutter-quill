part of '../raw_editor/raw_editor_state.dart';

extension QuillRawEditorStateMagnifierExt on QuillRawEditorState {
  void _hideMagnifier() {
    if (_selectionOverlay == null) return;
    _selectionOverlay?.hideMagnifier();
  }

  void _showMagnifier(ui.Offset positionToShow) {
    if (_hasFocus == false) return;
    if (_selectionOverlay == null) return;
    final position = renderEditor.getPositionForOffset(positionToShow);
    if (_selectionOverlay!.magnifierIsVisible) {
      _selectionOverlay!
          .updateMagnifier(position, positionToShow, renderEditor);
    } else {
      _selectionOverlay!.showMagnifier(position, positionToShow, renderEditor);
    }
  }

  void _updateMagnifier(ui.Offset positionToShow) =>
      showMagnifier(positionToShow);

  TextMagnifierConfiguration get _magnifierConfiguration =>
      widget.configurations.magnifierConfiguration ??
      TextMagnifier.adaptiveMagnifierConfiguration;
}

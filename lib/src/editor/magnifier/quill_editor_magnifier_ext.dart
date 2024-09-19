part of '../editor.dart';

extension QuillEditorSelectionGestureDetectorBuilderMagnifierExt
    on _QuillEditorSelectionGestureDetectorBuilder {
  void _showMagnifierIfSupportedByPlatform(Offset positionToShow) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        editor?.showMagnifier(positionToShow);
      default:
    }
  }

  void _hideMagnifierIfSupportedByPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        editor?.hideMagnifier();
      default:
    }
  }
}

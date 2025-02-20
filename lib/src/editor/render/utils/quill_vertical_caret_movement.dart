import 'dart:ui';
import 'package:meta/meta.dart';
import '../render_editor.dart';

@internal
class QuillVerticalCaretMovementRun implements Iterator<TextPosition> {
  QuillVerticalCaretMovementRun(
    this._editor,
    this._currentTextPosition,
  );

  TextPosition _currentTextPosition;

  final RenderEditor _editor;

  @override
  TextPosition get current {
    return _currentTextPosition;
  }

  @override
  bool moveNext() {
    _currentTextPosition = _editor.getTextPositionBelow(_currentTextPosition);
    return true;
  }

  bool movePrevious() {
    _currentTextPosition = _editor.getTextPositionAbove(_currentTextPosition);
    return true;
  }

  void moveVertical(double verticalOffset) {
    _currentTextPosition = _editor.getTextPositionMoveVertical(
        _currentTextPosition, verticalOffset);
  }
}

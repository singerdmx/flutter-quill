part of '../widgets/text/text_selection.dart';

final MagnifierController _magnifierController = MagnifierController();

/// Restore the selection context menu after the magnifier is dismissed.
/// Fix: https://github.com/singerdmx/flutter-quill/issues/2046
bool _restoreToolbar = false;

extension EditorTextSelectionOverlayMagnifierExt on EditorTextSelectionOverlay {
  // build magnifier info
  MagnifierInfo _buildMagnifier(
      {required RenderEditor renderEditable,
      required Offset globalGesturePosition,
      required TextPosition currentTextPosition}) {
    final globalRenderEditableTopLeft =
        renderEditable.localToGlobal(Offset.zero);
    final localCaretRect =
        renderEditable.getLocalRectForCaret(currentTextPosition);

    final lineAtOffset = renderEditable.getLineAtOffset(currentTextPosition);
    final positionAtEndOfLine = TextPosition(
      offset: lineAtOffset.extentOffset,
      affinity: TextAffinity.upstream,
    );

    // Default affinity is downstream.
    final positionAtBeginningOfLine = TextPosition(
      offset: lineAtOffset.baseOffset,
    );

    final lineBoundaries = Rect.fromPoints(
      renderEditable.getLocalRectForCaret(positionAtBeginningOfLine).topCenter,
      renderEditable.getLocalRectForCaret(positionAtEndOfLine).bottomCenter,
    );

    return MagnifierInfo(
      fieldBounds: globalRenderEditableTopLeft & renderEditable.size,
      globalGesturePosition: globalGesturePosition,
      caretRect: localCaretRect.shift(globalRenderEditableTopLeft),
      currentLineBoundaries: lineBoundaries.shift(globalRenderEditableTopLeft),
    );
  }

  void _showMagnifier(MagnifierInfo initialMagnifierInfo) {
    // Hide toolbar
    if (toolbar != null) {
      _restoreToolbar = true;
      hideToolbar();
    } else {
      _restoreToolbar = false;
    }

    // Update magnifier Info
    _magnifierInfo.value = initialMagnifierInfo;

    final builtMagnifier = magnifierConfiguration.magnifierBuilder(
      context,
      _magnifierController,
      _magnifierInfo,
    );

    if (builtMagnifier == null) return;

    _magnifierController.show(
      context: context,
      below: magnifierConfiguration.shouldDisplayHandlesInMagnifier
          ? null
          : _handles?.elementAtOrNull(0),
      builder: (_) => builtMagnifier,
    );
  }

  void _updateMagnifier(MagnifierInfo magnifierInfo) {
    if (_magnifierController.overlayEntry == null) {
      return;
    }
    _magnifierInfo.value = magnifierInfo;
  }

  // TODO: Why we're having private and public methods for showMagnifier, and updateMagnifier?
  //      Is this internal API that is for public use?
  //      Once we know the reason, explain and document it.

  void showMagnifier(
      TextPosition position, Offset offset, RenderEditor editor) {
    _showMagnifier(
      _buildMagnifier(
        currentTextPosition: position,
        globalGesturePosition: offset,
        renderEditable: editor,
      ),
    );
  }

  void updateMagnifier(
      TextPosition position, Offset offset, RenderEditor editor) {
    _updateMagnifier(
      _buildMagnifier(
        currentTextPosition: position,
        globalGesturePosition: offset,
        renderEditable: editor,
      ),
    );
  }

  void hideMagnifier() {
    if (_magnifierController.overlayEntry == null) {
      return;
    }
    _magnifierController.hide();
    if (_restoreToolbar) {
      _restoreToolbar = false;
      showToolbar();
    }
  }
}

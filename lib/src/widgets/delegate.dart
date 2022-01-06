import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../flutter_quill.dart';
import 'text_selection.dart';

typedef EmbedBuilder = Widget Function(
    BuildContext context, Embed node, bool readOnly);

typedef CustomStyleBuilder = TextStyle Function(Attribute attribute);

abstract class EditorTextSelectionGestureDetectorBuilderDelegate {
  GlobalKey<EditorState> getEditableTextKey();

  bool getForcePressEnabled();

  bool getSelectionEnabled();
}

/// Builds a [EditorTextSelectionGestureDetector] to wrap an [EditableText].
///
/// The class implements sensible defaults for many user interactions
/// with an [EditableText] (see the documentation of the various gesture handler
/// methods, e.g. [onTapDown], [onForcePressStart], etc.). Subclasses of
/// [EditorTextSelectionGestureDetectorBuilder] can change the behavior
/// performed in responds to these gesture events by overriding
/// the corresponding handler methods of this class.
///
/// The resulting [EditorTextSelectionGestureDetector] to wrap an [EditableText]
/// is obtained by calling [buildGestureDetector].
///
/// See also:
///
///  * [TextField], which uses a subclass to implement the Material-specific
///    gesture logic of an [EditableText].
///  * [CupertinoTextField], which uses a subclass to implement the
///    Cupertino-specific gesture logic of an [EditableText].
class EditorTextSelectionGestureDetectorBuilder {
  /// Creates a [EditorTextSelectionGestureDetectorBuilder].
  ///
  /// The [delegate] must not be null.
  EditorTextSelectionGestureDetectorBuilder({required this.delegate});

  /// The delegate for this [EditorTextSelectionGestureDetectorBuilder].
  ///
  /// The delegate provides the builder with information about what actions can
  /// currently be performed on the textfield. Based on this, the builder adds
  /// the correct gesture handlers to the gesture detector.
  @protected
  final EditorTextSelectionGestureDetectorBuilderDelegate delegate;

  /// Whether to show the selection toolbar.
  ///
  /// It is based on the signal source when a [onTapDown] is called. This getter
  /// will return true if current [onTapDown] event is triggered by a touch or
  /// a stylus.
  bool shouldShowSelectionToolbar = true;

  /// The [State] of the [EditableText] for which the builder will provide a
  /// [EditorTextSelectionGestureDetector].
  @protected
  EditorState? getEditor() {
    return delegate.getEditableTextKey().currentState;
  }

  /// The [RenderObject] of the [EditableText] for which the builder will
  /// provide a [EditorTextSelectionGestureDetector].
  @protected
  RenderEditor? getRenderEditor() {
    return getEditor()!.renderEditor;
  }

  /// Handler for [EditorTextSelectionGestureDetector.onTapDown].
  ///
  /// By default, it forwards the tap to [RenderEditable.handleTapDown] and sets
  /// [shouldShowSelectionToolbar] to true if the tap was initiated by a finger
  /// or stylus.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onTapDown],
  ///  which triggers this callback.
  @protected
  void onTapDown(TapDownDetails details) {
    getRenderEditor()!.handleTapDown(details);
    // The selection overlay should only be shown when the user is interacting
    // through a touch screen (via either a finger or a stylus).
    // A mouse shouldn't trigger the selection overlay.
    // For backwards-compatibility, we treat a null kind the same as touch.
    final kind = details.kind;
    shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus;
  }

  /// Handler for [EditorTextSelectionGestureDetector.onForcePressStart].
  ///
  /// By default, it selects the word at the position of the force press,
  /// if selection is enabled.
  ///
  /// This callback is only applicable when force press is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onForcePressStart],
  ///  which triggers this callback.
  @protected
  void onForcePressStart(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    shouldShowSelectionToolbar = true;
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.selectWordsInRange(
        details.globalPosition,
        null,
        SelectionChangedCause.forcePress,
      );
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onForcePressEnd].
  ///
  /// By default, it selects words in the range specified in [details] and shows
  /// toolbar if it is necessary.
  ///
  /// This callback is only applicable when force press is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onForcePressEnd],
  ///  which triggers this callback.
  @protected
  void onForcePressEnd(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    getRenderEditor()!.selectWordsInRange(
      details.globalPosition,
      null,
      SelectionChangedCause.forcePress,
    );
    if (shouldShowSelectionToolbar) {
      getEditor()!.showToolbar();
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onSingleTapUp].
  ///
  /// By default, it selects word edge if selection is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleTapUp], which triggers
  ///    this callback.
  @protected
  void onSingleTapUp(TapUpDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.selectWordEdge(SelectionChangedCause.tap);
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onSingleTapCancel].
  ///
  /// By default, it services as place holder to enable subclass override.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleTapCancel], which triggers
  ///    this callback.
  @protected
  void onSingleTapCancel() {
    /* Subclass should override this method if needed. */
  }

  /// Handler for [EditorTextSelectionGestureDetector.onSingleLongTapStart].
  ///
  /// By default, it selects text position specified in [details] if selection
  /// is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleLongTapStart],
  ///  which triggers this callback.
  @protected
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.selectPositionAt(
        from: details.globalPosition,
        cause: SelectionChangedCause.longPress,
      );
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onSingleLongTapMoveUpdate]
  ///
  /// By default, it updates the selection location specified in [details] if
  /// selection is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleLongTapMoveUpdate], which
  ///    triggers this callback.
  @protected
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.selectPositionAt(
        from: details.globalPosition,
        cause: SelectionChangedCause.longPress,
      );
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onSingleLongTapEnd].
  ///
  /// By default, it shows toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleLongTapEnd],
  ///  which triggers this callback.
  @protected
  void onSingleLongTapEnd(LongPressEndDetails details) {
    if (shouldShowSelectionToolbar) {
      getEditor()!.showToolbar();
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onDoubleTapDown].
  ///
  /// By default, it selects a word through [RenderEditable.selectWord] if
  /// selectionEnabled and shows toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onDoubleTapDown],
  ///  which triggers this callback.
  @protected
  void onDoubleTapDown(TapDownDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor()!.selectWord(SelectionChangedCause.tap);
      if (shouldShowSelectionToolbar) {
        getEditor()!.showToolbar();
      }
    }
  }

  /// Handler for [EditorTextSelectionGestureDetector.onDragSelectionStart].
  ///
  /// By default, it selects a text position specified in [details].
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onDragSelectionStart],
  ///  which triggers this callback.
  @protected
  void onDragSelectionStart(DragStartDetails details) {
    getRenderEditor()!.handleDragStart(details);
  }

  /// Handler for [EditorTextSelectionGestureDetector.onDragSelectionUpdate].
  ///
  /// By default, it updates the selection location specified in the provided
  /// details objects.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onDragSelectionUpdate],
  ///  which triggers this callback./lib/src/material/text_field.dart
  @protected
  void onDragSelectionUpdate(
      DragStartDetails startDetails, DragUpdateDetails updateDetails) {
    getRenderEditor()!.extendSelection(updateDetails.globalPosition,
        cause: SelectionChangedCause.drag);
  }

  /// Handler for [EditorTextSelectionGestureDetector.onDragSelectionEnd].
  ///
  /// By default, it services as place holder to enable subclass override.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onDragSelectionEnd],
  ///  which triggers this callback.
  @protected
  void onDragSelectionEnd(DragEndDetails details) {
    getRenderEditor()!.handleDragEnd(details);
  }

  /// Returns a [EditorTextSelectionGestureDetector] configured with
  /// the handlers provided by this builder.
  ///
  /// The [child] or its subtree should contain [EditableText].
  Widget build(
      {required HitTestBehavior behavior, required Widget child, Key? key}) {
    return EditorTextSelectionGestureDetector(
      key: key,
      onTapDown: onTapDown,
      onForcePressStart:
          delegate.getForcePressEnabled() ? onForcePressStart : null,
      onForcePressEnd: delegate.getForcePressEnabled() ? onForcePressEnd : null,
      onSingleTapUp: onSingleTapUp,
      onSingleTapCancel: onSingleTapCancel,
      onSingleLongTapStart: onSingleLongTapStart,
      onSingleLongTapMoveUpdate: onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: onSingleLongTapEnd,
      onDoubleTapDown: onDoubleTapDown,
      onDragSelectionStart: onDragSelectionStart,
      onDragSelectionUpdate: onDragSelectionUpdate,
      onDragSelectionEnd: onDragSelectionEnd,
      behavior: behavior,
      child: child,
    );
  }
}

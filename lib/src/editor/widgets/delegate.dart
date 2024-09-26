import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../common/utils/platform.dart';
import '../../document/attribute.dart';
import '../../document/nodes/leaf.dart';
import '../editor.dart';
import '../raw_editor/raw_editor.dart';
import 'text/text_selection.dart';

typedef CustomStyleBuilder = TextStyle Function(Attribute attribute);

typedef CustomRecognizerBuilder = GestureRecognizer? Function(
    Attribute attribute, Leaf leaf);

/// Delegate interface for the [EditorTextSelectionGestureDetectorBuilder].
///
/// The interface is usually implemented by textfield implementations wrapping
/// [EditableText], that use a [EditorTextSelectionGestureDetectorBuilder]
/// to build a [EditorTextSelectionGestureDetector] for their [EditableText].
/// The delegate provides the builder with information about the current state
/// of the textfield.
/// Based on these information, the builder adds the correct gesture handlers
/// to the gesture detector.
///
/// See also:
///
///  * [TextField], which implements this delegate for the Material textfield.
///  * [CupertinoTextField], which implements this delegate for the Cupertino
///    textfield.
abstract class EditorTextSelectionGestureDetectorBuilderDelegate {
  /// [GlobalKey] to the [EditableText] for which the
  /// [EditorTextSelectionGestureDetectorBuilder] will build
  /// a [EditorTextSelectionGestureDetector].
  GlobalKey<EditorState> get editableTextKey;

  /// Whether the textfield should respond to force presses.
  bool get forcePressEnabled;

  /// Whether the user may select text in the textfield.
  bool get selectionEnabled;
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
  EditorTextSelectionGestureDetectorBuilder(
      {required this.delegate, this.detectWordBoundary = true});

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
  PointerDeviceKind? kind;

  /// Check if the selection toolbar should show.
  ///
  /// If mouse is used, the toolbar should only show when right click.
  /// Else, it should show when the selection is enabled.
  bool checkSelectionToolbarShouldShow({required bool isAdditionalAction}) {
    if (kind != PointerDeviceKind.mouse) {
      return shouldShowSelectionToolbar;
    }
    return shouldShowSelectionToolbar && isAdditionalAction;
  }

  bool detectWordBoundary = true;

  /// The [State] of the [EditableText] for which the builder will provide a
  /// [EditorTextSelectionGestureDetector].
  @protected
  EditorState? get editor => delegate.editableTextKey.currentState;

  /// The [RenderObject] of the [EditableText] for which the builder will
  /// provide a [EditorTextSelectionGestureDetector].
  @protected
  RenderEditor? get renderEditor => editor?.renderEditor;

  /// Whether the Shift key was pressed when the most recent [PointerDownEvent]
  /// was tracked by the [BaseTapAndDragGestureRecognizer].
  bool _isShiftPressed = false;

  /// The viewport offset pixels of any [Scrollable] containing the
  /// [RenderEditable] at the last drag start.
  double _dragStartScrollOffset = 0;

  /// The viewport offset pixels of the [RenderEditable] at the last drag start.
  double _dragStartViewportOffset = 0;

  double get _scrollPosition {
    final scrollableState = delegate.editableTextKey.currentContext == null
        ? null
        : Scrollable.maybeOf(delegate.editableTextKey.currentContext!);
    return scrollableState == null ? 0.0 : scrollableState.position.pixels;
  }

  // For tap + drag gesture on iOS, whether the position where the drag started
  // was on the previous TextSelection. iOS uses this value to determine if
  // the cursor should move on drag update.
  //
  TextSelection? _dragStartSelection;

  // If the drag started on the previous selection then the cursor will move on
  // drag update. If the drag did not start on the previous selection then the
  // cursor will not move on drag update.
  bool? _dragBeganOnPreviousSelection;

  /// Returns true if lastSecondaryTapDownPosition was on selection.
  bool get _lastSecondaryTapWasOnSelection {
    assert(renderEditor?.lastSecondaryTapDownPosition != null);
    if (renderEditor?.selection == null) {
      return false;
    }
    renderEditor?.lastSecondaryTapDownPosition;
    final textPosition = renderEditor?.getPositionForOffset(
      renderEditor!.lastSecondaryTapDownPosition!,
    );

    if (textPosition == null) return false;

    return renderEditor!.selection.start <= textPosition.offset &&
        renderEditor!.selection.end >= textPosition.offset;
  }

  /// Returns true if position was on selection.
  bool _positionOnSelection(Offset position, TextSelection? targetSelection) {
    if (targetSelection == null) return false;

    final textPosition = renderEditor?.getPositionForOffset(position);

    if (textPosition == null) return false;

    return targetSelection.start <= textPosition.offset &&
        targetSelection.end >= textPosition.offset;
  }

  // Expand the selection to the given global position.
  //
  // Either base or extent will be moved to the last tapped position, whichever
  // is closest. The selection will never shrink or pivot, only grow.
  //
  // If fromSelection is given, will expand from that selection instead of the
  // current selection in renderEditable.
  //
  // See also:
  //
  //   * [_extendSelection], which is similar but pivots the selection around
  //     the base.
  void _expandSelection(Offset offset, SelectionChangedCause cause,
      [TextSelection? fromSelection]) {
    final tappedPosition = renderEditor!.getPositionForOffset(offset);
    final selection = fromSelection ?? renderEditor!.selection;
    final baseIsCloser = (tappedPosition.offset - selection.baseOffset).abs() <
        (tappedPosition.offset - selection.extentOffset).abs();
    final nextSelection = selection.copyWith(
      baseOffset: baseIsCloser ? selection.extentOffset : selection.baseOffset,
      extentOffset: tappedPosition.offset,
    );

    editor?.userUpdateTextEditingValue(
        editor!.textEditingValue.copyWith(selection: nextSelection), cause);
  }

  // Extend the selection to the given global position.
  //
  // Holds the base in place and moves the extent.
  //
  // See also:
  //
  //   * [_expandSelection], which is similar but always increases the size of
  //     the selection.
  void _extendSelection(Offset offset, SelectionChangedCause cause) {
    assert(renderEditor?.selection.baseOffset != null);

    final tappedPosition = renderEditor!.getPositionForOffset(offset);
    final selection = switch (cause) {
      SelectionChangedCause.drag => _dragStartSelection!,
      _ => renderEditor!.selection
    };

    final nextSelection = selection.copyWith(
      extentOffset: tappedPosition.offset,
    );

    editor?.userUpdateTextEditingValue(
        editor!.textEditingValue.copyWith(selection: nextSelection), cause);
  }

  /// Handler for [TextSelectionGestureDetector.onTapTrackStart].
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onTapTrackStart], which triggers this
  ///    callback.
  @protected
  void onTapTrackStart() {
    _isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed
        .intersection(<LogicalKeyboardKey>{
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight
    }).isNotEmpty;
  }

  /// Handler for [TextSelectionGestureDetector.onTapTrackReset].
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onTapTrackReset], which triggers this
  ///    callback.
  @protected
  void onTapTrackReset() {
    _isShiftPressed = false;
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
  void onTapDown(TapDragDownDetails details) {
    if (!delegate.selectionEnabled) return;
    renderEditor!
        .handleTapDown(TapDownDetails(globalPosition: details.globalPosition));
    final kind = details.kind;
    shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus;
    final isShiftPressedValid =
        _isShiftPressed && renderEditor?.selection.baseOffset != null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        editor?.hideToolbar(false);
      case TargetPlatform.iOS:
        // On mobile platforms the selection is set on tap up.
        break;
      case TargetPlatform.macOS:
        editor?.hideToolbar();
        // On macOS, a shift-tapped unfocused field expands from 0, not from the
        // previous selection.
        if (isShiftPressedValid) {
          final fromSelection = renderEditor?.hasFocus == true
              ? null
              : const TextSelection.collapsed(offset: 0);
          _expandSelection(
              details.globalPosition, SelectionChangedCause.tap, fromSelection);
          return;
        }
        renderEditor?.selectPosition(cause: SelectionChangedCause.tap);
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        editor?.hideToolbar();
        if (isShiftPressedValid) {
          _extendSelection(details.globalPosition, SelectionChangedCause.tap);
          return;
        }
        renderEditor?.selectPosition(cause: SelectionChangedCause.tap);
    }
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
    assert(delegate.forcePressEnabled);
    shouldShowSelectionToolbar = true;
    if (delegate.selectionEnabled) {
      renderEditor!.selectWordsInRange(
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
    assert(delegate.forcePressEnabled);
    renderEditor!.selectWordsInRange(
      details.globalPosition,
      null,
      SelectionChangedCause.forcePress,
    );
    if (checkSelectionToolbarShouldShow(isAdditionalAction: false)) {
      editor!.showToolbar();
    }
  }

  /// Whether the provided [onUserTap] callback should be dispatched on every
  /// tap or only non-consecutive taps.
  ///
  /// Defaults to false.
  @protected
  bool get onUserTapAlwaysCalled => false;

  /// Handler for [TextSelectionGestureDetector.onUserTap].
  ///
  /// By default, it serves as placeholder to enable subclass override.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onUserTap], which triggers this
  ///    callback.
  ///  * [TextSelectionGestureDetector.onUserTapAlwaysCalled], which controls
  ///     whether this callback is called only on the first tap in a series
  ///     of taps.
  @protected
  void onUserTap() {/* Subclass should override this method if needed. */}

  /// Handler for [EditorTextSelectionGestureDetector.onSingleTapUp].
  ///
  /// By default, it selects word edge if selection is enabled.
  ///
  /// See also:
  ///
  ///  * [EditorTextSelectionGestureDetector.onSingleTapUp], which triggers
  ///    this callback.
  @protected
  void onSingleTapUp(TapDragUpDetails details) {
    if (delegate.selectionEnabled) {
      renderEditor!.selectWordEdge(SelectionChangedCause.tap);
    }
  }

  /// onSingleTapUp for mouse right click
  @protected
  void onSecondarySingleTapUp(TapUpDetails details) {
    // added to show toolbar by right click
    if (checkSelectionToolbarShouldShow(isAdditionalAction: true)) {
      editor!.showToolbar();
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
    if (delegate.selectionEnabled) {
      renderEditor!.selectPositionAt(
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
    if (delegate.selectionEnabled) {
      renderEditor!.selectPositionAt(
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
    if (checkSelectionToolbarShouldShow(isAdditionalAction: false)) {
      editor!.showToolbar();
    }
    // Q: why ?
    // A: cannot access QuillRawEditorState.updateFloatingCursor
    //
    // if (defaultTargetPlatform == TargetPlatform.iOS &&
    //     delegate.selectionEnabled &&
    //     editor?.textEditingValue.selection.isCollapsed == true) {
    //   // Update the floating cursor.
    //   final cursorPoint =
    //       RawFloatingCursorPoint(state: FloatingCursorDragState.End);
    //   //  !.updateFloatingCursor(cursorPoint);
    //   (editor as QuillRawEditorState?)?.updateFloatingCursor(cursorPoint);
    // }
  }

  /// Handler for [TextSelectionGestureDetector.onSecondaryTap].
  ///
  /// By default, selects the word if possible and shows the toolbar.
  @protected
  void onSecondaryTap() {
    if (!delegate.selectionEnabled) {
      return;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        if (!_lastSecondaryTapWasOnSelection ||
            renderEditor?.hasFocus == false) {
          renderEditor?.selectWord(SelectionChangedCause.tap);
        }
        if (shouldShowSelectionToolbar) {
          editor?.hideToolbar();
          editor?.showToolbar();
        }
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (renderEditor?.hasFocus == false) {
          renderEditor?.selectPosition(cause: SelectionChangedCause.tap);
        }
        editor?.toggleToolbar();
    }
  }

  /// Handler for [TextSelectionGestureDetector.onDoubleTapDown].
  ///
  /// By default, it selects a word through [RenderEditable.selectWord] if
  /// selectionEnabled and shows toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onDoubleTapDown], which triggers this
  ///    callback.
  @protected
  void onSecondaryTapDown(TapDownDetails details) {
    renderEditor?.handleSecondaryTapDown(
        TapDownDetails(globalPosition: details.globalPosition));
    shouldShowSelectionToolbar = true;
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
  void onDoubleTapDown(TapDragDownDetails details) {
    if (delegate.selectionEnabled) {
      renderEditor!.selectWord(SelectionChangedCause.tap);
      // allow the selection to get updated before trying to bring up
      // toolbars.
      //
      // if double tap happens on an editor that doesn't
      // have focus, selection hasn't been set when the toolbars
      // get added
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (checkSelectionToolbarShouldShow(isAdditionalAction: false)) {
          editor!.showToolbar();
        }
      });
    }
  }

  // Selects the set of paragraphs in a document that intersect a given range of
  // global positions.
  void _selectParagraphsInRange(
      {required Offset from, Offset? to, SelectionChangedCause? cause}) {
    final TextBoundary paragraphBoundary =
        ParagraphBoundary(editor!.textEditingValue.text);
    _selectTextBoundariesInRange(
        boundary: paragraphBoundary, from: from, to: to, cause: cause);
  }

  // Selects the set of lines in a document that intersect a given range of
  // global positions.
  void _selectLinesInRange(
      {required Offset from, Offset? to, SelectionChangedCause? cause}) {
    final TextBoundary lineBoundary = LineBoundary(renderEditor!);
    _selectTextBoundariesInRange(
        boundary: lineBoundary, from: from, to: to, cause: cause);
  }

  // Returns the location of a text boundary at `extent`. When `extent` is at
  // the end of the text, returns the previous text boundary's location.
  TextRange _moveToTextBoundary(
      TextPosition extent, TextBoundary textBoundary) {
    assert(extent.offset >= 0);
    final start = textBoundary.getLeadingTextBoundaryAt(
            extent.offset == editor!.textEditingValue.text.length
                ? extent.offset - 1
                : extent.offset) ??
        0;
    final end = textBoundary.getTrailingTextBoundaryAt(extent.offset) ??
        editor!.textEditingValue.text.length;
    return TextRange(start: start, end: end);
  }

  // Selects the set of text boundaries in a document that intersect a given
  // range of global positions.
  //
  // The set of text boundaries selected are not strictly bounded by the range
  // of global positions.
  //
  // The first and last endpoints of the selection will always be at the
  // beginning and end of a text boundary respectively.
  void _selectTextBoundariesInRange(
      {required TextBoundary boundary,
      required Offset from,
      Offset? to,
      SelectionChangedCause? cause}) {
    final fromPosition = renderEditor!.getPositionForOffset(from);
    final fromRange = _moveToTextBoundary(fromPosition, boundary);
    final toPosition =
        to == null ? fromPosition : renderEditor!.getPositionForOffset(to);
    final toRange = toPosition == fromPosition
        ? fromRange
        : _moveToTextBoundary(toPosition, boundary);
    final isFromBoundaryBeforeToBoundary = fromRange.start < toRange.end;

    final newSelection = isFromBoundaryBeforeToBoundary
        ? TextSelection(baseOffset: fromRange.start, extentOffset: toRange.end)
        : TextSelection(baseOffset: fromRange.end, extentOffset: toRange.start);

    editor!.userUpdateTextEditingValue(
        editor!.textEditingValue.copyWith(selection: newSelection),
        cause ?? SelectionChangedCause.drag);
  }

  /// Handler for [TextSelectionGestureDetector.onTripleTapDown].
  ///
  /// By default, it selects a paragraph if
  /// [TextSelectionGestureDetectorBuilderDelegate.selectionEnabled] is true
  /// and shows the toolbar if necessary.
  ///
  /// See also:
  ///
  ///  * [TextSelectionGestureDetector.onTripleTapDown], which triggers this
  ///    callback.
  @protected
  void onTripleTapDown(TapDragDownDetails details) {
    if (!delegate.selectionEnabled) {
      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        _selectParagraphsInRange(
            from: details.globalPosition, cause: SelectionChangedCause.tap);
      case TargetPlatform.linux:
        _selectLinesInRange(
            from: details.globalPosition, cause: SelectionChangedCause.tap);
    }

    if (shouldShowSelectionToolbar) {
      editor?.showToolbar();
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
  void onDragSelectionStart(TapDragStartDetails details) {
    if (delegate.selectionEnabled == false) return;
    // underline show open on ios and android,
    // when has isCollapsed, show not reposonse to tapdarg gesture
    // so that will not change texteditingvalue,
    // and same issue to TextField, tap selection area, will lost selection,
    // if (editor?.textEditingValue.selection.isCollapsed == false) return;

    final kind = details.kind;
    shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus;
    _dragStartSelection = renderEditor?.selection;
    _dragStartScrollOffset = _scrollPosition;
    _dragStartViewportOffset = renderEditor?.offset?.pixels ?? 0.0;
    _dragBeganOnPreviousSelection =
        _positionOnSelection(details.globalPosition, _dragStartSelection);
    if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
            details.consecutiveTapCount) >
        1) {
      // Do not set the selection on a consecutive tap and drag.
      return;
    }

    if (_isShiftPressed &&
        renderEditor?.selection != null &&
        renderEditor?.selection.isValid == true) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          renderEditor?.extendSelection(details.globalPosition,
              cause: SelectionChangedCause.drag);

        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderEditor?.extendSelection(details.globalPosition,
              cause: SelectionChangedCause.drag);
      }
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
              _dragStartSelection = renderEditor?.selectPositionAt(
                from: details.globalPosition,
                cause: SelectionChangedCause.drag,
              );
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              // For iOS platforms, a touch drag does not initiate unless the
              // editable has focus and the drag began on the previous selection.
              assert(_dragBeganOnPreviousSelection != null);
              if (renderEditor?.hasFocus == true &&
                  _dragBeganOnPreviousSelection!) {
                _dragStartSelection = renderEditor?.selectPositionAt(
                  from: details.globalPosition,
                  cause: SelectionChangedCause.drag,
                );
                editor?.showMagnifier(details.globalPosition);
              }
            case null:
          }
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          switch (details.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
              _dragStartSelection = renderEditor?.selectPositionAt(
                from: details.globalPosition,
                cause: SelectionChangedCause.drag,
              );
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              // For Android, Fucshia, and iOS platforms, a touch drag
              // does not initiate unless the editable has focus.
              if (renderEditor?.hasFocus == true) {
                _dragStartSelection = renderEditor?.selectPositionAt(
                  from: details.globalPosition,
                  cause: SelectionChangedCause.drag,
                );
                editor?.showMagnifier(details.globalPosition);
              }
            case null:
          }
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          _dragStartSelection = renderEditor?.selectPositionAt(
            from: details.globalPosition,
            cause: SelectionChangedCause.drag,
          );
      }
    }
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
  void onDragSelectionUpdate(TapDragUpdateDetails updateDetails) {
    if (delegate.selectionEnabled == false) return;
    // if (editor?.textEditingValue.selection.isCollapsed == false) return;
    if (!_isShiftPressed) {
      // Adjust the drag start offset for possible viewport offset changes.
      final editableOffset = Offset(
          0, (renderEditor!.offset?.pixels ?? 0) - _dragStartViewportOffset);
      final scrollableOffset =
          Offset(0, _scrollPosition - _dragStartScrollOffset);
      final dragStartGlobalPosition =
          updateDetails.globalPosition - updateDetails.offsetFromOrigin;

      // Select word by word.
      if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
              updateDetails.consecutiveTapCount) ==
          2) {
        renderEditor?.selectWordsInRange(
          dragStartGlobalPosition - editableOffset - scrollableOffset,
          updateDetails.globalPosition,
          SelectionChangedCause.drag,
        );

        switch (updateDetails.kind) {
          case PointerDeviceKind.stylus:
          case PointerDeviceKind.invertedStylus:
          case PointerDeviceKind.touch:
          case PointerDeviceKind.unknown:
            return editor?.updateMagnifier(updateDetails.globalPosition);
          case PointerDeviceKind.mouse:
          case PointerDeviceKind.trackpad:
          case null:
            return;
        }
      }

      // Select paragraph-by-paragraph.
      if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
              updateDetails.consecutiveTapCount) ==
          3) {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.iOS:
            switch (updateDetails.kind) {
              case PointerDeviceKind.mouse:
              case PointerDeviceKind.trackpad:
                return _selectParagraphsInRange(
                  from: dragStartGlobalPosition -
                      editableOffset -
                      scrollableOffset,
                  to: updateDetails.globalPosition,
                  cause: SelectionChangedCause.drag,
                );
              case PointerDeviceKind.stylus:
              case PointerDeviceKind.invertedStylus:
              case PointerDeviceKind.touch:
              case PointerDeviceKind.unknown:
              case null:
                // Triple tap to drag is not present on these platforms when using
                // non-precise pointer devices at the moment.
                break;
            }
            return;
          case TargetPlatform.linux:
            return _selectLinesInRange(
              from: dragStartGlobalPosition - editableOffset - scrollableOffset,
              to: updateDetails.globalPosition,
              cause: SelectionChangedCause.drag,
            );
          case TargetPlatform.windows:
          case TargetPlatform.macOS:
            return _selectParagraphsInRange(
              from: dragStartGlobalPosition - editableOffset - scrollableOffset,
              to: updateDetails.globalPosition,
              cause: SelectionChangedCause.drag,
            );
        }
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          // With a touch device, nothing should happen, unless there was a double tap, or
          // there was a collapsed selection, and the tap/drag position is at the collapsed selection.
          // In that case the caret should move with the drag position.
          //
          // With a mouse device, a drag should select the range from the origin of the drag
          // to the current position of the drag.
          switch (updateDetails.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
              renderEditor?.selectPositionAt(
                from:
                    dragStartGlobalPosition - editableOffset - scrollableOffset,
                to: updateDetails.globalPosition,
                cause: SelectionChangedCause.drag,
              );
              return;
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              assert(_dragBeganOnPreviousSelection != null);
              if (renderEditor?.hasFocus == true &&
                  _dragStartSelection!.isCollapsed &&
                  _dragBeganOnPreviousSelection!) {
                renderEditor?.selectPositionAt(
                  from: updateDetails.globalPosition,
                  cause: SelectionChangedCause.drag,
                );
                return editor?.updateMagnifier(updateDetails.globalPosition);
              }
            case null:
              break;
          }
          return;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          // With a precise pointer device, such as a mouse, trackpad, or stylus,
          // the drag will select the text spanning the origin of the drag to the end of the drag.
          // With a touch device, the cursor should move with the drag.
          switch (updateDetails.kind) {
            case PointerDeviceKind.mouse:
            case PointerDeviceKind.trackpad:
            case PointerDeviceKind.stylus:
            case PointerDeviceKind.invertedStylus:
              renderEditor?.selectPositionAt(
                from:
                    dragStartGlobalPosition - editableOffset - scrollableOffset,
                to: updateDetails.globalPosition,
                cause: SelectionChangedCause.drag,
              );
              return;
            case PointerDeviceKind.touch:
            case PointerDeviceKind.unknown:
              if (renderEditor?.hasFocus == true) {
                renderEditor?.selectPositionAt(
                  from: updateDetails.globalPosition,
                  cause: SelectionChangedCause.drag,
                );
                return editor?.updateMagnifier(updateDetails.globalPosition);
              }
            case null:
              break;
          }
          return;
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          renderEditor?.selectPositionAt(
            from: dragStartGlobalPosition - editableOffset - scrollableOffset,
            to: updateDetails.globalPosition,
            cause: SelectionChangedCause.drag,
          );
      }
    }

    if (_dragStartSelection!.isCollapsed ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      return _extendSelection(
          updateDetails.globalPosition, SelectionChangedCause.drag);
    }

    // If the drag inverts the selection, Mac and iOS revert to the initial
    // selection.
    final selection = renderEditor!.selection;
    final nextExtent =
        renderEditor!.getPositionForOffset(updateDetails.globalPosition);

    final isShiftTapDragSelectionForward =
        _dragStartSelection!.baseOffset < _dragStartSelection!.extentOffset;
    final isInverted = isShiftTapDragSelectionForward
        ? nextExtent.offset < _dragStartSelection!.baseOffset
        : nextExtent.offset > _dragStartSelection!.baseOffset;
    if (isInverted && selection.baseOffset == _dragStartSelection!.baseOffset) {
      editor?.userUpdateTextEditingValue(
        editor!.textEditingValue.copyWith(
          selection: TextSelection(
            baseOffset: _dragStartSelection!.extentOffset,
            extentOffset: nextExtent.offset,
          ),
        ),
        SelectionChangedCause.drag,
      );
    } else if (!isInverted &&
        nextExtent.offset != _dragStartSelection!.baseOffset &&
        selection.baseOffset != _dragStartSelection!.baseOffset) {
      editor?.userUpdateTextEditingValue(
        editor!.textEditingValue.copyWith(
          selection: TextSelection(
            baseOffset: _dragStartSelection!.baseOffset,
            extentOffset: nextExtent.offset,
          ),
        ),
        SelectionChangedCause.drag,
      );
    } else {
      _extendSelection(
          updateDetails.globalPosition, SelectionChangedCause.drag);
    }
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
  void onDragSelectionEnd(TapDragEndDetails details) {
    // if (editor?.textEditingValue.selection.isCollapsed == false) return;
    renderEditor!.handleDragEnd(details);
    if (isDesktop &&
        delegate.selectionEnabled &&
        checkSelectionToolbarShouldShow(isAdditionalAction: false)) {
      // added to show selection copy/paste toolbar after drag to select
      editor!.showToolbar();
    }
    editor?.hideMagnifier();
  }

  /// Returns a [EditorTextSelectionGestureDetector] configured with
  /// the handlers provided by this builder.
  ///
  /// The [child] or its subtree should contain [EditableText].
  Widget build({
    required HitTestBehavior behavior,
    required Widget child,
    Key? key,
    bool detectWordBoundary = true,
  }) {
    return EditorTextSelectionGestureDetector(
      key: key,
      onTapTrackStart: onTapTrackStart,
      onTapTrackReset: onTapTrackReset,
      onTapDown: onTapDown,
      onForcePressStart: delegate.forcePressEnabled ? onForcePressStart : null,
      onForcePressEnd: delegate.forcePressEnabled ? onForcePressEnd : null,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown,
      onSingleTapUp: onSingleTapUp,
      onSingleTapCancel: onSingleTapCancel,
      onUserTap: onUserTap,
      onSingleLongTapStart: onSingleLongTapStart,
      onSingleLongTapMoveUpdate: onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: onSingleLongTapEnd,
      onDoubleTapDown: onDoubleTapDown,
      onTripleTapDown: onTripleTapDown,
      onDragSelectionStart: onDragSelectionStart,
      onDragSelectionUpdate: onDragSelectionUpdate,
      onDragSelectionEnd: onDragSelectionEnd,
      onUserTapAlwaysCalled: onUserTapAlwaysCalled,
      behavior: behavior,
      child: child,
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../document/nodes/node.dart';
import '../../editor.dart';

TextSelection localSelection(Node node, TextSelection selection, fromParent) {
  final base = fromParent ? node.offset : node.documentOffset;
  assert(base <= selection.end && selection.start <= base + node.length - 1);

  final offset = fromParent ? node.offset : node.documentOffset;
  return selection.copyWith(
      baseOffset: math.max(selection.start - offset, 0),
      extentOffset: math.min(selection.end - offset, node.length - 1));
}

/// The text position that a give selection handle manipulates. Dragging the
/// [start] handle always moves the [start]/[baseOffset] of the selection.
enum _TextSelectionHandlePosition { start, end }

/// internal use, used to get drag direction information
class DragTextSelection extends TextSelection {
  const DragTextSelection({
    super.affinity,
    super.baseOffset = 0,
    super.extentOffset = 0,
    super.isDirectional,
    this.first = true,
  });

  final bool first;

  @override
  DragTextSelection copyWith({
    int? baseOffset,
    int? extentOffset,
    TextAffinity? affinity,
    bool? isDirectional,
    bool? first,
  }) {
    return DragTextSelection(
      baseOffset: baseOffset ?? this.baseOffset,
      extentOffset: extentOffset ?? this.extentOffset,
      affinity: affinity ?? this.affinity,
      isDirectional: isDirectional ?? this.isDirectional,
      first: first ?? this.first,
    );
  }
}

/// An object that manages a pair of text selection handles.
///
/// The selection handles are displayed in the [Overlay] that most closely
/// encloses the given [BuildContext].
class EditorTextSelectionOverlay {
  /// Creates an object that manages overlay entries for selection handles.
  ///
  /// The [context] must not be null and must have an [Overlay] as an ancestor.
  EditorTextSelectionOverlay({
    required this.value,
    required this.context,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.renderObject,
    required this.debugRequiredFor,
    required this.selectionCtrls,
    required this.selectionDelegate,
    required this.contextMenuBuilder,
    this.clipboardStatus,
    this.onSelectionHandleTapped,
    this.dragStartBehavior = DragStartBehavior.start,
    this.handlesVisible = false,
    this.magnifierConfiguration = TextMagnifierConfiguration.disabled,
  }) {
    // Clipboard status is only checked on first instance of
    // ClipboardStatusNotifier
    // if state has changed after creation, but prior to
    // our listener being created
    // we won't know the status unless there is forced update
    // i.e. occasionally no paste
    if (clipboardStatus != null && !kIsWeb) {
      // Web - esp Safari Mac/iOS has security measures in place that restrict
      // cliboard status checks w/o direct user interaction. So skip this
      // for web
      clipboardStatus!.update();
    }
  }

  TextEditingValue value;

  /// Whether selection handles are visible.
  ///
  /// Set to false if you want to hide the handles. Use this property to show or
  /// hide the handle without rebuilding them.
  ///
  /// If this method is called while the [SchedulerBinding.schedulerPhase] is
  /// [SchedulerPhase.persistentCallbacks], i.e. during the build, layout, or
  /// paint phases (see [WidgetsBinding.drawFrame]), then the update is delayed
  /// until the post-frame callbacks phase. Otherwise the update is done
  /// synchronously. This means that it is safe to call during builds, but also
  /// that if you do call this during a build, the UI will not update until the
  /// next frame (i.e. many milliseconds later).
  ///
  /// Defaults to false.
  bool handlesVisible = false;

  /// The context in which the selection handles should appear.
  ///
  /// This context must have an [Overlay] as an ancestor because this object
  /// will display the text selection handles in that [Overlay].
  final BuildContext context;

  /// Debugging information for explaining why the [Overlay] is required.
  final Widget debugRequiredFor;

  /// The objects supplied to the [CompositedTransformTarget] that wraps the
  /// location of start selection handle.
  final LayerLink startHandleLayerLink;

  /// The objects supplied to the [CompositedTransformTarget] that wraps the
  /// location of end selection handle.
  final LayerLink endHandleLayerLink;

  /// The editable line in which the selected text is being displayed.
  final RenderEditor renderObject;

  /// Builds text selection handles and toolbar.
  final TextSelectionControls selectionCtrls;

  /// The delegate for manipulating the current selection in the owning
  /// text field.
  final TextSelectionDelegate selectionDelegate;

  /// {@macro flutter.widgets.EditableText.contextMenuBuilder}
  ///
  /// If not provided, no context menu will be built.
  final WidgetBuilder? contextMenuBuilder;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], handle drag behavior will
  /// begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first
  /// detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior],
  ///  which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  /// {@template flutter.widgets.textSelection.onSelectionHandleTapped}
  /// A callback that's invoked when a selection handle is tapped.
  ///
  /// Both regular taps and long presses invoke this callback, but a drag
  /// gesture won't.
  /// {@endtemplate}
  final VoidCallback? onSelectionHandleTapped;

  /// Maintains the status of the clipboard for determining if its contents can
  /// be pasted or not.
  ///
  /// Useful because the actual value of the clipboard can only be checked
  /// asynchronously (see [Clipboard.getData]).
  final ClipboardStatusNotifier? clipboardStatus;

  /// A pair of handles. If this is non-null, there are always 2, though the
  /// second is hidden when the selection is collapsed.
  List<OverlayEntry>? _handles;

  /// A copy/paste toolbar.
  OverlayEntry? toolbar;
  bool _restoreToolbar = false;

  TextSelection get _selection => value.selection;

  final MagnifierController _magnifierController = MagnifierController();

  bool get magnifierIsVisible => _magnifierController.shown;

  final TextMagnifierConfiguration magnifierConfiguration;

  final ValueNotifier<MagnifierInfo> _magnifierInfo =
      ValueNotifier<MagnifierInfo>(MagnifierInfo.empty);

  void setHandlesVisible(bool visible) {
    if (handlesVisible == visible) {
      return;
    }
    handlesVisible = visible;
    // If we are in build state, it will be too late to update visibility.
    // We will need to schedule the build in next frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  /// Destroys the handles by removing them from overlay.
  void hideHandles() {
    if (_handles == null) {
      return;
    }
    _handles![0].remove();
    _handles![1].remove();
    _handles = null;
  }

  /// Hides the toolbar part of the overlay.
  ///
  /// To hide the whole overlay, see [hide].
  void hideToolbar() {
    assert(toolbar != null);
    toolbar!.remove();
    toolbar = null;
  }

  /// Shows the toolbar by inserting it into the [context]'s overlay.
  void showToolbar() {
    assert(toolbar == null);
    if (contextMenuBuilder == null) return;
    toolbar = OverlayEntry(builder: (context) {
      return contextMenuBuilder!(context);
    });
    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)
        .insert(toolbar!);

    // make sure handles are visible as well
    if (_handles == null) {
      showHandles();
    }
  }

  Widget _buildHandle(
      BuildContext context, _TextSelectionHandlePosition position) {
    if (_selection.isCollapsed &&
        position == _TextSelectionHandlePosition.end) {
      return const SizedBox.shrink();
    }
    return Visibility(
        visible: handlesVisible,
        child: _TextSelectionHandleOverlay(
          onSelectionHandleChanged: (newSelection) {
            _handleSelectionHandleChanged(newSelection, position);
          },
          onSelectionHandleTapped: onSelectionHandleTapped,
          startHandleLayerLink: startHandleLayerLink,
          endHandleLayerLink: endHandleLayerLink,
          renderObject: renderObject,
          selection: _selection,
          selectionControls: selectionCtrls,
          position: position,
          onHandleDragStart: _onHandleDragStart,
          onHandleDragUpdate: _onHandleDragUpdate,
          onHandleDragEnd: _onHandleDragEnd,
          dragStartBehavior: dragStartBehavior,
        ));
  }

  /// Updates the overlay after the selection has changed.
  ///
  /// If this method is called while the [SchedulerBinding.schedulerPhase] is
  /// [SchedulerPhase.persistentCallbacks], i.e. during the build, layout, or
  /// paint phases (see [WidgetsBinding.drawFrame]), then the update is delayed
  /// until the post-frame callbacks phase. Otherwise the update is done
  /// synchronously. This means that it is safe to call during builds, but also
  /// that if you do call this during a build, the UI will not update until the
  /// next frame (i.e. many milliseconds later).
  void update(TextEditingValue newValue) {
    if (value == newValue) {
      return;
    }
    value = newValue;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  void _handleSelectionHandleChanged(
    TextSelection? newSelection,
    _TextSelectionHandlePosition position,
  ) {
    TextPosition textPosition;
    switch (position) {
      case _TextSelectionHandlePosition.start:
        textPosition = newSelection != null
            ? newSelection.base
            : const TextPosition(offset: 0);
        break;
      case _TextSelectionHandlePosition.end:
        textPosition = newSelection != null
            ? newSelection.extent
            : const TextPosition(offset: 0);
        break;
      default:
        throw ArgumentError('Invalid position');
    }

    final currSelection = newSelection != null
        ? DragTextSelection(
            baseOffset: newSelection.baseOffset,
            extentOffset: newSelection.extentOffset,
            affinity: newSelection.affinity,
            isDirectional: newSelection.isDirectional,
            first: position == _TextSelectionHandlePosition.start,
          )
        : null;

    update(value.copyWith(
      selection: currSelection,
      composing: TextRange.empty,
    ));

    selectionDelegate
      ..userUpdateTextEditingValue(value, SelectionChangedCause.drag)
      ..bringIntoView(textPosition);
  }

  void markNeedsBuild([Duration? duration]) {
    if (_handles != null) {
      _handles![0].markNeedsBuild();
      _handles![1].markNeedsBuild();
    }
    toolbar?.markNeedsBuild();
  }

  /// Hides the entire overlay including the toolbar and the handles.
  void hide() {
    if (_handles != null) {
      _handles![0].remove();
      _handles![1].remove();
      _handles = null;
    }
    if (toolbar != null) {
      hideToolbar();
    }
  }

  /// Final cleanup.
  void dispose() {
    hide();
    _magnifierInfo.dispose();
  }

  /// Builds the handles by inserting them into the [context]'s overlay.
  void showHandles() {
    if (_handles != null) return;
    _handles = <OverlayEntry>[
      OverlayEntry(
          builder: (context) =>
              _buildHandle(context, _TextSelectionHandlePosition.start)),
      OverlayEntry(
          builder: (context) =>
              _buildHandle(context, _TextSelectionHandlePosition.end)),
    ];

    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)
        .insertAll(_handles!);
  }

  /// Causes the overlay to update its rendering.
  ///
  /// This is intended to be called when the [renderObject] may have changed its
  /// text metrics (e.g. because the text was scrolled).
  void updateForScroll() {
    markNeedsBuild();
  }

  void _onHandleDragStart(DragStartDetails details, TextPosition position) {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) return;
    showMagnifier(position, details.globalPosition, renderObject);
  }

  void _onHandleDragUpdate(DragUpdateDetails details, TextPosition position) {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) return;
    updateMagnifier(position, details.globalPosition, renderObject);
  }

  void _onHandleDragEnd(DragEndDetails details) {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) return;
    hideMagnifier();
  }

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

  void _showMagnifier(MagnifierInfo initialMagnifierInfo) {
    // 隐藏toolbar
    if (toolbar != null) {
      _restoreToolbar = true;
      hideToolbar();
    } else {
      _restoreToolbar = false;
    }

    // 更新 magnifierInfo
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

  void _updateMagnifier(MagnifierInfo magnifierInfo) {
    if (_magnifierController.overlayEntry == null) {
      return;
    }
    _magnifierInfo.value = magnifierInfo;
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
}

typedef DargHandleCallback<T> = void Function(T details, TextPosition position);

/// This widget represents a single draggable text selection handle.
class _TextSelectionHandleOverlay extends StatefulWidget {
  const _TextSelectionHandleOverlay({
    required this.selection,
    required this.position,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.renderObject,
    required this.onSelectionHandleChanged,
    required this.onSelectionHandleTapped,
    required this.selectionControls,
    required this.onHandleDragStart,
    required this.onHandleDragUpdate,
    required this.onHandleDragEnd,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  final TextSelection selection;
  final _TextSelectionHandlePosition position;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final RenderEditor renderObject;
  final ValueChanged<TextSelection?> onSelectionHandleChanged;
  final DargHandleCallback<DragStartDetails>? onHandleDragStart;
  final DargHandleCallback<DragUpdateDetails>? onHandleDragUpdate;
  final ValueChanged<DragEndDetails> onHandleDragEnd;
  final VoidCallback? onSelectionHandleTapped;
  final TextSelectionControls selectionControls;
  final DragStartBehavior dragStartBehavior;

  @override
  _TextSelectionHandleOverlayState createState() =>
      _TextSelectionHandleOverlayState();

  ValueListenable<bool> get _visibility {
    switch (position) {
      case _TextSelectionHandlePosition.start:
        return renderObject.selectionStartInViewport;
      case _TextSelectionHandlePosition.end:
        return renderObject.selectionEndInViewport;
      default:
        throw ArgumentError('Invalid position');
    }
  }
}

class _TextSelectionHandleOverlayState
    extends State<_TextSelectionHandleOverlay>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  late Offset _dragPosition;

  late AnimationController _controller;

  Animation<double> get _opacity => _controller.view;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _handleVisibilityChanged();
    widget._visibility.addListener(_handleVisibilityChanged);
  }

  void _handleVisibilityChanged() {
    if (widget._visibility.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(_TextSelectionHandleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget._visibility.removeListener(_handleVisibilityChanged);
    _handleVisibilityChanged();
    widget._visibility.addListener(_handleVisibilityChanged);
  }

  @override
  void dispose() {
    widget._visibility.removeListener(_handleVisibilityChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (!widget.renderObject.attached) return;
    final textPosition = widget.position == _TextSelectionHandlePosition.start
        ? widget.selection.base
        : widget.selection.extent;
    final lineHeight = widget.renderObject.preferredLineHeight(textPosition);
    final handleSize = widget.selectionControls.getHandleSize(lineHeight);
    _dragPosition = details.globalPosition + Offset(0, -handleSize.height);
    widget.onHandleDragStart?.call(details, textPosition);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.renderObject.attached) return;
    _dragPosition += details.delta;
    final position =
        widget.renderObject.getPositionForOffset(details.globalPosition);
    if (widget.selection.isCollapsed) {
      widget.onSelectionHandleChanged(TextSelection.fromPosition(position));
      return;
    }

    final isNormalized =
        widget.selection.extentOffset >= widget.selection.baseOffset;
    TextSelection newSelection;
    switch (widget.position) {
      case _TextSelectionHandlePosition.start:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? position.offset : widget.selection.baseOffset,
          extentOffset:
              isNormalized ? widget.selection.extentOffset : position.offset,
        );
        break;
      case _TextSelectionHandlePosition.end:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? widget.selection.baseOffset : position.offset,
          extentOffset:
              isNormalized ? position.offset : widget.selection.extentOffset,
        );
        break;
      default:
        throw ArgumentError('Invalid widget.position');
    }

    if (newSelection.baseOffset >= newSelection.extentOffset) {
      return; // don't allow order swapping.
    }
    widget.onSelectionHandleChanged(newSelection);
    if (widget.position == _TextSelectionHandlePosition.start) {
      widget.onHandleDragUpdate?.call(details, newSelection.base);
    } else if (widget.position == _TextSelectionHandlePosition.end) {
      widget.onHandleDragUpdate?.call(details, newSelection.extent);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.renderObject.attached) return;
    widget.onHandleDragEnd.call(details);
  }

  void _handleTap() {
    widget.onSelectionHandleTapped?.call();
  }

  @override
  Widget build(BuildContext context) {
    late LayerLink layerLink;
    TextSelectionHandleType? type;

    switch (widget.position) {
      case _TextSelectionHandlePosition.start:
        layerLink = widget.startHandleLayerLink;
        type = _chooseType(
          widget.renderObject.textDirection,
          TextSelectionHandleType.left,
          TextSelectionHandleType.right,
        );
        break;
      case _TextSelectionHandlePosition.end:
        // For collapsed selections, we shouldn't be building the [end] handle.
        assert(!widget.selection.isCollapsed);
        layerLink = widget.endHandleLayerLink;
        type = _chooseType(
          widget.renderObject.textDirection,
          TextSelectionHandleType.right,
          TextSelectionHandleType.left,
        );
        break;
    }

    // TODO: This logic doesn't work for TextStyle.height larger 1.
    // It makes the extent handle top end on iOS extend too high which makes
    // stick out above the selection background.
    // May have to use getSelectionBoxes instead of preferredLineHeight.
    // or expose TextStyle on the render object and calculate
    // preferredLineHeight / style.height
    final textPosition = widget.position == _TextSelectionHandlePosition.start
        ? widget.selection.base
        : widget.selection.extent;
    final lineHeight = widget.renderObject.preferredLineHeight(textPosition);
    final handleAnchor =
        widget.selectionControls.getHandleAnchor(type!, lineHeight);
    final handleSize = widget.selectionControls.getHandleSize(lineHeight);

    final handleRect = Rect.fromLTWH(
      -handleAnchor.dx,
      -handleAnchor.dy,
      handleSize.width,
      handleSize.height,
    );

    // Make sure the GestureDetector is big enough to be easily interactive.
    final interactiveRect = handleRect.expandToInclude(
      Rect.fromCircle(
          center: handleRect.center, radius: kMinInteractiveDimension / 2),
    );
    final padding = RelativeRect.fromLTRB(
      math.max((interactiveRect.width - handleRect.width) / 2, 0),
      math.max((interactiveRect.height - handleRect.height) / 2, 0),
      math.max((interactiveRect.width - handleRect.width) / 2, 0),
      math.max((interactiveRect.height - handleRect.height) / 2, 0),
    );

    return CompositedTransformFollower(
      link: layerLink,
      offset: interactiveRect.topLeft,
      showWhenUnlinked: false,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          alignment: Alignment.topLeft,
          width: interactiveRect.width,
          height: interactiveRect.height,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            dragStartBehavior: widget.dragStartBehavior,
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            onTap: _handleTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                top: padding.top,
                right: padding.right,
                bottom: padding.bottom,
              ),
              child: widget.selectionControls.buildHandle(
                context,
                type,
                lineHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextSelectionHandleType? _chooseType(
    TextDirection textDirection,
    TextSelectionHandleType ltrType,
    TextSelectionHandleType rtlType,
  ) {
    if (widget.selection.isCollapsed) return TextSelectionHandleType.collapsed;

    switch (textDirection) {
      case TextDirection.ltr:
        return ltrType;
      case TextDirection.rtl:
        return rtlType;
    }
  }
}

/// A gesture detector to respond to non-exclusive event chains for a
/// text field.
///
/// An ordinary [GestureDetector] configured to handle events like tap and
/// double tap will only recognize one or the other. This widget detects both:
/// first the tap and then, if another tap down occurs within a time limit, the
/// double tap.
///
/// See also:
///
///  * [TextField], a Material text field which uses this gesture detector.
///  * [CupertinoTextField], a Cupertino text field which uses this gesture
///    detector.
class EditorTextSelectionGestureDetector extends StatefulWidget {
  /// Create a [EditorTextSelectionGestureDetector].
  ///
  /// Multiple callbacks can be called for one sequence of input gesture.
  /// The [child] parameter must not be null.
  const EditorTextSelectionGestureDetector({
    required this.child,
    super.key,
    this.onTapTrackStart,
    this.onTapTrackReset,
    this.onTapDown,
    this.onForcePressStart,
    this.onForcePressEnd,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSingleTapUp,
    this.onSingleTapCancel,
    this.onUserTap,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.onDoubleTapDown,
    this.onTripleTapDown,
    this.onDragSelectionStart,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.onUserTapAlwaysCalled = false,
    this.behavior,
  });

  /// {@macro flutter.gestures.selectionrecognizers.BaseTapAndDragGestureRecognizer.onTapTrackStart}
  final VoidCallback? onTapTrackStart;

  /// {@macro flutter.gestures.selectionrecognizers.BaseTapAndDragGestureRecognizer.onTapTrackReset}
  final VoidCallback? onTapTrackReset;

  /// Called for every tap down including every tap down that's part of a
  /// double click or a long press, except touches that include enough movement
  /// to not qualify as taps (e.g. pans and flings).
  final GestureTapDragDownCallback? onTapDown;

  /// Called when a pointer has tapped down and the force of the pointer has
  /// just become greater than [ForcePressGestureRecognizer.startPressure].
  final GestureForcePressStartCallback? onForcePressStart;

  /// Called when a pointer that had previously triggered [onForcePressStart] is
  /// lifted off the screen.
  final GestureForcePressEndCallback? onForcePressEnd;

  /// Called for a tap event with the secondary mouse button.
  final GestureTapCallback? onSecondaryTap;

  /// Called for a tap down event with the secondary mouse button.
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Called for the first tap in a series of taps, consecutive taps do not call
  /// this method.
  ///
  /// For example, if the detector was configured with [onTapDown] and
  /// [onDoubleTapDown], three quick taps would be recognized as a single tap
  /// down, followed by a tap up, then a double tap down, followed by a single tap down.
  final GestureTapDragUpCallback? onSingleTapUp;

  /// Called for each touch that becomes recognized as a gesture that is not a
  /// short tap, such as a long tap or drag. It is called at the moment when
  /// another gesture from the touch is recognized.
  final GestureCancelCallback? onSingleTapCancel;

  /// Called for the first tap in a series of taps when [onUserTapAlwaysCalled] is
  /// disabled, which is the default behavior.
  ///
  /// When [onUserTapAlwaysCalled] is enabled, this is called for every tap,
  /// including consecutive taps.
  final GestureTapCallback? onUserTap;

  /// Called for a single long tap that's sustained for longer than
  /// [kLongPressTimeout] but not necessarily lifted. Not called for a
  /// double-tap-hold, which calls [onDoubleTapDown] instead.
  final GestureLongPressStartCallback? onSingleLongTapStart;

  /// Called after [onSingleLongTapStart] when the pointer is dragged.
  final GestureLongPressMoveUpdateCallback? onSingleLongTapMoveUpdate;

  /// Called after [onSingleLongTapStart] when the pointer is lifted.
  final GestureLongPressEndCallback? onSingleLongTapEnd;

  /// Called after a momentary hold or a short tap that is close in space and
  /// time (within [kDoubleTapTimeout]) to a previous short tap.
  final GestureTapDragDownCallback? onDoubleTapDown;

  /// Called after a momentary hold or a short tap that is close in space and
  /// time (within [kDoubleTapTimeout]) to a previous double-tap.
  final GestureTapDragDownCallback? onTripleTapDown;

  /// Called when a mouse starts dragging to select text.
  final GestureTapDragStartCallback? onDragSelectionStart;

  /// Called repeatedly as a mouse moves while dragging.
  final GestureTapDragUpdateCallback? onDragSelectionUpdate;

  /// Called when a mouse that was previously dragging is released.
  final GestureTapDragEndCallback? onDragSelectionEnd;

  /// Whether [onUserTap] will be called for all taps including consecutive taps.
  ///
  /// Defaults to false, so [onUserTap] is only called for each distinct tap.
  final bool onUserTapAlwaysCalled;

  /// How this gesture detector should behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.deferToChild].
  final HitTestBehavior? behavior;

  /// Child below this widget.
  final Widget child;

  @override
  State<StatefulWidget> createState() =>
      _EditorTextSelectionGestureDetectorState();

  static int getEffectiveConsecutiveTapCount(int rawCount) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
        // From observation, these platform's reset their tap count to 0 when
        // the number of consecutive taps exceeds 3. For example on Debian Linux
        // with GTK, when going past a triple click, on the fourth click the
        // selection is moved to the precise click position, on the fifth click
        // the word at the position is selected, and on the sixth click the
        // paragraph at the position is selected.
        return rawCount <= 3
            ? rawCount
            : (rawCount % 3 == 0 ? 3 : rawCount % 3);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // From observation, these platform's either hold their tap count at 3.
        // For example on macOS, when going past a triple click, the selection
        // should be retained at the paragraph that was first selected on triple
        // click.
        return math.min(rawCount, 3);
      case TargetPlatform.windows:
        // From observation, this platform's consecutive tap actions alternate
        // between double click and triple click actions. For example, after a
        // triple click has selected a paragraph, on the next click the word at
        // the clicked position will be selected, and on the next click the
        // paragraph at the position is selected.
        return rawCount < 2 ? rawCount : 2 + rawCount % 2;
    }
  }
}

class _EditorTextSelectionGestureDetectorState
    extends State<EditorTextSelectionGestureDetector> {
  // Converts the details.consecutiveTapCount from a TapAndDrag*Details object,
  // which can grow to be infinitely large, to a value between 1 and 3. The value
  // that the raw count is converted to is based on the default observed behavior
  // on the native platforms.
  //
  // This method should be used in all instances when details.consecutiveTapCount
  // would be used.

  void _handleTapTrackStart() {
    widget.onTapTrackStart?.call();
  }

  void _handleTapTrackReset() {
    widget.onTapTrackReset?.call();
  }

  // The down handler is force-run on success of a single tap and optimistically
  // run before a long press success.
  void _handleTapDown(TapDragDownDetails details) {
    widget.onTapDown?.call(details);
    // This isn't detected as a double tap gesture in the gesture recognizer
    // because it's 2 single taps, each of which may do different things depending
    // on whether it's a single tap, the first tap of a double tap, the second
    // tap held down, a clean double tap etc.
    if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
            details.consecutiveTapCount) ==
        2) {
      return widget.onDoubleTapDown?.call(details);
    }

    if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
            details.consecutiveTapCount) ==
        3) {
      return widget.onTripleTapDown?.call(details);
    }
  }

  void _handleTapUp(TapDragUpDetails details) {
    if (EditorTextSelectionGestureDetector.getEffectiveConsecutiveTapCount(
            details.consecutiveTapCount) ==
        1) {
      widget.onSingleTapUp?.call(details);
      widget.onUserTap?.call();
    } else if (widget.onUserTapAlwaysCalled) {
      widget.onUserTap?.call();
    }
  }

  void _handleTapCancel() {
    widget.onSingleTapCancel?.call();
  }

  void _handleDragStart(TapDragStartDetails details) {
    widget.onDragSelectionStart?.call(details);
  }

  void _handleDragUpdate(TapDragUpdateDetails details) {
    widget.onDragSelectionUpdate?.call(details);
  }

  void _handleDragEnd(TapDragEndDetails details) {
    widget.onDragSelectionEnd?.call(details);
  }

  void _forcePressStarted(ForcePressDetails details) {
    widget.onForcePressStart?.call(details);
  }

  void _forcePressEnded(ForcePressDetails details) {
    widget.onForcePressEnd?.call(details);
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (widget.onSingleLongTapStart != null) {
      widget.onSingleLongTapStart!(details);
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (widget.onSingleLongTapMoveUpdate != null) {
      widget.onSingleLongTapMoveUpdate!(details);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (widget.onSingleLongTapEnd != null) {
      widget.onSingleLongTapEnd!(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gestures = <Type, GestureRecognizerFactory>{};

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(debugOwner: this),
      (instance) {
        instance
          ..onSecondaryTap = widget.onSecondaryTap
          ..onSecondaryTapDown = widget.onSecondaryTapDown;
      },
    );

    if (widget.onSingleLongTapStart != null ||
        widget.onSingleLongTapMoveUpdate != null ||
        widget.onSingleLongTapEnd != null) {
      gestures[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(
            debugOwner: this,
            supportedDevices: <PointerDeviceKind>{PointerDeviceKind.touch}),
        (instance) {
          instance
            ..onLongPressStart = _handleLongPressStart
            ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
            ..onLongPressEnd = _handleLongPressEnd;
        },
      );
    }

    if (widget.onDragSelectionStart != null ||
        widget.onDragSelectionUpdate != null ||
        widget.onDragSelectionEnd != null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.iOS:
          gestures[TapAndHorizontalDragGestureRecognizer] =
              GestureRecognizerFactoryWithHandlers<
                  TapAndHorizontalDragGestureRecognizer>(
            () => TapAndHorizontalDragGestureRecognizer(debugOwner: this),
            (instance) {
              instance
                // Text selection should start from the position of the first pointer
                // down event.
                ..dragStartBehavior = DragStartBehavior.down
                ..onTapTrackStart = _handleTapTrackStart
                ..onTapTrackReset = _handleTapTrackReset
                ..onTapDown = _handleTapDown
                ..onDragStart = _handleDragStart
                ..onDragUpdate = _handleDragUpdate
                ..onDragEnd = _handleDragEnd
                ..onTapUp = _handleTapUp
                ..onCancel = _handleTapCancel;
            },
          );
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
          gestures[TapAndPanGestureRecognizer] =
              GestureRecognizerFactoryWithHandlers<TapAndPanGestureRecognizer>(
            () => TapAndPanGestureRecognizer(debugOwner: this),
            (instance) {
              instance
                // Text selection should start from the position of the first pointer
                // down event.
                ..dragStartBehavior = DragStartBehavior.down
                ..onTapTrackStart = _handleTapTrackStart
                ..onTapTrackReset = _handleTapTrackReset
                ..onTapDown = _handleTapDown
                ..onDragStart = _handleDragStart
                ..onDragUpdate = _handleDragUpdate
                ..onDragEnd = _handleDragEnd
                ..onTapUp = _handleTapUp
                ..onCancel = _handleTapCancel;
            },
          );
      }
    }

    if (widget.onForcePressStart != null || widget.onForcePressEnd != null) {
      gestures[ForcePressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
        () => ForcePressGestureRecognizer(debugOwner: this),
        (instance) {
          instance
            ..onStart =
                widget.onForcePressStart != null ? _forcePressStarted : null
            ..onEnd = widget.onForcePressEnd != null ? _forcePressEnded : null;
        },
      );
    }

    return RawGestureDetector(
      gestures: gestures,
      excludeFromSemantics: true,
      behavior: widget.behavior,
      child: widget.child,
    );
  }
}

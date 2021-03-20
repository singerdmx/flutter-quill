import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';

import 'editor.dart';

TextSelection localSelection(Node node, TextSelection selection, fromParent) {
  int base = fromParent ? node.getOffset() : node.getDocumentOffset();
  assert(base <= selection.end && selection.start <= base + node.length - 1);

  int offset = fromParent ? node.getOffset() : node.getDocumentOffset();
  return selection.copyWith(
      baseOffset: math.max(selection.start - offset, 0),
      extentOffset: math.min(selection.end - offset, node.length - 1));
}

enum _TextSelectionHandlePosition { START, END }

class EditorTextSelectionOverlay {
  TextEditingValue value;
  bool handlesVisible = false;
  final BuildContext context;
  final Widget debugRequiredFor;
  final LayerLink toolbarLayerLink;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final RenderEditor? renderObject;
  final TextSelectionControls selectionCtrls;
  final TextSelectionDelegate selectionDelegate;
  final DragStartBehavior dragStartBehavior;
  final VoidCallback? onSelectionHandleTapped;
  final ClipboardStatusNotifier clipboardStatus;
  late AnimationController _toolbarController;
  List<OverlayEntry>? _handles;
  OverlayEntry? toolbar;

  EditorTextSelectionOverlay(
      this.value,
      this.handlesVisible,
      this.context,
      this.debugRequiredFor,
      this.toolbarLayerLink,
      this.startHandleLayerLink,
      this.endHandleLayerLink,
      this.renderObject,
      this.selectionCtrls,
      this.selectionDelegate,
      this.dragStartBehavior,
      this.onSelectionHandleTapped,
      this.clipboardStatus) {
    OverlayState overlay = Overlay.of(context, rootOverlay: true)!;

    _toolbarController = AnimationController(
        duration: Duration(milliseconds: 150), vsync: overlay);
  }

  TextSelection get _selection => value.selection;

  Animation<double> get _toolbarOpacity => _toolbarController.view;

  setHandlesVisible(bool visible) {
    if (handlesVisible == visible) {
      return;
    }
    handlesVisible = visible;
    if (SchedulerBinding.instance!.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance!.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  hideHandles() {
    if (_handles == null) {
      return;
    }
    _handles![0].remove();
    _handles![1].remove();
    _handles = null;
  }

  hideToolbar() {
    assert(toolbar != null);
    _toolbarController.stop();
    toolbar!.remove();
    toolbar = null;
  }

  showToolbar() {
    assert(toolbar == null);
    toolbar = OverlayEntry(builder: _buildToolbar);
    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)!
        .insert(toolbar!);
    _toolbarController.forward(from: 0.0);
  }

  Widget _buildHandle(
      BuildContext context, _TextSelectionHandlePosition position) {
    if ((_selection.isCollapsed &&
        position == _TextSelectionHandlePosition.END)) {
      return Container();
    }
    return Visibility(
        visible: handlesVisible,
        child: _TextSelectionHandleOverlay(
          onSelectionHandleChanged: (TextSelection? newSelection) {
            _handleSelectionHandleChanged(newSelection, position);
          },
          onSelectionHandleTapped: onSelectionHandleTapped,
          startHandleLayerLink: startHandleLayerLink,
          endHandleLayerLink: endHandleLayerLink,
          renderObject: renderObject,
          selection: _selection,
          selectionControls: selectionCtrls,
          position: position,
          dragStartBehavior: dragStartBehavior,
        ));
  }

  update(TextEditingValue newValue) {
    if (value == newValue) {
      return;
    }
    value = newValue;
    if (SchedulerBinding.instance!.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance!.addPostFrameCallback(markNeedsBuild);
    } else {
      markNeedsBuild();
    }
  }

  _handleSelectionHandleChanged(
      TextSelection? newSelection, _TextSelectionHandlePosition position) {
    TextPosition textPosition;
    switch (position) {
      case _TextSelectionHandlePosition.START:
        textPosition =
            newSelection != null ? newSelection.base : TextPosition(offset: 0);
        break;
      case _TextSelectionHandlePosition.END:
        textPosition = newSelection != null
            ? newSelection.extent
            : TextPosition(offset: 0);
        break;
      default:
        throw ('Invalid position');
    }
    selectionDelegate.textEditingValue =
        value.copyWith(selection: newSelection, composing: TextRange.empty);
    selectionDelegate.bringIntoView(textPosition);
  }

  Widget _buildToolbar(BuildContext context) {
    List<TextSelectionPoint> endpoints =
        renderObject!.getEndpointsForSelection(_selection);

    Rect editingRegion = Rect.fromPoints(
      renderObject!.localToGlobal(Offset.zero),
      renderObject!.localToGlobal(renderObject!.size.bottomRight(Offset.zero)),
    );

    double baseLineHeight = renderObject!.preferredLineHeight(_selection.base);
    double extentLineHeight =
        renderObject!.preferredLineHeight(_selection.extent);
    double smallestLineHeight = math.min(baseLineHeight, extentLineHeight);
    bool isMultiline = endpoints.last.point.dy - endpoints.first.point.dy >
        smallestLineHeight / 2;

    double midX = isMultiline
        ? editingRegion.width / 2
        : (endpoints.first.point.dx + endpoints.last.point.dx) / 2;

    Offset midpoint = Offset(
      midX,
      endpoints[0].point.dy - baseLineHeight,
    );

    return FadeTransition(
      opacity: _toolbarOpacity,
      child: CompositedTransformFollower(
        link: toolbarLayerLink,
        showWhenUnlinked: false,
        offset: -editingRegion.topLeft,
        child: selectionCtrls.buildToolbar(
            context,
            editingRegion,
            baseLineHeight,
            midpoint,
            endpoints,
            selectionDelegate,
            clipboardStatus,
            Offset(0, 0)),
      ),
    );
  }

  markNeedsBuild([Duration? duration]) {
    if (_handles != null) {
      _handles![0].markNeedsBuild();
      _handles![1].markNeedsBuild();
    }
    toolbar?.markNeedsBuild();
  }

  hide() {
    if (_handles != null) {
      _handles![0].remove();
      _handles![1].remove();
      _handles = null;
    }
    if (toolbar != null) {
      hideToolbar();
    }
  }

  dispose() {
    hide();
    _toolbarController.dispose();
  }

  void showHandles() {
    assert(_handles == null);
    _handles = <OverlayEntry>[
      OverlayEntry(
          builder: (BuildContext context) =>
              _buildHandle(context, _TextSelectionHandlePosition.START)),
      OverlayEntry(
          builder: (BuildContext context) =>
              _buildHandle(context, _TextSelectionHandlePosition.END)),
    ];

    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor)!
        .insertAll(_handles!);
  }
}

class _TextSelectionHandleOverlay extends StatefulWidget {
  const _TextSelectionHandleOverlay({
    Key? key,
    required this.selection,
    required this.position,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.renderObject,
    required this.onSelectionHandleChanged,
    required this.onSelectionHandleTapped,
    required this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final TextSelection selection;
  final _TextSelectionHandlePosition position;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final RenderEditor? renderObject;
  final ValueChanged<TextSelection?> onSelectionHandleChanged;
  final VoidCallback? onSelectionHandleTapped;
  final TextSelectionControls selectionControls;
  final DragStartBehavior dragStartBehavior;

  @override
  _TextSelectionHandleOverlayState createState() =>
      _TextSelectionHandleOverlayState();

  ValueListenable<bool>? get _visibility {
    switch (position) {
      case _TextSelectionHandlePosition.START:
        return renderObject!.selectionStartInViewport;
      case _TextSelectionHandlePosition.END:
        return renderObject!.selectionEndInViewport;
    }
  }
}

class _TextSelectionHandleOverlayState
    extends State<_TextSelectionHandleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Animation<double> get _opacity => _controller.view;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this);

    _handleVisibilityChanged();
    widget._visibility!.addListener(_handleVisibilityChanged);
  }

  _handleVisibilityChanged() {
    if (widget._visibility!.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  didUpdateWidget(_TextSelectionHandleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget._visibility!.removeListener(_handleVisibilityChanged);
    _handleVisibilityChanged();
    widget._visibility!.addListener(_handleVisibilityChanged);
  }

  @override
  void dispose() {
    widget._visibility!.removeListener(_handleVisibilityChanged);
    _controller.dispose();
    super.dispose();
  }

  _handleDragStart(DragStartDetails details) {}

  _handleDragUpdate(DragUpdateDetails details) {
    TextPosition position =
        widget.renderObject!.getPositionForOffset(details.globalPosition);
    if (widget.selection.isCollapsed) {
      widget.onSelectionHandleChanged(TextSelection.fromPosition(position));
      return;
    }

    bool isNormalized =
        widget.selection.extentOffset >= widget.selection.baseOffset;
    TextSelection? newSelection;
    switch (widget.position) {
      case _TextSelectionHandlePosition.START:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? position.offset : widget.selection.baseOffset,
          extentOffset:
              isNormalized ? widget.selection.extentOffset : position.offset,
        );
        break;
      case _TextSelectionHandlePosition.END:
        newSelection = TextSelection(
          baseOffset:
              isNormalized ? widget.selection.baseOffset : position.offset,
          extentOffset:
              isNormalized ? position.offset : widget.selection.extentOffset,
        );
        break;
    }

    widget.onSelectionHandleChanged(newSelection);
  }

  _handleTap() {
    if (widget.onSelectionHandleTapped != null)
      widget.onSelectionHandleTapped!();
  }

  @override
  Widget build(BuildContext context) {
    late LayerLink layerLink;
    TextSelectionHandleType? type;

    switch (widget.position) {
      case _TextSelectionHandlePosition.START:
        layerLink = widget.startHandleLayerLink;
        type = _chooseType(
          widget.renderObject!.textDirection,
          TextSelectionHandleType.left,
          TextSelectionHandleType.right,
        );
        break;
      case _TextSelectionHandlePosition.END:
        assert(!widget.selection.isCollapsed);
        layerLink = widget.endHandleLayerLink;
        type = _chooseType(
          widget.renderObject!.textDirection,
          TextSelectionHandleType.right,
          TextSelectionHandleType.left,
        );
        break;
    }

    TextPosition textPosition =
        widget.position == _TextSelectionHandlePosition.START
            ? widget.selection.base
            : widget.selection.extent;
    double lineHeight = widget.renderObject!.preferredLineHeight(textPosition);
    Offset handleAnchor =
        widget.selectionControls.getHandleAnchor(type!, lineHeight);
    Size handleSize = widget.selectionControls.getHandleSize(lineHeight);

    Rect handleRect = Rect.fromLTWH(
      -handleAnchor.dx,
      -handleAnchor.dy,
      handleSize.width,
      handleSize.height,
    );

    Rect interactiveRect = handleRect.expandToInclude(
      Rect.fromCircle(
          center: handleRect.center, radius: kMinInteractiveDimension / 2),
    );
    RelativeRect padding = RelativeRect.fromLTRB(
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

class EditorTextSelectionGestureDetector extends StatefulWidget {
  const EditorTextSelectionGestureDetector({
    Key? key,
    this.onTapDown,
    this.onForcePressStart,
    this.onForcePressEnd,
    this.onSingleTapUp,
    this.onSingleTapCancel,
    this.onSingleLongTapStart,
    this.onSingleLongTapMoveUpdate,
    this.onSingleLongTapEnd,
    this.onDoubleTapDown,
    this.onDragSelectionStart,
    this.onDragSelectionUpdate,
    this.onDragSelectionEnd,
    this.behavior,
    required this.child,
  }) : super(key: key);

  final GestureTapDownCallback? onTapDown;

  final GestureForcePressStartCallback? onForcePressStart;

  final GestureForcePressEndCallback? onForcePressEnd;

  final GestureTapUpCallback? onSingleTapUp;

  final GestureTapCancelCallback? onSingleTapCancel;

  final GestureLongPressStartCallback? onSingleLongTapStart;

  final GestureLongPressMoveUpdateCallback? onSingleLongTapMoveUpdate;

  final GestureLongPressEndCallback? onSingleLongTapEnd;

  final GestureTapDownCallback? onDoubleTapDown;

  final GestureDragStartCallback? onDragSelectionStart;

  final DragSelectionUpdateCallback? onDragSelectionUpdate;

  final GestureDragEndCallback? onDragSelectionEnd;

  final HitTestBehavior? behavior;

  final Widget child;

  @override
  State<StatefulWidget> createState() =>
      _EditorTextSelectionGestureDetectorState();
}

class _EditorTextSelectionGestureDetectorState
    extends State<EditorTextSelectionGestureDetector> {
  Timer? _doubleTapTimer;
  Offset? _lastTapOffset;
  bool _isDoubleTap = false;

  @override
  void dispose() {
    _doubleTapTimer?.cancel();
    _dragUpdateThrottleTimer?.cancel();
    super.dispose();
  }

  _handleTapDown(TapDownDetails details) {
    if (widget.onTapDown != null) {
      widget.onTapDown!(details);
    }
    if (_doubleTapTimer != null &&
        _isWithinDoubleTapTolerance(details.globalPosition)) {
      if (widget.onDoubleTapDown != null) {
        widget.onDoubleTapDown!(details);
      }

      _doubleTapTimer!.cancel();
      _doubleTapTimeout();
      _isDoubleTap = true;
    }
  }

  _handleTapUp(TapUpDetails details) {
    if (!_isDoubleTap) {
      if (widget.onSingleTapUp != null) {
        widget.onSingleTapUp!(details);
      }
      _lastTapOffset = details.globalPosition;
      _doubleTapTimer = Timer(kDoubleTapTimeout, _doubleTapTimeout);
    }
    _isDoubleTap = false;
  }

  _handleTapCancel() {
    if (widget.onSingleTapCancel != null) {
      widget.onSingleTapCancel!();
    }
  }

  DragStartDetails? _lastDragStartDetails;
  DragUpdateDetails? _lastDragUpdateDetails;
  Timer? _dragUpdateThrottleTimer;

  _handleDragStart(DragStartDetails details) {
    assert(_lastDragStartDetails == null);
    _lastDragStartDetails = details;
    if (widget.onDragSelectionStart != null) {
      widget.onDragSelectionStart!(details);
    }
  }

  _handleDragUpdate(DragUpdateDetails details) {
    _lastDragUpdateDetails = details;
    _dragUpdateThrottleTimer ??=
        Timer(Duration(milliseconds: 50), _handleDragUpdateThrottled);
  }

  _handleDragUpdateThrottled() {
    assert(_lastDragStartDetails != null);
    assert(_lastDragUpdateDetails != null);
    if (widget.onDragSelectionUpdate != null) {
      widget.onDragSelectionUpdate!(
          _lastDragStartDetails!, _lastDragUpdateDetails!);
    }
    _dragUpdateThrottleTimer = null;
    _lastDragUpdateDetails = null;
  }

  _handleDragEnd(DragEndDetails details) {
    assert(_lastDragStartDetails != null);
    if (_dragUpdateThrottleTimer != null) {
      _dragUpdateThrottleTimer!.cancel();
      _handleDragUpdateThrottled();
    }
    if (widget.onDragSelectionEnd != null) {
      widget.onDragSelectionEnd!(details);
    }
    _dragUpdateThrottleTimer = null;
    _lastDragStartDetails = null;
    _lastDragUpdateDetails = null;
  }

  _forcePressStarted(ForcePressDetails details) {
    _doubleTapTimer?.cancel();
    _doubleTapTimer = null;
    if (widget.onForcePressStart != null) {
      widget.onForcePressStart!(details);
    }
  }

  _forcePressEnded(ForcePressDetails details) {
    if (widget.onForcePressEnd != null) {
      widget.onForcePressEnd!(details);
    }
  }

  _handleLongPressStart(LongPressStartDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapStart != null) {
      widget.onSingleLongTapStart!(details);
    }
  }

  _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapMoveUpdate != null) {
      widget.onSingleLongTapMoveUpdate!(details);
    }
  }

  _handleLongPressEnd(LongPressEndDetails details) {
    if (!_isDoubleTap && widget.onSingleLongTapEnd != null) {
      widget.onSingleLongTapEnd!(details);
    }
    _isDoubleTap = false;
  }

  void _doubleTapTimeout() {
    _doubleTapTimer = null;
    _lastTapOffset = null;
  }

  bool _isWithinDoubleTapTolerance(Offset secondTapOffset) {
    if (_lastTapOffset == null) {
      return false;
    }

    return (secondTapOffset - _lastTapOffset!).distance <= kDoubleTapSlop;
  }

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(debugOwner: this),
      (TapGestureRecognizer instance) {
        instance
          ..onTapDown = _handleTapDown
          ..onTapUp = _handleTapUp
          ..onTapCancel = _handleTapCancel;
      },
    );

    if (widget.onSingleLongTapStart != null ||
        widget.onSingleLongTapMoveUpdate != null ||
        widget.onSingleLongTapEnd != null) {
      gestures[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(
            debugOwner: this, kind: PointerDeviceKind.touch),
        (LongPressGestureRecognizer instance) {
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
      gestures[HorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(
            debugOwner: this, kind: PointerDeviceKind.mouse),
        (HorizontalDragGestureRecognizer instance) {
          instance
            ..dragStartBehavior = DragStartBehavior.down
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd;
        },
      );
    }

    if (widget.onForcePressStart != null || widget.onForcePressEnd != null) {
      gestures[ForcePressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
        () => ForcePressGestureRecognizer(debugOwner: this),
        (ForcePressGestureRecognizer instance) {
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

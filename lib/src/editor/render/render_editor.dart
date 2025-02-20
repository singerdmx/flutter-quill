import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../document/attribute.dart';
import '../../document/document.dart';
import '../widgets/box.dart';
import '../widgets/cursor.dart';
import '../widgets/painters/floating_cursor_painter.dart';
import '../widgets/text/selection/text_selection.dart';
import 'abstract_render_editor.dart';
import 'render_editable_container_box.dart';
import 'utils/quill_vertical_caret_movement.dart';
import 'utils/render_editor_utils.dart';

/// Displays a document as a vertical list of document segments (lines
/// and blocks).
///
/// Children of [RenderEditor] must be instances of [RenderEditableBox].
class RenderEditor extends RenderEditableContainerBox
    with RelayoutWhenSystemFontsChangeMixin
    implements RenderAbstractEditor {
  RenderEditor({
    required this.document,
    required super.textDirection,
    required bool hasFocus,
    required this.selection,
    required this.scrollable,
    required LayerLink startHandleLayerLink,
    required LayerLink endHandleLayerLink,
    required super.padding,
    required CursorCont cursorController,
    required this.onSelectionChanged,
    required this.onSelectionCompleted,
    required super.scrollBottomInset,
    required this.floatingCursorDisabled,
    ViewportOffset? offset,
    super.children,
    EdgeInsets floatingCursorAddedMargin =
        const EdgeInsets.fromLTRB(4, 4, 4, 5),
    double? maxContentWidth,
  })  : _hasFocus = hasFocus,
        _extendSelectionOrigin = selection,
        _startHandleLayerLink = startHandleLayerLink,
        _endHandleLayerLink = endHandleLayerLink,
        _cursorController = cursorController,
        _maxContentWidth = maxContentWidth,
        super(
          container: document.root,
        );

  final CursorCont _cursorController;
  final bool floatingCursorDisabled;
  final bool scrollable;

  Document document;
  TextSelection selection;
  bool _hasFocus = false;
  LayerLink _startHandleLayerLink;
  LayerLink _endHandleLayerLink;

  /// Called when the selection changes.
  TextSelectionChangedHandler onSelectionChanged;
  TextSelectionCompletedHandler onSelectionCompleted;
  final ValueNotifier<bool> _selectionStartInViewport =
      ValueNotifier<bool>(true);

  ValueListenable<bool> get selectionStartInViewport =>
      _selectionStartInViewport;

  ValueListenable<bool> get selectionEndInViewport => _selectionEndInViewport;
  final ValueNotifier<bool> _selectionEndInViewport = ValueNotifier<bool>(true);

  void _updateSelectionExtentsVisibility(Offset effectiveOffset) {
    final visibleRegion = Offset.zero & size;
    final startPosition =
        TextPosition(offset: selection.start, affinity: selection.affinity);
    final startOffset = _getOffsetForCaret(startPosition);
    // TODO(justinmc): https://github.com/flutter/flutter/issues/31495
    // Check if the selection is visible with an approximation because a
    // difference between rounded and unrounded values causes the caret to be
    // reported as having a slightly (< 0.5) negative y offset. This rounding
    // happens in paragraph.cc's layout and TextPainer's
    // _applyFloatingPointHack. Ideally, the rounding mismatch will be fixed and
    // this can be changed to be a strict check instead of an approximation.
    const visibleRegionSlop = 0.5;
    _selectionStartInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(startOffset + effectiveOffset);

    final endPosition =
        TextPosition(offset: selection.end, affinity: selection.affinity);
    final endOffset = _getOffsetForCaret(endPosition);
    _selectionEndInViewport.value = visibleRegion
        .inflate(visibleRegionSlop)
        .contains(endOffset + effectiveOffset);
  }

  // returns offset relative to this at which the caret will be painted
  // given a global TextPosition
  Offset _getOffsetForCaret(TextPosition position) {
    final child = childAtPosition(position);
    final childPosition = child.globalToLocalPosition(position);
    final boxParentData = child.parentData as BoxParentData;
    final localOffsetForCaret = child.getOffsetForCaret(childPosition);
    return boxParentData.offset + localOffsetForCaret;
  }

  void setDocument(Document doc) {
    if (document == doc) {
      return;
    }
    document = doc;
    markNeedsLayout();
  }

  void setHasFocus(bool h) {
    if (_hasFocus == h) {
      return;
    }
    _hasFocus = h;
    markNeedsSemanticsUpdate();
  }

  Offset get _paintOffset => Offset(0, -(offset?.pixels ?? 0.0));

  ViewportOffset? get offset => _offset;
  ViewportOffset? _offset;

  set offset(ViewportOffset? value) {
    if (_offset == value) return;
    if (attached) _offset?.removeListener(markNeedsPaint);
    _offset = value;
    if (attached) _offset?.addListener(markNeedsPaint);
    markNeedsLayout();
  }

  void setSelection(TextSelection t) {
    if (selection == t) {
      return;
    }
    selection = t;
    markNeedsPaint();

    if (!_shiftPressed && !_isDragging) {
      // Only update extend selection origin if Shift key is not pressed and
      // user is not dragging selection.
      _extendSelectionOrigin = selection;
    }
  }

  bool get _shiftPressed =>
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftLeft) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftRight);

  void setStartHandleLayerLink(LayerLink value) {
    if (_startHandleLayerLink == value) {
      return;
    }
    _startHandleLayerLink = value;
    markNeedsPaint();
  }

  void setEndHandleLayerLink(LayerLink value) {
    if (_endHandleLayerLink == value) {
      return;
    }
    _endHandleLayerLink = value;
    markNeedsPaint();
  }

  void setScrollBottomInset(double value) {
    if (scrollBottomInset == value) {
      return;
    }
    scrollBottomInset = value;
    markNeedsPaint();
  }

  double? _maxContentWidth;

  set maxContentWidth(double? value) {
    if (_maxContentWidth == value) return;
    _maxContentWidth = value;
    markNeedsLayout();
  }

  @override
  List<TextSelectionPoint> getEndpointsForSelection(
      TextSelection textSelection) {
    if (textSelection.isCollapsed) {
      final child = childAtPosition(textSelection.extent);
      final localPosition = TextPosition(
        offset: textSelection.extentOffset - child.container.offset,
        affinity: textSelection.affinity,
      );
      final localOffset = child.getOffsetForCaret(localPosition);
      final parentData = child.parentData as BoxParentData;
      return <TextSelectionPoint>[
        TextSelectionPoint(
            Offset(0, child.preferredLineHeight(localPosition)) +
                localOffset +
                parentData.offset,
            null)
      ];
    }

    final baseNode = container.queryChild(textSelection.start, false).node;

    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.container == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    final baseParentData = baseChild!.parentData as BoxParentData;
    final baseSelection =
        localSelection(baseChild.container, textSelection, true);
    var basePoint = baseChild.getBaseEndpointForSelection(baseSelection);
    basePoint = TextSelectionPoint(
      basePoint.point + baseParentData.offset,
      basePoint.direction,
    );

    final extentNode = container.queryChild(textSelection.end, false).node;
    RenderEditableBox? extentChild = baseChild;

    /// Trap shortening the text of a link which can cause selection to extend off end of line
    if (extentNode == null) {
      while (true) {
        final next = childAfter(extentChild);
        if (next == null) {
          break;
        }
      }
    } else {
      while (extentChild != null) {
        if (extentChild.container == extentNode) {
          break;
        }
        extentChild = childAfter(extentChild);
      }
    }
    assert(extentChild != null);

    final extentParentData = extentChild!.parentData as BoxParentData;
    final extentSelection =
        localSelection(extentChild.container, textSelection, true);
    var extentPoint =
        extentChild.getExtentEndpointForSelection(extentSelection);
    extentPoint = TextSelectionPoint(
      extentPoint.point + extentParentData.offset,
      extentPoint.direction,
    );

    return <TextSelectionPoint>[basePoint, extentPoint];
  }

  Offset? _lastTapDownPosition;

  // Used on Desktop (mouse and keyboard enabled platforms) as base offset
  // for extending selection, either with combination of `Shift` + Click or
  // by dragging
  TextSelection? _extendSelectionOrigin;

  @override
  void handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  bool _isDragging = false;

  void handleDragStart(DragStartDetails details) {
    _isDragging = true;

    final newSelection = selectPositionAt(
      from: details.globalPosition,
      cause: SelectionChangedCause.drag,
    );

    if (newSelection == null) return;
    // Make sure to remember the origin for extend selection.
    _extendSelectionOrigin = newSelection;
  }

  void handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    onSelectionCompleted();
  }

  @override
  void selectWordsInRange(
    Offset from,
    Offset? to,
    SelectionChangedCause cause,
  ) {
    final firstPosition = getPositionForOffset(from);
    final firstWord = selectWordAtPosition(firstPosition);
    final lastWord =
        to == null ? firstWord : selectWordAtPosition(getPositionForOffset(to));

    _handleSelectionChange(
      TextSelection(
        baseOffset: firstWord.base.offset,
        extentOffset: lastWord.extent.offset,
        affinity: firstWord.affinity,
      ),
      cause,
    );
  }

  void _handleSelectionChange(
    TextSelection nextSelection,
    SelectionChangedCause cause,
  ) {
    final focusingEmpty = nextSelection.baseOffset == 0 &&
        nextSelection.extentOffset == 0 &&
        !_hasFocus;
    if (nextSelection == selection &&
        cause != SelectionChangedCause.keyboard &&
        !focusingEmpty) {
      return;
    }
    onSelectionChanged(nextSelection, cause);
  }

  /// Extends current selection to the position closest to specified offset.
  void extendSelection(Offset to, {required SelectionChangedCause cause}) {
    /// The below logic does not exactly match the native version because
    /// we do not allow swapping of base and extent positions.
    assert(_extendSelectionOrigin != null);
    final position = getPositionForOffset(to);

    if (position.offset < _extendSelectionOrigin!.baseOffset) {
      _handleSelectionChange(
        TextSelection(
          baseOffset: position.offset,
          extentOffset: _extendSelectionOrigin!.extentOffset,
          affinity: selection.affinity,
        ),
        cause,
      );
    } else if (position.offset > _extendSelectionOrigin!.extentOffset) {
      _handleSelectionChange(
        TextSelection(
          baseOffset: _extendSelectionOrigin!.baseOffset,
          extentOffset: position.offset,
          affinity: selection.affinity,
        ),
        cause,
      );
    }
  }

  @override
  void selectWordEdge(SelectionChangedCause cause) {
    assert(_lastTapDownPosition != null);
    final position = getPositionForOffset(_lastTapDownPosition!);
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
      offset: position.offset - nodeOffset,
      affinity: position.affinity,
    );
    final localWord = child.getWordBoundary(localPosition);
    final word = TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );

    // Don't change selection if the selected word is a placeholder.
    if (child.container.style.attributes
        .containsKey(Attribute.placeholder.key)) {
      return;
    }

    if (position.offset - word.start <= 1 && word.end != position.offset) {
      _handleSelectionChange(
        TextSelection.collapsed(offset: word.start),
        cause,
      );
    } else {
      _handleSelectionChange(
        TextSelection.collapsed(
            offset: word.end, affinity: TextAffinity.upstream),
        cause,
      );
    }
  }

  @override
  TextSelection? selectPositionAt({
    required Offset from,
    required SelectionChangedCause cause,
    Offset? to,
  }) {
    final fromPosition = getPositionForOffset(from);
    final toPosition = to == null ? null : getPositionForOffset(to);

    var baseOffset = fromPosition.offset;
    var extentOffset = fromPosition.offset;
    if (toPosition != null) {
      baseOffset = math.min(fromPosition.offset, toPosition.offset);
      extentOffset = math.max(fromPosition.offset, toPosition.offset);
    }

    final newSelection = TextSelection(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
      affinity: fromPosition.affinity,
    );

    // Call [onSelectionChanged] only when the selection actually changed.
    _handleSelectionChange(newSelection, cause);
    return newSelection;
  }

  @override
  void selectWord(SelectionChangedCause cause) {
    selectWordsInRange(_lastTapDownPosition!, null, cause);
  }

  @override
  void selectPosition({required SelectionChangedCause cause}) {
    selectPositionAt(from: _lastTapDownPosition!, cause: cause);
  }

  @override
  TextSelection selectWordAtPosition(TextPosition position) {
    final word = getWordBoundary(position);
    // When long-pressing past the end of the text, we want a collapsed cursor.
    if (position.offset >= word.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: word.start, extentOffset: word.end);
  }

  @override
  TextSelection selectLineAtPosition(TextPosition position) {
    final line = getLineAtOffset(position);

    // When long-pressing past the end of the text, we want a collapsed cursor.
    if (position.offset >= line.end) {
      return TextSelection.fromPosition(position);
    }
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  @override
  void performLayout() {
    assert(() {
      if (!scrollable || !constraints.hasBoundedHeight) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('RenderEditableContainerBox must have '
            'unlimited space along its main axis when it is scrollable.'),
        ErrorDescription('RenderEditableContainerBox does not clip or'
            ' resize its children, so it must be '
            'placed in a parent that does not constrain the main '
            'axis.'),
        ErrorHint(
            'You probably want to put the RenderEditableContainerBox inside a '
            'RenderViewport with a matching main axis or disable the '
            'scrollable property.')
      ]);
    }());
    assert(() {
      if (constraints.hasBoundedWidth) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('RenderEditableContainerBox must have a bounded'
            ' constraint for its cross axis.'),
        ErrorDescription('RenderEditableContainerBox forces its children to '
            "expand to fit the RenderEditableContainerBox's container, "
            'so it must be placed in a parent that constrains the cross '
            'axis to a finite dimension.'),
      ]);
    }());

    resolvePadding();
    assert(resolvedPadding != null);

    var mainAxisExtent = resolvedPadding!.top;
    var child = firstChild;
    final innerConstraints = BoxConstraints.tightFor(
            width: math.min(
                _maxContentWidth ?? double.infinity, constraints.maxWidth))
        .deflate(resolvedPadding!);
    final leftOffset = _maxContentWidth == null
        ? 0.0
        : math.max((constraints.maxWidth - _maxContentWidth!) / 2, 0);
    while (child != null) {
      child.layout(innerConstraints, parentUsesSize: true);
      final childParentData = child.parentData as EditableContainerParentData
        ..offset = Offset(resolvedPadding!.left + leftOffset, mainAxisExtent);
      mainAxisExtent += child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    mainAxisExtent += resolvedPadding!.bottom;
    size = constraints.constrain(Size(constraints.maxWidth, mainAxisExtent));

    assert(size.isFinite);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasFocus &&
        _cursorController.show.value &&
        !_cursorController.style.paintAboveText) {
      _paintFloatingCursor(context, offset);
    }
    defaultPaint(context, offset);
    _updateSelectionExtentsVisibility(offset + _paintOffset);
    _paintHandleLayers(context, getEndpointsForSelection(selection));

    if (_hasFocus &&
        _cursorController.show.value &&
        _cursorController.style.paintAboveText) {
      _paintFloatingCursor(context, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _paintHandleLayers(
      PaintingContext context, List<TextSelectionPoint> endpoints) {
    var startPoint = endpoints[0].point;
    startPoint = Offset(
      startPoint.dx.clamp(0.0, size.width),
      startPoint.dy.clamp(0.0, size.height),
    );
    context.pushLayer(
      LeaderLayer(link: _startHandleLayerLink, offset: startPoint),
      super.paint,
      Offset.zero,
    );
    if (endpoints.length == 2) {
      var endPoint = endpoints[1].point;
      endPoint = Offset(
        endPoint.dx.clamp(0.0, size.width),
        endPoint.dy.clamp(0.0, size.height),
      );
      context.pushLayer(
        LeaderLayer(link: _endHandleLayerLink, offset: endPoint),
        super.paint,
        Offset.zero,
      );
    }
  }

  @override
  double preferredLineHeight(TextPosition position) {
    final child = childAtPosition(position);
    return child.preferredLineHeight(
        TextPosition(offset: position.offset - child.container.offset));
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    final local = globalToLocal(offset);
    final child = childAtOffset(local);

    final parentData = child.parentData as BoxParentData;
    final localOffset = local - parentData.offset;
    final localPosition = child.getPositionForOffset(localOffset);
    return TextPosition(
      offset: localPosition.offset + child.container.offset,
      affinity: localPosition.affinity,
    );
  }

  /// Returns the y-offset of the editor at which [selection] is visible.
  ///
  /// The offset is the distance from the top of the editor and is the minimum
  /// from the current scroll position until [selection] becomes visible.
  /// Returns null if [selection] is already visible.
  ///
  /// Finds the closest scroll offset that fully reveals the editing cursor.
  ///
  /// The `scrollOffset` parameter represents current scroll offset in the
  /// parent viewport.
  ///
  /// The `offsetInViewport` parameter represents the editor's vertical offset
  /// in the parent viewport. This value should normally be 0.0 if this editor
  /// is the only child of the viewport or if it's the topmost child. Otherwise
  /// it should be a positive value equal to total height of all siblings of
  /// this editor from above it.
  ///
  /// Returns `null` if the cursor is currently visible.
  double? getOffsetToRevealCursor(
      double viewportHeight, double scrollOffset, double offsetInViewport) {
    // Endpoints coordinates represents lower left or lower right corner of
    // the selection. If we want to scroll up to reveal the caret we need to
    // adjust the dy value by the height of the line. We also add a small margin
    // so that the caret is not too close to the edge of the viewport.
    final endpoints = getEndpointsForSelection(selection);

    // when we drag the right handle, we should get the last point
    TextSelectionPoint endpoint;
    if (selection.isCollapsed) {
      endpoint = endpoints.first;
    } else {
      if (selection is DragTextSelection) {
        endpoint = (selection as DragTextSelection).first
            ? endpoints.first
            : endpoints.last;
      } else {
        endpoint = endpoints.first;
      }
    }

    // Collapsed selection => caret
    final child = childAtPosition(selection.extent);
    const kMargin = 8.0;

    final caretTop = endpoint.point.dy -
        child.preferredLineHeight(TextPosition(
            offset: selection.extentOffset - child.container.documentOffset)) -
        kMargin +
        offsetInViewport +
        scrollBottomInset;
    final caretBottom =
        endpoint.point.dy + kMargin + offsetInViewport + scrollBottomInset;
    double? dy;
    if (caretTop < scrollOffset) {
      dy = caretTop;
    } else if (caretBottom > scrollOffset + viewportHeight) {
      dy = caretBottom - viewportHeight;
    }
    if (dy == null) {
      return null;
    }
    // Clamping to 0.0 so that the content does not jump unnecessarily.
    return math.max(dy, 0);
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    final targetChild = childAtPosition(position);
    final localPosition = targetChild.globalToLocalPosition(position);

    final childLocalRect = targetChild.getLocalRectForCaret(localPosition);

    final boxParentData = targetChild.parentData as BoxParentData;
    return childLocalRect.shift(Offset(0, boxParentData.offset.dy));
  }

  // Start floating cursor

  FloatingCursorPainter get _floatingCursorPainter => FloatingCursorPainter(
        floatingCursorRect: _floatingCursorRect,
        style: _cursorController.style,
      );

  bool _floatingCursorOn = false;
  Rect? _floatingCursorRect;

  TextPosition get floatingCursorTextPosition => _floatingCursorTextPosition;
  late TextPosition _floatingCursorTextPosition;

  // The relative origin in relation to the distance the user has theoretically
  // dragged the floating cursor offscreen.
  // This value is used to account for the difference
  // in the rendering position and the raw offset value.
  Offset _relativeOrigin = Offset.zero;
  Offset? _previousOffset;
  bool _resetOriginOnLeft = false;
  bool _resetOriginOnRight = false;
  bool _resetOriginOnTop = false;
  bool _resetOriginOnBottom = false;

  /// Returns the position within the editor closest to the raw cursor offset.
  Offset calculateBoundedFloatingCursorOffset(
      Offset rawCursorOffset, double preferredLineHeight) {
    var deltaPosition = Offset.zero;
    final topBound = kFloatingCursorAddedMargin.top;
    final bottomBound =
        size.height - preferredLineHeight + kFloatingCursorAddedMargin.bottom;
    final leftBound = kFloatingCursorAddedMargin.left;
    final rightBound = size.width - kFloatingCursorAddedMargin.right;

    if (_previousOffset != null) {
      deltaPosition = rawCursorOffset - _previousOffset!;
    }

    // If the raw cursor offset has gone off an edge,
    // we want to reset the relative origin of
    // the dragging when the user drags back into the field.
    if (_resetOriginOnLeft && deltaPosition.dx > 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - leftBound, _relativeOrigin.dy);
      _resetOriginOnLeft = false;
    } else if (_resetOriginOnRight && deltaPosition.dx < 0) {
      _relativeOrigin =
          Offset(rawCursorOffset.dx - rightBound, _relativeOrigin.dy);
      _resetOriginOnRight = false;
    }
    if (_resetOriginOnTop && deltaPosition.dy > 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - topBound);
      _resetOriginOnTop = false;
    } else if (_resetOriginOnBottom && deltaPosition.dy < 0) {
      _relativeOrigin =
          Offset(_relativeOrigin.dx, rawCursorOffset.dy - bottomBound);
      _resetOriginOnBottom = false;
    }

    final currentX = rawCursorOffset.dx - _relativeOrigin.dx;
    final currentY = rawCursorOffset.dy - _relativeOrigin.dy;
    final double adjustedX =
        math.min(math.max(currentX, leftBound), rightBound);
    final double adjustedY =
        math.min(math.max(currentY, topBound), bottomBound);
    final adjustedOffset = Offset(adjustedX, adjustedY);

    if (currentX < leftBound && deltaPosition.dx < 0) {
      _resetOriginOnLeft = true;
    } else if (currentX > rightBound && deltaPosition.dx > 0) {
      _resetOriginOnRight = true;
    }
    if (currentY < topBound && deltaPosition.dy < 0) {
      _resetOriginOnTop = true;
    } else if (currentY > bottomBound && deltaPosition.dy > 0) {
      _resetOriginOnBottom = true;
    }

    _previousOffset = rawCursorOffset;

    return adjustedOffset;
  }

  @override
  void setFloatingCursor(FloatingCursorDragState dragState,
      Offset boundedOffset, TextPosition textPosition,
      {double? resetLerpValue}) {
    if (floatingCursorDisabled) return;

    if (dragState == FloatingCursorDragState.Start) {
      _relativeOrigin = Offset.zero;
      _previousOffset = null;
      _resetOriginOnBottom = false;
      _resetOriginOnTop = false;
      _resetOriginOnRight = false;
      _resetOriginOnBottom = false;
    }
    _floatingCursorOn = dragState != FloatingCursorDragState.End;
    if (_floatingCursorOn) {
      _floatingCursorTextPosition = textPosition;
      final sizeAdjustment = resetLerpValue != null
          ? EdgeInsets.lerp(
              kFloatingCaretSizeIncrease, EdgeInsets.zero, resetLerpValue)!
          : kFloatingCaretSizeIncrease;
      final child = childAtPosition(textPosition);
      final caretPrototype =
          child.getCaretPrototype(child.globalToLocalPosition(textPosition));
      _floatingCursorRect =
          sizeAdjustment.inflateRect(caretPrototype).shift(boundedOffset);
      _cursorController
          .setFloatingCursorTextPosition(_floatingCursorTextPosition);
    } else {
      _floatingCursorRect = null;
      _cursorController.setFloatingCursorTextPosition(null);
    }
    markNeedsPaint();
  }

  void _paintFloatingCursor(PaintingContext context, Offset offset) {
    _floatingCursorPainter.paint(context.canvas);
  }

  // End floating cursor

  // Start TextLayoutMetrics implementation

  /// Return a [TextSelection] containing the line of the given [TextPosition].
  @override
  TextSelection getLineAtOffset(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localLineRange = child.getLineBoundary(localPosition);
    final line = TextRange(
      start: localLineRange.start + nodeOffset,
      end: localLineRange.end + nodeOffset,
    );
    return TextSelection(baseOffset: line.start, extentOffset: line.end);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final localPosition = TextPosition(
        offset: position.offset - nodeOffset, affinity: position.affinity);
    final localWord = child.getWordBoundary(localPosition);
    return TextRange(
      start: localWord.start + nodeOffset,
      end: localWord.end + nodeOffset,
    );
  }

  /// Returns the TextPosition after moving by the vertical offset.
  TextPosition getTextPositionMoveVertical(
      TextPosition position, double verticalOffset) {
    final caretOfs = localToGlobal(_getOffsetForCaret(position));
    return getPositionForOffset(caretOfs.translate(0, verticalOffset));
  }

  /// Returns the TextPosition above the given offset into the text.
  ///
  /// If the offset is already on the first line, the offset of the first
  /// character will be returned.
  @override
  TextPosition getTextPositionAbove(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition =
        TextPosition(offset: position.offset - child.container.documentOffset);

    var newPosition = child.getPositionAbove(localPosition);

    if (newPosition == null) {
      // There was no text above in the current child, check the direct
      // sibling.
      final sibling = childBefore(child);
      if (sibling == null) {
        // reached beginning of the document, move to the
        // first character
        newPosition = const TextPosition(offset: 0);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        final testPosition = TextPosition(offset: sibling.container.length - 1);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
            offset: sibling.container.documentOffset + siblingPosition.offset);
      }
    } else {
      newPosition = TextPosition(
          offset: child.container.documentOffset + newPosition.offset);
    }
    return newPosition;
  }

  /// Returns the TextPosition below the given offset into the text.
  ///
  /// If the offset is already on the last line, the offset of the last
  /// character will be returned.
  @override
  TextPosition getTextPositionBelow(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition = TextPosition(
      offset: position.offset - child.container.documentOffset,
    );

    var newPosition = child.getPositionBelow(localPosition);

    if (newPosition == null) {
      // There was no text below in the current child, check the direct sibling.
      final sibling = childAfter(child);
      if (sibling == null) {
        // reached end of the document, move to the
        // last character
        newPosition = TextPosition(offset: document.length - 1);
      } else {
        final caretOffset = child.getOffsetForCaret(localPosition);
        const testPosition = TextPosition(offset: 0);
        final testOffset = sibling.getOffsetForCaret(testPosition);
        final finalOffset = Offset(caretOffset.dx, testOffset.dy);
        final siblingPosition = sibling.getPositionForOffset(finalOffset);
        newPosition = TextPosition(
          offset: sibling.container.documentOffset + siblingPosition.offset,
        );
      }
    } else {
      newPosition = TextPosition(
        offset: child.container.documentOffset + newPosition.offset,
      );
    }
    return newPosition;
  }

  // End TextLayoutMetrics implementation
  QuillVerticalCaretMovementRun startVerticalCaretMovement(
      TextPosition startPosition) {
    return QuillVerticalCaretMovementRun(
      this,
      startPosition,
    );
  }

  @override
  void systemFontsDidChange() {
    super.systemFontsDidChange();
    markNeedsLayout();
  }
}

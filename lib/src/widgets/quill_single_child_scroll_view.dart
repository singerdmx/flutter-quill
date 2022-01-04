import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Very similar to [SingleChildView] but with a [ViewportBuilder] argument
/// instead of a [Widget]
///
/// Useful when child needs [ViewportOffset] (e.g. [RenderEditor])
/// see: [SingleChildScrollView]
class QuillSingleChildScrollView extends StatelessWidget {
  /// Creates a box in which a single widget can be scrolled.
  const QuillSingleChildScrollView({
    required this.controller,
    required this.viewportBuilder,
    Key? key,
    this.physics,
    this.restorationId,
  }) : super(key: key);

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController controller;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  final ViewportBuilder viewportBuilder;

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, Axis.vertical, false);
  }

  @override
  Widget build(BuildContext context) {
    final axisDirection = _getDirection(context);
    final scrollController = controller;
    final scrollable = Scrollable(
      axisDirection: axisDirection,
      controller: scrollController,
      physics: physics,
      restorationId: restorationId,
      viewportBuilder: (context, offset) {
        return _SingleChildViewport(
          offset: offset,
          child: viewportBuilder(context, offset),
        );
      },
    );
    return scrollable;
  }
}

class _SingleChildViewport extends SingleChildRenderObjectWidget {
  const _SingleChildViewport({
    required this.offset,
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  final ViewportOffset offset;

  @override
  _RenderSingleChildViewport createRenderObject(BuildContext context) {
    return _RenderSingleChildViewport(
      offset: offset,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderSingleChildViewport renderObject) {
    // Order dependency: The offset setter reads the axis direction.
    renderObject.offset = offset;
  }
}

class _RenderSingleChildViewport extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>
    implements RenderAbstractViewport {
  _RenderSingleChildViewport({
    required ViewportOffset offset,
    double cacheExtent = RenderAbstractViewport.defaultCacheExtent,
    RenderBox? child,
  })  : _offset = offset,
        _cacheExtent = cacheExtent {
    this.child = child;
  }

  ViewportOffset get offset => _offset;
  ViewportOffset _offset;

  set offset(ViewportOffset value) {
    if (value == _offset) return;
    if (attached) _offset.removeListener(_hasScrolled);
    _offset = value;
    if (attached) _offset.addListener(_hasScrolled);
    markNeedsLayout();
  }

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  double get cacheExtent => _cacheExtent;
  double _cacheExtent;

  set cacheExtent(double value) {
    if (value == _cacheExtent) return;
    _cacheExtent = value;
    markNeedsLayout();
  }

  void _hasScrolled() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(RenderObject child) {
    // We don't actually use the offset argument in BoxParentData, so let's
    // avoid allocating it at all.
    if (child.parentData is! ParentData) child.parentData = ParentData();
  }

  @override
  bool get isRepaintBoundary => true;

  double get _viewportExtent {
    assert(hasSize);
    return size.height;
  }

  double get _minScrollExtent {
    assert(hasSize);
    return 0;
  }

  double get _maxScrollExtent {
    assert(hasSize);
    if (child == null) return 0;
    return math.max(0, child!.size.height - size.height);
  }

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
    return constraints.widthConstraints();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) return child!.getMinIntrinsicWidth(height);
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) return child!.getMaxIntrinsicWidth(height);
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) return child!.getMinIntrinsicHeight(width);
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) return child!.getMaxIntrinsicHeight(width);
    return 0;
  }

  // We don't override computeDistanceToActualBaseline(), because we
  // want the default behavior (returning null). Otherwise, as you
  // scroll, it would shift in its parent if the parent was baseline-aligned,
  // which makes no sense.

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null) {
      return constraints.smallest;
    }
    final childSize = child!.getDryLayout(_getInnerConstraints(constraints));
    return constraints.constrain(childSize);
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (child == null) {
      size = constraints.smallest;
    } else {
      child!.layout(_getInnerConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child!.size);
    }

    offset
      ..applyViewportDimension(_viewportExtent)
      ..applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  Offset get _paintOffset => _paintOffsetForPosition(offset.pixels);

  Offset _paintOffsetForPosition(double position) {
    return Offset(0, -position);
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset) {
    assert(child != null);
    return paintOffset.dx < 0 ||
        paintOffset.dy < 0 ||
        paintOffset.dx + child!.size.width > size.width ||
        paintOffset.dy + child!.size.height > size.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final paintOffset = _paintOffset;

      void paintContents(PaintingContext context, Offset offset) {
        context.paintChild(child!, offset + paintOffset);
      }

      if (_shouldClipAtPaintOffset(paintOffset)) {
        _clipRectLayer.layer = context.pushClipRect(
          needsCompositing,
          offset,
          Offset.zero & size,
          paintContents,
          oldLayer: _clipRectLayer.layer,
        );
      } else {
        _clipRectLayer.layer = null;
        paintContents(context, offset);
      }
    }
  }

  final _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final paintOffset = _paintOffset;
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject? child) {
    if (child != null && _shouldClipAtPaintOffset(_paintOffset)) {
      return Offset.zero & size;
    }
    return null;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      return result.addWithPaintOffset(
        offset: _paintOffset,
        position: position,
        hitTest: (result, transformed) {
          assert(transformed == position + -_paintOffset);
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }

  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment,
      {Rect? rect}) {
    rect ??= target.paintBounds;
    if (target is! RenderBox) {
      return RevealedOffset(offset: offset.pixels, rect: rect);
    }

    final targetBox = target;
    final transform = targetBox.getTransformTo(child);
    final bounds = MatrixUtils.transformRect(transform, rect);

    final double leadingScrollOffset;
    final double targetMainAxisExtent;
    final double mainAxisExtent;

    mainAxisExtent = size.height;
    leadingScrollOffset = bounds.top;
    targetMainAxisExtent = bounds.height;

    final targetOffset = leadingScrollOffset -
        (mainAxisExtent - targetMainAxisExtent) * alignment;
    final targetRect = bounds.shift(_paintOffsetForPosition(targetOffset));
    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    if (!offset.allowImplicitScrolling) {
      return super.showOnScreen(
        descendant: descendant,
        rect: rect,
        duration: duration,
        curve: curve,
      );
    }

    final newRect = RenderViewportBase.showInViewport(
      descendant: descendant,
      viewport: this,
      offset: offset,
      rect: rect,
      duration: duration,
      curve: curve,
    );
    super.showOnScreen(
      rect: newRect,
      duration: duration,
      curve: curve,
    );
  }

  @override
  Rect describeSemanticsClip(RenderObject child) {
    return Rect.fromLTRB(
      semanticBounds.left,
      semanticBounds.top - cacheExtent,
      semanticBounds.right,
      semanticBounds.bottom + cacheExtent,
    );
  }
}

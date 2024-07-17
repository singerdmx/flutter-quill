import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ScribbleFocusable extends StatefulWidget {
  const ScribbleFocusable({
    required this.child,
    required this.editorKey,
    required this.renderBoxForBounds,
    required this.onScribbleFocus,
    required this.enabled,
    required this.scribbleAreaInsets,
    super.key,
  });

  final Widget child;
  final GlobalKey editorKey;
  final RenderBox? Function() renderBoxForBounds;
  final void Function(Offset offset) onScribbleFocus;
  final bool enabled;
  final EdgeInsets? scribbleAreaInsets;

  @override
  // ignore: library_private_types_in_public_api
  _ScribbleFocusableState createState() => _ScribbleFocusableState();
}

class _ScribbleFocusableState extends State<ScribbleFocusable>
    implements ScribbleClient {
  _ScribbleFocusableState()
      : _elementIdentifier = 'quill-scribble-${_nextElementIdentifier++}';

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      TextInput.registerScribbleElement(elementIdentifier, this);
    }
  }

  @override
  void didUpdateWidget(ScribbleFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      TextInput.registerScribbleElement(elementIdentifier, this);
    }

    if (oldWidget.enabled && !widget.enabled) {
      TextInput.unregisterScribbleElement(elementIdentifier);
    }
  }

  @override
  void dispose() {
    TextInput.unregisterScribbleElement(elementIdentifier);
    super.dispose();
  }

  RenderBox? get _renderBoxForEditor =>
      widget.editorKey.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? get _renderBoxForBounds {
    final box = widget.renderBoxForBounds();
    if (box == null || !mounted || !box.attached) {
      return null;
    }
    return box;
  }

  static int _nextElementIdentifier = 1;
  final String _elementIdentifier;

  @override
  String get elementIdentifier => _elementIdentifier;

  @override
  void onScribbleFocus(Offset offset) {
    widget.onScribbleFocus(offset);
  }

  @override
  bool isInScribbleRect(Rect rect) {
    final calculatedBounds = bounds;
    if (calculatedBounds == Rect.zero) {
      return false;
    }
    if (!calculatedBounds.overlaps(rect)) {
      return false;
    }
    final intersection = calculatedBounds.intersect(rect);
    final result = HitTestResult();
    WidgetsBinding.instance
        .hitTestInView(result, intersection.center, View.of(context).viewId);
    return result.path.any((entry) =>
        entry.target == _renderBoxForEditor ||
        entry.target == _renderBoxForBounds);
  }

  @override
  Rect get bounds {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !mounted || !box.attached) {
      return Rect.zero;
    }
    final transform = box.getTransformTo(null);
    final size = _renderBoxForBounds?.size ?? box.size;
    return MatrixUtils.transformRect(
        transform,
        Rect.fromLTWH(
          0 + (widget.scribbleAreaInsets?.left ?? 0),
          0 + (widget.scribbleAreaInsets?.top ?? 0),
          size.width -
              (widget.scribbleAreaInsets?.left ?? 0) -
              (widget.scribbleAreaInsets?.right ?? 0),
          size.height -
              (widget.scribbleAreaInsets?.top ?? 0) -
              (widget.scribbleAreaInsets?.bottom ?? 0),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

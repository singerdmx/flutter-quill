import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../models/documents/nodes/container.dart';
import '../others/box.dart'; // Adjust the import according to your project structure

class QABlockSeparator extends StatelessWidget {
  const QABlockSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.grey,
      thickness: 1.0,
    );
  }
}

class RenderQABlockSeparator extends RenderBox implements RenderEditableBox {
  final QuillContainer<Node?> _container;

  RenderQABlockSeparator(this._container);

  @override
  QuillContainer<Node?> get container => _container;

  @override
  double getPreferredSize(TextPosition position) {
    return 1.0;
  }

  @override
  double preferredLineHeight(TextPosition position) {
    return 1.0;
  }

  @override
  TextPosition getPositionAbove(TextPosition position) {
    return position;
  }

  @override
  TextPosition getPositionBelow(TextPosition position) {
    return position;
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    return TextRange(start: position.offset, end: position.offset);
  }

  @override
  TextRange getLineBoundary(TextPosition position) {
    return TextRange(start: position.offset, end: position.offset);
  }

  @override
  Offset getOffsetForCaret(TextPosition position) {
    return Offset.zero;
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    return Rect.zero;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    return const TextPosition(offset: 0);
  }

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final paint = Paint()..color = Colors.grey;
    context.canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, 1),
      paint,
    );
  }

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection selection) {
    return TextSelectionPoint(Offset.zero, null);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(TextSelection selection) {
    return TextSelectionPoint(Offset.zero, null);
  }

  @override
  Rect getCaretPrototype(TextPosition position) {
    return Rect.zero;
  }

  @override
  TextPosition globalToLocalPosition(TextPosition position) {
    return position;
  }
}
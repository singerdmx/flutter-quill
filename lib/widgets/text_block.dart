import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/widgets/cursor.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/text_line.dart';
import 'package:flutter_quill/widgets/text_selection.dart';
import 'package:tuple/tuple.dart';

import 'box.dart';
import 'delegate.dart';
import 'editor.dart';

class EditableTextBlock extends StatelessWidget {
  final Block block;
  final TextDirection textDirection;
  final Tuple2 verticalSpacing;
  final TextSelection textSelection;
  final Color color;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final EdgeInsets contentPadding;
  final EmbedBuilder embedBuilder;
  final CursorCont cursorCont;

  EditableTextBlock(
      this.block,
      this.textDirection,
      this.verticalSpacing,
      this.textSelection,
      this.color,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.contentPadding,
      this.embedBuilder,
      this.cursorCont)
      : assert(hasFocus != null),
        assert(embedBuilder != null),
        assert(cursorCont != null);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    DefaultStyles defaultStyles = QuillStyles.getStyles(context, false);
    return _EditableBlock(
        block,
        textDirection,
        verticalSpacing,
        _getDecorationForBlock(block, defaultStyles) ?? BoxDecoration(),
        contentPadding,
        _buildChildren(context));
  }

  BoxDecoration _getDecorationForBlock(
      Block node, DefaultStyles defaultStyles) {
    Map<String, Attribute> attrs = block.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles.quote.decoration;
    }
    if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles.code.decoration;
    }
    return null;
  }

  List<Widget> _buildChildren(BuildContext context) {
    DefaultStyles defaultStyles = QuillStyles.getStyles(context, false);
    int count = block.children.length;
    var children = <Widget>[];
    int index = 0;
    for (Line line in block.children) {
      index++;
      EditableTextLine editableTextLine = EditableTextLine(
          line,
          _buildLeading(context, line, index, count),
          TextLine(
            line: line,
            textDirection: textDirection,
            embedBuilder: embedBuilder,
          ),
          _getIndentWidth(),
          _getSpacingForLine(line, index, count, defaultStyles),
          textDirection,
          textSelection,
          color,
          enableInteractiveSelection,
          hasFocus,
          MediaQuery.of(context).devicePixelRatio,
          cursorCont);
      children.add(editableTextLine);
    }
    return children.toList(growable: false);
  }

  Widget _buildLeading(BuildContext context, Line node, int index, int count) {
    DefaultStyles defaultStyles = QuillStyles.getStyles(context, false);
    Map<String, Attribute> attrs = block.style.attributes;
    if (attrs[Attribute.list.key] == Attribute.ol) {
      return _NumberPoint(
        index: index,
        count: count,
        style: defaultStyles.paragraph.style,
        width: 32.0,
        padding: 8.0,
      );
    }

    if (attrs[Attribute.list.key] == Attribute.ul) {
      return _BulletPoint(
        style:
            defaultStyles.paragraph.style.copyWith(fontWeight: FontWeight.bold),
        width: 32,
      );
    }
    if (attrs.containsKey(Attribute.codeBlock.key)) {
      return _NumberPoint(
        index: index,
        count: count,
        style: defaultStyles.code.style
            .copyWith(color: defaultStyles.code.style.color.withOpacity(0.4)),
        width: 32.0,
        padding: 16.0,
        withDot: false,
      );
    }
    return null;
  }

  double _getIndentWidth() {
    Map<String, Attribute> attrs = block.style.attributes;

    Attribute indent = attrs[Attribute.indent.key];
    double extraIndent = 0.0;
    if (indent != null && indent.value != null) {
      extraIndent = 16.0 * indent.value;
    }

    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return 16.0 + extraIndent;
    }

    return 32.0 + extraIndent;
  }

  Tuple2 _getSpacingForLine(
      Line node, int index, int count, DefaultStyles defaultStyles) {
    double top = 0.0, bottom = 0.0;

    Map<String, Attribute> attrs = block.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      int level = attrs[Attribute.header.key].value;
      switch (level) {
        case 1:
          top = defaultStyles.h1.verticalSpacing.item1;
          bottom = defaultStyles.h1.verticalSpacing.item2;
          break;
        case 2:
          top = defaultStyles.h2.verticalSpacing.item1;
          bottom = defaultStyles.h2.verticalSpacing.item2;
          break;
        case 3:
          top = defaultStyles.h3.verticalSpacing.item1;
          bottom = defaultStyles.h3.verticalSpacing.item2;
          break;
        default:
          throw ('Invalid level $level');
      }
    } else {
      Tuple2 lineSpacing;
      if (attrs.containsKey(Attribute.blockQuote.key)) {
        lineSpacing = defaultStyles.quote.lineSpacing;
      } else if (attrs.containsKey(Attribute.list.key)) {
        lineSpacing = defaultStyles.lists.lineSpacing;
      } else if (attrs.containsKey(Attribute.codeBlock.key)) {
        lineSpacing = defaultStyles.code.lineSpacing;
      } else if (attrs.containsKey(Attribute.indent.key)) {
        lineSpacing = defaultStyles.indent.lineSpacing;
      }
      top = lineSpacing.item1;
      bottom = lineSpacing.item2;
    }

    if (index == 1) {
      top = 0.0;
    }

    if (index == count) {
      bottom = 0.0;
    }

    return Tuple2(top, bottom);
  }
}

class RenderEditableTextBlock extends RenderEditableContainerBox
    implements RenderEditableBox {
  RenderEditableTextBlock({
    List<RenderEditableBox> children,
    @required Block block,
    @required TextDirection textDirection,
    @required EdgeInsetsGeometry padding,
    @required Decoration decoration,
    ImageConfiguration configuration = ImageConfiguration.empty,
    EdgeInsets contentPadding = EdgeInsets.zero,
  })  : assert(block != null),
        assert(textDirection != null),
        assert(decoration != null),
        assert(padding != null),
        assert(contentPadding != null),
        _decoration = decoration,
        _configuration = configuration,
        _savedPadding = padding,
        _contentPadding = contentPadding,
        super(
          children,
          block,
          textDirection,
          padding.add(contentPadding),
        );

  EdgeInsetsGeometry _savedPadding;
  EdgeInsets _contentPadding;

  set contentPadding(EdgeInsets value) {
    assert(value != null);
    if (_contentPadding == value) return;
    _contentPadding = value;
    super.setPadding(_savedPadding.add(_contentPadding));
  }

  @override
  setPadding(EdgeInsetsGeometry value) {
    super.setPadding(value.add(_contentPadding));
    _savedPadding = value;
  }

  BoxPainter _painter;

  Decoration get decoration => _decoration;
  Decoration _decoration;

  set decoration(Decoration value) {
    assert(value != null);
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;

  set configuration(ImageConfiguration value) {
    assert(value != null);
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  TextRange getLineBoundary(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    TextRange rangeInChild = child.getLineBoundary(TextPosition(
      offset: position.offset - child.getContainer().getOffset(),
      affinity: position.affinity,
    ));
    return TextRange(
      start: rangeInChild.start + child.getContainer().getOffset(),
      end: rangeInChild.end + child.getContainer().getOffset(),
    );
  }

  @override
  Offset getOffsetForCaret(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    return child.getOffsetForCaret(TextPosition(
          offset: position.offset - child.getContainer().getOffset(),
          affinity: position.affinity,
        )) +
        (child.parentData as BoxParentData).offset;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    RenderEditableBox child = childAtOffset(offset);
    BoxParentData parentData = child.parentData;
    TextPosition localPosition =
        child.getPositionForOffset(offset - parentData.offset);
    return TextPosition(
      offset: localPosition.offset + child.getContainer().getOffset(),
      affinity: localPosition.affinity,
    );
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    int nodeOffset = child.getContainer().getOffset();
    TextRange childWord = child
        .getWordBoundary(TextPosition(offset: position.offset - nodeOffset));
    return TextRange(
      start: childWord.start + nodeOffset,
      end: childWord.end + nodeOffset,
    );
  }

  @override
  TextPosition getPositionAbove(TextPosition position) {
    assert(position.offset < getContainer().length);

    RenderEditableBox child = childAtPosition(position);
    TextPosition childLocalPosition = TextPosition(
        offset: position.offset - child.getContainer().getOffset());
    TextPosition result = child.getPositionAbove(childLocalPosition);
    if (result != null) {
      return TextPosition(
          offset: result.offset + child.getContainer().getOffset());
    }

    RenderEditableBox sibling = childBefore(child);
    if (sibling == null) {
      return null;
    }

    Offset caretOffset = child.getOffsetForCaret(childLocalPosition);
    TextPosition testPosition =
        TextPosition(offset: sibling.getContainer().length - 1);
    Offset testOffset = sibling.getOffsetForCaret(testPosition);
    Offset finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.getContainer().getOffset() +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  TextPosition getPositionBelow(TextPosition position) {
    assert(position.offset < getContainer().length);

    RenderEditableBox child = childAtPosition(position);
    TextPosition childLocalPosition = TextPosition(
        offset: position.offset - child.getContainer().getOffset());
    TextPosition result = child.getPositionBelow(childLocalPosition);
    if (result != null) {
      return TextPosition(
          offset: result.offset + child.getContainer().getOffset());
    }

    RenderEditableBox sibling = childAfter(child);
    if (sibling == null) {
      return null;
    }

    Offset caretOffset = child.getOffsetForCaret(childLocalPosition);
    Offset testOffset = sibling.getOffsetForCaret(TextPosition(offset: 0));
    Offset finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.getContainer().getOffset() +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    RenderEditableBox child = childAtPosition(position);
    return child.preferredLineHeight(TextPosition(
        offset: position.offset - child.getContainer().getOffset()));
  }

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0.0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    Node baseNode = getContainer().queryChild(selection.start, false).node;
    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.getContainer() == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    TextSelectionPoint basePoint = baseChild.getBaseEndpointForSelection(
        localSelection(baseChild.getContainer(), selection, true));
    return TextSelectionPoint(
        basePoint.point + (baseChild.parentData as BoxParentData).offset,
        basePoint.direction);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0.0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    Node extentNode = getContainer().queryChild(selection.end, false).node;

    var extentChild = firstChild;
    while (extentChild != null) {
      if (extentChild.getContainer() == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    TextSelectionPoint extentPoint = extentChild.getExtentEndpointForSelection(
        localSelection(extentChild.getContainer(), selection, true));
    return TextSelectionPoint(
        extentPoint.point + (extentChild.parentData as BoxParentData).offset,
        extentPoint.direction);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
    markNeedsPaint();
  }

  @override
  paint(PaintingContext context, Offset offset) {
    _paintDecoration(context, offset);
    defaultPaint(context, offset);
  }

  _paintDecoration(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);

    EdgeInsets decorationPadding = resolvedPadding - _contentPadding;

    ImageConfiguration filledConfiguration =
        configuration.copyWith(size: decorationPadding.deflateSize(size));
    int debugSaveCount = context.canvas.getSaveCount();

    final decorationOffset =
        offset.translate(decorationPadding.left, decorationPadding.top);
    _painter.paint(context.canvas, decorationOffset, filledConfiguration);
    if (debugSaveCount != context.canvas.getSaveCount()) {
      throw ('${_decoration.runtimeType} painter had mismatching save and restore calls.');
    }
    if (decoration.isComplex) {
      context.setIsComplexHint();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _EditableBlock extends MultiChildRenderObjectWidget {
  final Block block;
  final TextDirection textDirection;
  final Tuple2<double, double> padding;
  final Decoration decoration;
  final EdgeInsets contentPadding;

  _EditableBlock(this.block, this.textDirection, this.padding, this.decoration,
      this.contentPadding, List<Widget> children)
      : assert(block != null),
        assert(textDirection != null),
        assert(padding != null),
        assert(decoration != null),
        assert(children != null),
        super(children: children);

  EdgeInsets get _padding =>
      EdgeInsets.only(top: padding.item1, bottom: padding.item2);

  EdgeInsets get _contentPadding => contentPadding ?? EdgeInsets.zero;

  @override
  RenderEditableTextBlock createRenderObject(BuildContext context) {
    return RenderEditableTextBlock(
      block: block,
      textDirection: textDirection,
      padding: _padding,
      decoration: decoration,
      contentPadding: _contentPadding,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditableTextBlock renderObject) {
    renderObject.setContainer(block);
    renderObject.textDirection = textDirection;
    renderObject.setPadding(_padding);
    renderObject.decoration = decoration;
    renderObject.contentPadding = _contentPadding;
  }
}

class _NumberPoint extends StatelessWidget {
  final int index;
  final int count;
  final TextStyle style;
  final double width;
  final bool withDot;
  final double padding;

  const _NumberPoint({
    Key key,
    @required this.index,
    @required this.count,
    @required this.style,
    @required this.width,
    this.withDot = true,
    this.padding = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      child: Text(withDot ? '$index.' : '$index', style: style),
      width: width,
      padding: EdgeInsetsDirectional.only(end: padding),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final TextStyle style;
  final double width;

  const _BulletPoint({
    Key key,
    @required this.style,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      child: Text('•', style: style),
      width: width,
      padding: EdgeInsetsDirectional.only(end: 13.0),
    );
  }
}

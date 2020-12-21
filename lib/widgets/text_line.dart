import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/nodes/container.dart'
    as container;
import 'package:flutter_quill/models/documents/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/models/documents/nodes/leaf.dart';
import 'package:flutter_quill/models/documents/nodes/line.dart';
import 'package:flutter_quill/models/documents/nodes/node.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/widgets/cursor.dart';
import 'package:flutter_quill/widgets/proxy.dart';
import 'package:flutter_quill/widgets/text_selection.dart';
import 'package:tuple/tuple.dart';

import 'box.dart';
import 'default_styles.dart';
import 'delegate.dart';

class TextLine extends StatelessWidget {
  final Line line;
  final TextDirection textDirection;
  final EmbedBuilder embedBuilder;

  const TextLine({Key key, this.line, this.textDirection, this.embedBuilder})
      : assert(line != null),
        assert(embedBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    if (line.hasEmbed) {
      Embed embed = line.children.single as Embed;
      return EmbedProxy(embedBuilder(context, embed));
    }

    TextSpan textSpan = _buildTextSpan(context);
    StrutStyle strutStyle =
        StrutStyle.fromTextStyle(textSpan.style, forceStrutHeight: true);
    return RichTextProxy(
        RichText(
          text: _buildTextSpan(context),
          textDirection: textDirection,
          strutStyle: strutStyle,
          textScaleFactor: MediaQuery.textScaleFactorOf(context),
        ),
        textSpan.style,
        textDirection,
        1.0,
        Localizations.localeOf(context, nullOk: true),
        strutStyle,
        TextWidthBasis.parent,
        null);
  }

  TextSpan _buildTextSpan(BuildContext context) {
    DefaultStyles defaultStyles = DefaultStyles.getInstance(context);
    List<TextSpan> children = line.children
        .map((node) => _getTextSpanFromNode(defaultStyles, node))
        .toList(growable: false);

    TextStyle textStyle = TextStyle();

    Attribute header = line.style.attributes[Attribute.header.key];
    Map<Attribute, TextStyle> m = {
      Attribute.h1: defaultStyles.h1.style,
      Attribute.h2: defaultStyles.h2.style,
      Attribute.h3: defaultStyles.h3.style,
    };

    textStyle = textStyle.merge(m[header] ?? defaultStyles.paragraph.style);

    Attribute block = line.style.getBlockExceptHeader();
    TextStyle toMerge;
    if (block == Attribute.blockQuote) {
      toMerge = defaultStyles.quote.style;
    } else if (block == Attribute.codeBlock) {
      toMerge = defaultStyles.code.style;
    } else if (block != null) {
      toMerge = defaultStyles.lists.style;
    }

    textStyle = textStyle.merge(toMerge);

    return TextSpan(children: children, style: textStyle);
  }

  TextSpan _getTextSpanFromNode(DefaultStyles defaultStyles, Node node) {
    leaf.Text textNode = node as leaf.Text;
    Style style = textNode.style;
    TextStyle res = TextStyle();

    Map<Attribute, TextStyle> m = {
      Attribute.bold: defaultStyles.bold,
      Attribute.italic: defaultStyles.italic,
      Attribute.link: defaultStyles.link,
      Attribute.underline: defaultStyles.underline,
      Attribute.strikeThrough: defaultStyles.strikeThrough,
    };
    m.forEach((k, s) {
      if (style.values.any((v) => v == k)) {
        res = _merge(res, s);
      }
    });

    return TextSpan(text: textNode.value, style: res);
  }

  TextStyle _merge(TextStyle a, TextStyle b) {
    final decorations = <TextDecoration>[];
    if (a.decoration != null) {
      decorations.add(a.decoration);
    }
    if (b.decoration != null) {
      decorations.add(b.decoration);
    }
    return a.merge(b).apply(decoration: TextDecoration.combine(decorations));
  }
}

class EditableTextLine extends RenderObjectWidget {
  final Line line;
  final Widget leading;
  final Widget body;
  final double indentWidth;
  final Tuple2 verticalSpacing;
  final TextDirection textDirection;
  final TextSelection textSelection;
  final Color color;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final double devicePixelRatio;
  final CursorCont cursorCont;

  EditableTextLine(
      this.line,
      this.leading,
      this.body,
      this.indentWidth,
      this.verticalSpacing,
      this.textDirection,
      this.textSelection,
      this.color,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.devicePixelRatio,
      this.cursorCont)
      : assert(line != null),
        assert(indentWidth != null),
        assert(textSelection != null),
        assert(color != null),
        assert(enableInteractiveSelection != null),
        assert(hasFocus != null),
        assert(cursorCont != null);

  @override
  RenderObjectElement createElement() {
    return _TextLineElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderEditableTextLine(
        line,
        textDirection,
        textSelection,
        enableInteractiveSelection,
        hasFocus,
        devicePixelRatio,
        _getPadding(),
        cursorCont);
  }

  @override
  updateRenderObject(
      BuildContext context, covariant RenderEditableTextLine renderObject) {
    renderObject.setLine(line);
    renderObject.setPadding(_getPadding());
    renderObject.setTextDirection(textDirection);
    renderObject.setTextSelection(textSelection);
    renderObject.setColor(color);
    renderObject.setEnableInteractiveSelection(enableInteractiveSelection);
    renderObject.hasFocus = hasFocus;
    renderObject.setDevicePixelRatio(devicePixelRatio);
    renderObject.setCursorCont(cursorCont);
  }

  EdgeInsetsGeometry _getPadding() {
    return EdgeInsetsDirectional.only(
        start: indentWidth,
        top: verticalSpacing.item1,
        bottom: verticalSpacing.item2);
  }
}

enum TextLineSlot { LEADING, BODY }

class RenderEditableTextLine extends RenderEditableBox {
  RenderBox leading;
  RenderContentProxyBox body;
  Line line;
  TextDirection textDirection;
  TextSelection textSelection;
  Color color;
  bool enableInteractiveSelection;
  bool hasFocus = false;
  double devicePixelRatio;
  EdgeInsetsGeometry padding;
  CursorCont cursorCont;
  EdgeInsets _resolvedPadding;
  bool _containsCursor;
  List<TextBox> _selectedRects;
  Rect _caretPrototype;
  final Map<TextLineSlot, RenderBox> children = <TextLineSlot, RenderBox>{};

  RenderEditableTextLine(
      this.line,
      this.textDirection,
      this.textSelection,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.devicePixelRatio,
      this.padding,
      this.cursorCont)
      : assert(line != null),
        assert(padding != null),
        assert(padding.isNonNegative),
        assert(devicePixelRatio != null),
        assert(hasFocus != null),
        assert(cursorCont != null);

  Iterable<RenderBox> get _children sync* {
    if (leading != null) {
      yield leading;
    }
    if (body != null) {
      yield body;
    }
  }

  setCursorCont(CursorCont c) {
    assert(c != null);
    if (cursorCont == c) {
      return;
    }
    cursorCont = c;
    markNeedsLayout();
  }

  setDevicePixelRatio(double d) {
    if (devicePixelRatio == d) {
      return;
    }
    devicePixelRatio = d;
    markNeedsLayout();
  }

  setEnableInteractiveSelection(bool val) {
    if (enableInteractiveSelection == val) {
      return;
    }

    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  setColor(Color c) {
    if (color == c) {
      return;
    }

    color = c;
    if (containsTextSelection()) {
      markNeedsPaint();
    }
  }

  setTextSelection(TextSelection t) {
    if (textSelection == t) {
      return;
    }

    bool containsSelection = containsTextSelection();
    if (attached && containsCursor()) {
      cursorCont.removeListener(markNeedsLayout);
      cursorCont.color.removeListener(markNeedsPaint);
    }

    textSelection = t;
    _selectedRects = null;
    _containsCursor = null;
    if (attached && containsCursor()) {
      cursorCont.addListener(markNeedsLayout);
      cursorCont.color.addListener(markNeedsPaint);
    }

    if (containsSelection || containsTextSelection()) {
      markNeedsPaint();
    }
  }

  setTextDirection(TextDirection t) {
    if (textDirection == t) {
      return;
    }
    textDirection = t;
    _resolvedPadding = null;
    markNeedsLayout();
  }

  setLine(Line l) {
    assert(l != null);
    if (line == l) {
      return;
    }
    line = l;
    _containsCursor = null;
    markNeedsLayout();
  }

  setPadding(EdgeInsetsGeometry p) {
    assert(p != null);
    assert(p.isNonNegative);
    if (padding == p) {
      return;
    }
    padding = p;
    _resolvedPadding = null;
    markNeedsLayout();
  }

  setLeading(RenderBox l) {
    leading = _updateChild(leading, l, TextLineSlot.LEADING);
  }

  setBody(RenderContentProxyBox b) {
    body = _updateChild(body, b, TextLineSlot.BODY);
  }

  bool containsTextSelection() {
    return line.getDocumentOffset() <= textSelection.end &&
        textSelection.start <= line.getDocumentOffset() + line.length - 1;
  }

  bool containsCursor() {
    return _containsCursor ??= textSelection.isCollapsed &&
        line.containsOffset(textSelection.baseOffset);
  }

  RenderBox _updateChild(RenderBox old, RenderBox newChild, TextLineSlot slot) {
    if (old != null) {
      dropChild(old);
      children.remove(slot);
    }
    if (newChild != null) {
      children[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  List<TextBox> _getBoxes(TextSelection textSelection) {
    BoxParentData parentData = body.parentData as BoxParentData;
    return body.getBoxesForSelection(textSelection).map((box) {
      return TextBox.fromLTRBD(
        box.left + parentData.offset.dx,
        box.top + parentData.offset.dy,
        box.right + parentData.offset.dx,
        box.bottom + parentData.offset.dy,
        box.direction,
      );
    }).toList(growable: false);
  }

  _resolvePadding() {
    if (_resolvedPadding != null) {
      return;
    }
    _resolvedPadding = padding.resolve(textDirection);
    assert(_resolvedPadding.isNonNegative);
  }

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection textSelection) {
    return _getEndpointForSelection(textSelection, true);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(
      TextSelection textSelection) {
    return _getEndpointForSelection(textSelection, false);
  }

  TextSelectionPoint _getEndpointForSelection(
      TextSelection textSelection, bool first) {
    if (textSelection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0.0, preferredLineHeight(textSelection.extent)) +
              getOffsetForCaret(textSelection.extent),
          null);
    }
    List<TextBox> boxes = _getBoxes(textSelection);
    assert(boxes.isNotEmpty);
    TextBox targetBox = first ? boxes.first : boxes.last;
    return TextSelectionPoint(
        Offset(targetBox.start, targetBox.bottom), targetBox.direction);
  }

  @override
  TextRange getLineBoundary(TextPosition position) {
    double lineDy = getOffsetForCaret(position)
        .translate(0.0, 0.5 * preferredLineHeight(position))
        .dy;
    List<TextBox> lineBoxes =
        _getBoxes(TextSelection(baseOffset: 0, extentOffset: line.length - 1))
            .where((element) => element.top < lineDy && element.bottom > lineDy)
            .toList(growable: false);
    return TextRange(
        start:
            getPositionForOffset(Offset(lineBoxes.first.left, lineDy)).offset,
        end: getPositionForOffset(Offset(lineBoxes.last.right, lineDy)).offset);
  }

  @override
  Offset getOffsetForCaret(TextPosition position) {
    return body.getOffsetForCaret(position, _caretPrototype) +
        (body.parentData as BoxParentData).offset;
  }

  @override
  TextPosition getPositionAbove(TextPosition position) {
    return _getPosition(position, -0.5);
  }

  @override
  TextPosition getPositionBelow(TextPosition position) {
    return _getPosition(position, 1.5);
  }

  TextPosition _getPosition(TextPosition textPosition, double dyScale) {
    assert(textPosition.offset < line.length);
    Offset offset = getOffsetForCaret(textPosition)
        .translate(0, dyScale * preferredLineHeight(textPosition));
    if (body.size
        .contains(offset - (body.parentData as BoxParentData).offset)) {
      return getPositionForOffset(offset);
    }
    return null;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    return body.getPositionForOffset(
        offset - (body.parentData as BoxParentData).offset);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    return body.getWordBoundary(position);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    return body.getPreferredLineHeight();
  }

  @override
  container.Container getContainer() {
    return line;
  }

  double get cursorWidth => cursorCont.style.width;

  double get cursorHeight =>
      cursorCont.style.height ?? preferredLineHeight(TextPosition(offset: 0));

  _computeCaretPrototype() {
    assert(defaultTargetPlatform != null);
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _caretPrototype =
            Rect.fromLTWH(0.0, 0.0, cursorWidth, cursorHeight + 2);
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _caretPrototype =
            Rect.fromLTWH(0.0, 2.0, cursorWidth, cursorHeight - 4.0);
        break;
      default:
        throw ('Invalid platform');
    }
  }

  @override
  attach(covariant PipelineOwner owner) {
    super.attach(owner);
    for (final child in _children) {
      child.attach(owner);
    }
    if (containsCursor()) {
      cursorCont.addListener(markNeedsLayout);
      cursorCont.cursorColor.addListener(markNeedsPaint);
    }
  }

  @override
  detach() {
    super.detach();
    for (RenderBox child in _children) {
      child.detach();
    }
    if (containsCursor()) {
      cursorCont.removeListener(markNeedsLayout);
      cursorCont.cursorColor.removeListener(markNeedsPaint);
    }
  }

  @override
  redepthChildren() {
    _children.forEach(redepthChild);
  }

  @override
  visitChildren(RenderObjectVisitor visitor) {
    _children.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    var value = <DiagnosticsNode>[];
    void add(RenderBox child, String name) {
      if (child != null) {
        value.add(child.toDiagnosticsNode(name: name));
      }
    }

    add(leading, 'leading');
    add(body, 'body');
    return value;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    int leadingWidth = leading == null
        ? 0
        : leading.getMinIntrinsicWidth(height - verticalPadding);
    int bodyWidth = body == null
        ? 0
        : body.getMinIntrinsicWidth(math.max(0.0, height - verticalPadding));
    return horizontalPadding + leadingWidth + bodyWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    int leadingWidth = leading == null
        ? 0
        : leading.getMaxIntrinsicWidth(height - verticalPadding);
    int bodyWidth = body == null
        ? 0
        : body.getMaxIntrinsicWidth(math.max(0.0, height - verticalPadding));
    return horizontalPadding + leadingWidth + bodyWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    if (body != null) {
      return body
              .getMinIntrinsicHeight(math.max(0.0, width - horizontalPadding)) +
          verticalPadding;
    }
    return verticalPadding;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    if (body != null) {
      return body
              .getMaxIntrinsicHeight(math.max(0.0, width - horizontalPadding)) +
          verticalPadding;
    }
    return verticalPadding;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return body.getDistanceToActualBaseline(baseline) + _resolvedPadding.top;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    _selectedRects = null;

    _resolvePadding();
    assert(_resolvedPadding != null);

    if (body == null && leading == null) {
      size = constraints.constrain(Size(
        _resolvedPadding.left + _resolvedPadding.right,
        _resolvedPadding.top + _resolvedPadding.bottom,
      ));
      return;
    }
    final innerConstraints = constraints.deflate(_resolvedPadding);

    final indentWidth = textDirection == TextDirection.ltr
        ? _resolvedPadding.left
        : _resolvedPadding.right;

    body.layout(innerConstraints, parentUsesSize: true);
    final bodyParentData = body.parentData as BoxParentData;
    bodyParentData.offset = Offset(_resolvedPadding.left, _resolvedPadding.top);

    if (leading != null) {
      final leadingConstraints = innerConstraints.copyWith(
          minWidth: indentWidth,
          maxWidth: indentWidth,
          maxHeight: body.size.height);
      leading.layout(leadingConstraints, parentUsesSize: true);
      final parentData = leading.parentData as BoxParentData;
      parentData.offset = Offset(0.0, _resolvedPadding.top);
    }

    size = constraints.constrain(Size(
      _resolvedPadding.left + body.size.width + _resolvedPadding.right,
      _resolvedPadding.top + body.size.height + _resolvedPadding.bottom,
    ));

    _computeCaretPrototype();
  }

  CursorPainter get _cursorPainter => CursorPainter(
        body,
        cursorCont.style,
        _caretPrototype,
        cursorCont.cursorColor.value,
        devicePixelRatio,
      );

  @override
  paint(PaintingContext context, Offset offset) {
    if (leading != null) {
      final parentData = leading.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      context.paintChild(leading, effectiveOffset);
    }

    if (body != null) {
      final parentData = body.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      if ((enableInteractiveSelection ?? true) &&
          line.getDocumentOffset() <= textSelection.end &&
          textSelection.start <= line.getDocumentOffset() + line.length - 1) {
        final local = localSelection(line, textSelection, false);
        _selectedRects ??= body.getBoxesForSelection(
          local,
        );
        _paintSelection(context, effectiveOffset);
      }

      if (hasFocus &&
          cursorCont.show.value &&
          containsCursor() &&
          !cursorCont.style.paintAboveText) {
        _paintCursor(context, effectiveOffset);
      }

      context.paintChild(body, effectiveOffset);

      if (hasFocus &&
          cursorCont.show.value &&
          containsCursor() &&
          cursorCont.style.paintAboveText) {
        _paintCursor(context, effectiveOffset);
      }
    }
  }

  _paintSelection(PaintingContext context, Offset effectiveOffset) {
    assert(_selectedRects != null);
    final paint = Paint()..color = color;
    for (final box in _selectedRects) {
      context.canvas.drawRect(box.toRect().shift(effectiveOffset), paint);
    }
  }

  _paintCursor(PaintingContext context, Offset effectiveOffset) {
    final position = TextPosition(
      offset: textSelection.extentOffset - line.getDocumentOffset(),
      affinity: textSelection.base.affinity,
    );
    _cursorPainter.paint(context.canvas, effectiveOffset, position);
  }
}

class _TextLineElement extends RenderObjectElement {
  _TextLineElement(EditableTextLine line) : super(line);

  final Map<TextLineSlot, Element> _slotToChildren = <TextLineSlot, Element>{};

  @override
  EditableTextLine get widget => super.widget as EditableTextLine;

  @override
  RenderEditableTextLine get renderObject =>
      super.renderObject as RenderEditableTextLine;

  @override
  visitChildren(ElementVisitor visitor) {
    _slotToChildren.values.forEach(visitor);
  }

  @override
  forgetChild(Element child) {
    assert(_slotToChildren.containsValue(child));
    assert(child.slot is TextLineSlot);
    assert(_slotToChildren.containsKey(child.slot));
    _slotToChildren.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _mountChild(widget.leading, TextLineSlot.LEADING);
    _mountChild(widget.body, TextLineSlot.BODY);
  }

  @override
  update(EditableTextLine newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _updateChild(widget.leading, TextLineSlot.LEADING);
    _updateChild(widget.body, TextLineSlot.BODY);
  }

  @override
  insertRenderObjectChild(RenderObject child, TextLineSlot slot) {
    assert(child is RenderBox);
    _updateRenderObject(child, slot);
    assert(renderObject.children.keys.contains(slot));
  }

  @override
  removeRenderObjectChild(RenderObject child, TextLineSlot slot) {
    assert(child is RenderBox);
    assert(renderObject.children[slot] == child);
    _updateRenderObject(null, slot);
    assert(!renderObject.children.keys.contains(slot));
  }

  @override
  moveRenderObjectChild(RenderObject child, dynamic oldSlot, dynamic newSlot) {
    throw UnimplementedError();
  }

  _mountChild(Widget widget, TextLineSlot slot) {
    Element oldChild = _slotToChildren[slot];
    Element newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      _slotToChildren.remove(slot);
    }
    if (newChild != null) {
      _slotToChildren[slot] = newChild;
    }
  }

  _updateRenderObject(RenderObject child, TextLineSlot slot) {
    switch (slot) {
      case TextLineSlot.LEADING:
        renderObject.leading = child as RenderBox;
        break;
      case TextLineSlot.BODY:
        renderObject.body = child as RenderBox;
        break;
      default:
        throw UnimplementedError();
    }
  }

  _updateChild(Widget widget, TextLineSlot slot) {
    Element oldChild = _slotToChildren[slot];
    Element newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      _slotToChildren.remove(slot);
    }
    if (newChild != null) {
      _slotToChildren[slot] = newChild;
    }
  }
}

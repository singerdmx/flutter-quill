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
    final textAlign = _getTextAlign();
    RichText child = RichText(
      text: _buildTextSpan(context),
      textAlign: textAlign,
      textDirection: textDirection,
      strutStyle: strutStyle,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    );
    return RichTextProxy(
        child,
        textSpan.style,
        textAlign,
        textDirection,
        1.0,
        Localizations.localeOf(context, nullOk: true),
        strutStyle,
        TextWidthBasis.parent,
        null);
  }

  TextAlign _getTextAlign() {
    final alignment = line.style.attributes[Attribute.align.key];
    if (alignment == Attribute.leftAlignment) {
      return TextAlign.left;
    } else if (alignment == Attribute.centerAlignment) {
      return TextAlign.center;
    } else if (alignment == Attribute.rightAlignment) {
      return TextAlign.right;
    } else if (alignment == Attribute.justifyAlignment) {
      return TextAlign.justify;
    }
    return TextAlign.start;
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

  Color _hexStringToColor(String s) {
    switch (s) {
      case 'transparent':
        return Colors.transparent;
      case 'black':
        return Colors.black;
      case 'black12':
        return Colors.black12;
      case 'black26':
        return Colors.black26;
      case 'black38':
        return Colors.black38;
      case 'black45':
        return Colors.black45;
      case 'black54':
        return Colors.black54;
      case 'black87':
        return Colors.black87;
      case 'white':
        return Colors.white;
      case 'white10':
        return Colors.white10;
      case 'white12':
        return Colors.white12;
      case 'white24':
        return Colors.white24;
      case 'white30':
        return Colors.white30;
      case 'white38':
        return Colors.white38;
      case 'white54':
        return Colors.white54;
      case 'white60':
        return Colors.white60;
      case 'white70':
        return Colors.white70;
      case 'red':
        return Colors.red;
      case 'redAccent':
        return Colors.redAccent;
      case 'amber':
        return Colors.amber;
      case 'amberAccent':
        return Colors.amberAccent;
      case 'yellow':
        return Colors.yellow;
      case 'yellowAccent':
        return Colors.yellowAccent;
      case 'teal':
        return Colors.teal;
      case 'tealAccent':
        return Colors.tealAccent;
      case 'purple':
        return Colors.purple;
      case 'purpleAccent':
        return Colors.purpleAccent;
      case 'pink':
        return Colors.pink;
      case 'pinkAccent':
        return Colors.pinkAccent;
      case 'orange':
        return Colors.orange;
      case 'orangeAccent':
        return Colors.orangeAccent;
      case 'deepOrange':
        return Colors.deepOrange;
      case 'deepOrangeAccent':
        return Colors.deepOrangeAccent;
      case 'indigo':
        return Colors.indigo;
      case 'indigoAccent':
        return Colors.indigoAccent;
      case 'lime':
        return Colors.lime;
      case 'limeAccent':
        return Colors.limeAccent;
      case 'grey':
        return Colors.grey;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'green':
        return Colors.green;
      case 'greenAccent':
        return Colors.greenAccent;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'lightGreenAccent':
        return Colors.lightGreenAccent;
      case 'blue':
        return Colors.blue;
      case 'blueAccent':
        return Colors.blueAccent;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'lightBlueAccent':
        return Colors.lightBlueAccent;
      case 'cyan':
        return Colors.cyan;
      case 'cyanAccent':
        return Colors.cyanAccent;
      case 'brown':
        return Colors.brown;
    }

    if (s.startsWith('rgba')) {
      s = s.substring(5); // trim left 'rgba('
      s = s.substring(0, s.length - 1); // trim right ')'
      final arr = s.split(',').map((e) => e.trim()).toList();
      return Color.fromRGBO(int.parse(arr[0]), int.parse(arr[1]),
          int.parse(arr[2]), double.parse(arr[3]));
    }

    if (!s.startsWith('#')) {
      throw ("Color code not supported");
    }

    String hex = s.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return Color(val);
  }

  TextSpan _getTextSpanFromNode(DefaultStyles defaultStyles, Node node) {
    leaf.Text textNode = node as leaf.Text;
    Style style = textNode.style;
    TextStyle res = TextStyle();

    Map<String, TextStyle> m = {
      Attribute.bold.key: defaultStyles.bold,
      Attribute.italic.key: defaultStyles.italic,
      Attribute.link.key: defaultStyles.link,
      Attribute.underline.key: defaultStyles.underline,
      Attribute.strikeThrough.key: defaultStyles.strikeThrough,
    };
    m.forEach((k, s) {
      if (style.values.any((v) => v.key == k)) {
        res = _merge(res, s);
      }
    });

    Attribute color = textNode.style.attributes[Attribute.color.key];
    if (color != null && color.value != null) {
      final textColor = _hexStringToColor(color.value);
      res = res.merge(new TextStyle(color: textColor));
    }

    Attribute background = textNode.style.attributes[Attribute.background.key];
    if (background != null && background.value != null) {
      final backgroundColor = _hexStringToColor(background.value);
      res = res.merge(new TextStyle(backgroundColor: backgroundColor));
    }

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
        this.color,
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
  RenderBox _leading;
  RenderContentProxyBox _body;
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
      this.color,
      this.cursorCont)
      : assert(line != null),
        assert(padding != null),
        assert(padding.isNonNegative),
        assert(devicePixelRatio != null),
        assert(hasFocus != null),
        assert(color != null),
        assert(cursorCont != null);

  Iterable<RenderBox> get _children sync* {
    if (_leading != null) {
      yield _leading;
    }
    if (_body != null) {
      yield _body;
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
    _leading = _updateChild(_leading, l, TextLineSlot.LEADING);
  }

  setBody(RenderContentProxyBox b) {
    _body = _updateChild(_body, b, TextLineSlot.BODY);
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
    BoxParentData parentData = _body.parentData as BoxParentData;
    return _body.getBoxesForSelection(textSelection).map((box) {
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
        Offset(first ? targetBox.start : targetBox.end, targetBox.bottom),
        targetBox.direction);
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
    return _body.getOffsetForCaret(position, _caretPrototype) +
        (_body.parentData as BoxParentData).offset;
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
    if (_body.size
        .contains(offset - (_body.parentData as BoxParentData).offset)) {
      return getPositionForOffset(offset);
    }
    return null;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    return _body.getPositionForOffset(
        offset - (_body.parentData as BoxParentData).offset);
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    return _body.getWordBoundary(position);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    return _body.getPreferredLineHeight();
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

    add(_leading, 'leading');
    add(_body, 'body');
    return value;
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    int leadingWidth = _leading == null
        ? 0
        : _leading.getMinIntrinsicWidth(height - verticalPadding);
    int bodyWidth = _body == null
        ? 0
        : _body.getMinIntrinsicWidth(math.max(0.0, height - verticalPadding));
    return horizontalPadding + leadingWidth + bodyWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    int leadingWidth = _leading == null
        ? 0
        : _leading.getMaxIntrinsicWidth(height - verticalPadding);
    int bodyWidth = _body == null
        ? 0
        : _body.getMaxIntrinsicWidth(math.max(0.0, height - verticalPadding));
    return horizontalPadding + leadingWidth + bodyWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolvePadding();
    double horizontalPadding = _resolvedPadding.left + _resolvedPadding.right;
    double verticalPadding = _resolvedPadding.top + _resolvedPadding.bottom;
    if (_body != null) {
      return _body
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
    if (_body != null) {
      return _body
              .getMaxIntrinsicHeight(math.max(0.0, width - horizontalPadding)) +
          verticalPadding;
    }
    return verticalPadding;
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    _resolvePadding();
    return _body.getDistanceToActualBaseline(baseline) + _resolvedPadding.top;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    _selectedRects = null;

    _resolvePadding();
    assert(_resolvedPadding != null);

    if (_body == null && _leading == null) {
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

    _body.layout(innerConstraints, parentUsesSize: true);
    final bodyParentData = _body.parentData as BoxParentData;
    bodyParentData.offset = Offset(_resolvedPadding.left, _resolvedPadding.top);

    if (_leading != null) {
      final leadingConstraints = innerConstraints.copyWith(
          minWidth: indentWidth,
          maxWidth: indentWidth,
          maxHeight: _body.size.height);
      _leading.layout(leadingConstraints, parentUsesSize: true);
      final parentData = _leading.parentData as BoxParentData;
      parentData.offset = Offset(0.0, _resolvedPadding.top);
    }

    size = constraints.constrain(Size(
      _resolvedPadding.left + _body.size.width + _resolvedPadding.right,
      _resolvedPadding.top + _body.size.height + _resolvedPadding.bottom,
    ));

    _computeCaretPrototype();
  }

  CursorPainter get _cursorPainter => CursorPainter(
        _body,
        cursorCont.style,
        _caretPrototype,
        cursorCont.cursorColor.value,
        devicePixelRatio,
      );

  @override
  paint(PaintingContext context, Offset offset) {
    if (_leading != null) {
      final parentData = _leading.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      context.paintChild(_leading, effectiveOffset);
    }

    if (_body != null) {
      final parentData = _body.parentData as BoxParentData;
      final effectiveOffset = offset + parentData.offset;
      if ((enableInteractiveSelection ?? true) &&
          line.getDocumentOffset() <= textSelection.end &&
          textSelection.start <= line.getDocumentOffset() + line.length - 1) {
        final local = localSelection(line, textSelection, false);
        _selectedRects ??= _body.getBoxesForSelection(
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

      context.paintChild(_body, effectiveOffset);

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
        renderObject.setLeading(child as RenderBox);
        break;
      case TextLineSlot.BODY:
        renderObject.setBody(child as RenderBox);
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

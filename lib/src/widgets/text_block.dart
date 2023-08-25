import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/documents/attribute.dart';
import '../models/documents/nodes/block.dart';
import '../models/documents/nodes/line.dart';
import '../models/structs/vertical_spacing.dart';
import '../utils/delta.dart';
import 'box.dart';
import 'controller.dart';
import 'cursor.dart';
import 'default_styles.dart';
import 'delegate.dart';
import 'editor.dart';
import 'link.dart';
import 'style_widgets/bullet_point.dart';
import 'style_widgets/checkbox_point.dart';
import 'style_widgets/number_point.dart';
import 'text_line.dart';
import 'text_selection.dart';

const List<int> arabianRomanNumbers = [
  1000,
  900,
  500,
  400,
  100,
  90,
  50,
  40,
  10,
  9,
  5,
  4,
  1
];

const List<String> romanNumbers = [
  'M',
  'CM',
  'D',
  'CD',
  'C',
  'XC',
  'L',
  'XL',
  'X',
  'IX',
  'V',
  'IV',
  'I'
];

class EditableTextBlock extends StatelessWidget {
  const EditableTextBlock(
      {required this.block,
      required this.controller,
      required this.textDirection,
      required this.scrollBottomInset,
      required this.verticalSpacing,
      required this.textSelection,
      required this.color,
      required this.styles,
      required this.enableInteractiveSelection,
      required this.hasFocus,
      required this.contentPadding,
      required this.embedBuilder,
      required this.linkActionPicker,
      required this.cursorCont,
      required this.indentLevelCounts,
      required this.clearIndents,
      required this.onCheckboxTap,
      required this.readOnly,
      this.onLaunchUrl,
      this.customStyleBuilder,
      this.customLinkPrefixes = const <String>[],
      Key? key});

  final Block block;
  final QuillController controller;
  final TextDirection textDirection;
  final double scrollBottomInset;
  final VerticalSpacing verticalSpacing;
  final TextSelection textSelection;
  final Color color;
  final DefaultStyles? styles;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final EdgeInsets? contentPadding;
  final EmbedsBuilder embedBuilder;
  final LinkActionPicker linkActionPicker;
  final ValueChanged<String>? onLaunchUrl;
  final CustomStyleBuilder? customStyleBuilder;
  final CursorCont cursorCont;
  final Map<int, int> indentLevelCounts;
  final bool clearIndents;
  final Function(int, bool) onCheckboxTap;
  final bool readOnly;
  final List<String> customLinkPrefixes;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final defaultStyles = QuillStyles.getStyles(context, false);
    return _EditableBlock(
        block: block,
        textDirection: textDirection,
        padding: verticalSpacing,
        scrollBottomInset: scrollBottomInset,
        decoration: _getDecorationForBlock(block, defaultStyles) ??
            const BoxDecoration(),
        contentPadding: contentPadding,
        children: _buildChildren(context, indentLevelCounts, clearIndents));
  }

  BoxDecoration? _getDecorationForBlock(
      Block node, DefaultStyles? defaultStyles) {
    final attrs = block.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return defaultStyles!.quote!.decoration;
    }
    if (attrs.containsKey(Attribute.codeBlock.key)) {
      return defaultStyles!.code!.decoration;
    }
    return null;
  }

  List<Widget> _buildChildren(BuildContext context,
      Map<int, int> indentLevelCounts, bool clearIndents) {
    final defaultStyles = QuillStyles.getStyles(context, false);
    final count = block.children.length;
    final children = <Widget>[];
    if (clearIndents) {
      indentLevelCounts.clear();
    }
    var index = 0;
    for (final line in Iterable.castFrom<dynamic, Line>(block.children)) {
      index++;
      final editableTextLine = EditableTextLine(
          line,
          _buildLeading(context, line, index, indentLevelCounts, count),
          TextLine(
            line: line,
            textDirection: textDirection,
            embedBuilder: embedBuilder,
            customStyleBuilder: customStyleBuilder,
            styles: styles!,
            readOnly: readOnly,
            controller: controller,
            linkActionPicker: linkActionPicker,
            onLaunchUrl: onLaunchUrl,
            customLinkPrefixes: customLinkPrefixes,
          ),
          _getIndentWidth(context, count),
          _getSpacingForLine(line, index, count, defaultStyles),
          textDirection,
          textSelection,
          color,
          enableInteractiveSelection,
          hasFocus,
          MediaQuery.of(context).devicePixelRatio,
          cursorCont);
      final nodeTextDirection = getDirectionOfNode(line);
      children.add(Directionality(
          textDirection: nodeTextDirection, child: editableTextLine));
    }
    return children.toList(growable: false);
  }

  double _numberPointWidth(double fontSize, int count) {
    final length = '$count'.length;
    switch (length) {
      case 1:
      case 2:
        return fontSize * 2;
      default:
        // 3 -> 2.5
        // 4 -> 3
        // 5 -> 3.5
        return fontSize * (length - (length - 2) / 2);
    }
  }

  Widget? _buildLeading(BuildContext context, Line line, int index,
      Map<int, int> indentLevelCounts, int count) {
    final defaultStyles = QuillStyles.getStyles(context, false)!;
    final fontSize = defaultStyles.paragraph?.style.fontSize ?? 16;
    final attrs = line.style.attributes;

    if (attrs[Attribute.list.key] == Attribute.ol) {
      return QuillNumberPoint(
        index: index,
        indentLevelCounts: indentLevelCounts,
        count: count,
        style: defaultStyles.leading!.style,
        attrs: attrs,
        width: _numberPointWidth(fontSize, count),
        padding: fontSize / 2,
      );
    }

    if (attrs[Attribute.list.key] == Attribute.ul) {
      return QuillBulletPoint(
        style:
            defaultStyles.leading!.style.copyWith(fontWeight: FontWeight.bold),
        width: fontSize * 2,
        padding: fontSize / 2,
      );
    }

    if (attrs[Attribute.list.key] == Attribute.checked) {
      return CheckboxPoint(
        size: fontSize,
        value: true,
        enabled: !readOnly,
        onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
        uiBuilder: defaultStyles.lists?.checkboxUIBuilder,
      );
    }

    if (attrs[Attribute.list.key] == Attribute.unchecked) {
      return CheckboxPoint(
        size: fontSize,
        value: false,
        enabled: !readOnly,
        onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
        uiBuilder: defaultStyles.lists?.checkboxUIBuilder,
      );
    }

    if (attrs.containsKey(Attribute.codeBlock.key)) {
      return QuillNumberPoint(
        index: index,
        indentLevelCounts: indentLevelCounts,
        count: count,
        style: defaultStyles.code!.style
            .copyWith(color: defaultStyles.code!.style.color!.withOpacity(0.4)),
        width: _numberPointWidth(fontSize, count),
        attrs: attrs,
        padding: fontSize,
        withDot: false,
      );
    }
    return null;
  }

  double _getIndentWidth(BuildContext context, int count) {
    final defaultStyles = QuillStyles.getStyles(context, false)!;
    final fontSize = defaultStyles.paragraph?.style.fontSize ?? 16;
    final attrs = block.style.attributes;

    final indent = attrs[Attribute.indent.key];
    var extraIndent = 0.0;
    if (indent != null && indent.value != null) {
      extraIndent = fontSize * indent.value;
    }

    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return fontSize + extraIndent;
    }

    var baseIndent = 0.0;

    if (attrs.containsKey(Attribute.list.key)) {
      baseIndent = fontSize * 2;
      if (attrs[Attribute.list.key] == Attribute.ol) {
        baseIndent = _numberPointWidth(fontSize, count);
      } else if (attrs.containsKey(Attribute.codeBlock.key)) {
        baseIndent = _numberPointWidth(fontSize, count);
      }
    }

    return baseIndent + extraIndent;
  }

  VerticalSpacing _getSpacingForLine(
      Line node, int index, int count, DefaultStyles? defaultStyles) {
    var top = 0.0, bottom = 0.0;

    final attrs = block.style.attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      final level = attrs[Attribute.header.key]!.value;
      switch (level) {
        case 1:
          top = defaultStyles!.h1!.verticalSpacing.top;
          bottom = defaultStyles.h1!.verticalSpacing.bottom;
          break;
        case 2:
          top = defaultStyles!.h2!.verticalSpacing.top;
          bottom = defaultStyles.h2!.verticalSpacing.bottom;
          break;
        case 3:
          top = defaultStyles!.h3!.verticalSpacing.top;
          bottom = defaultStyles.h3!.verticalSpacing.bottom;
          break;
        default:
          throw 'Invalid level $level';
      }
    } else {
      late VerticalSpacing lineSpacing;
      if (attrs.containsKey(Attribute.blockQuote.key)) {
        lineSpacing = defaultStyles!.quote!.lineSpacing;
      } else if (attrs.containsKey(Attribute.indent.key)) {
        lineSpacing = defaultStyles!.indent!.lineSpacing;
      } else if (attrs.containsKey(Attribute.list.key)) {
        lineSpacing = defaultStyles!.lists!.lineSpacing;
      } else if (attrs.containsKey(Attribute.codeBlock.key)) {
        lineSpacing = defaultStyles!.code!.lineSpacing;
      } else if (attrs.containsKey(Attribute.align.key)) {
        lineSpacing = defaultStyles!.align!.lineSpacing;
      } else {
        // use paragraph linespacing as a default
        lineSpacing = defaultStyles!.paragraph!.lineSpacing;
      }
      top = lineSpacing.top;
      bottom = lineSpacing.bottom;
    }

    if (index == 1) {
      top = 0.0;
    }

    if (index == count) {
      bottom = 0.0;
    }

    return VerticalSpacing(top, bottom);
  }
}

class RenderEditableTextBlock extends RenderEditableContainerBox
    implements RenderEditableBox {
  RenderEditableTextBlock({
    required Block block,
    required TextDirection textDirection,
    required EdgeInsetsGeometry padding,
    required double scrollBottomInset,
    required Decoration decoration,
    List<RenderEditableBox>? children,
    EdgeInsets contentPadding = EdgeInsets.zero,
  })  : _decoration = decoration,
        _configuration = ImageConfiguration(textDirection: textDirection),
        _savedPadding = padding,
        _contentPadding = contentPadding,
        super(
          children: children,
          container: block,
          textDirection: textDirection,
          scrollBottomInset: scrollBottomInset,
          padding: padding.add(contentPadding),
        );

  EdgeInsetsGeometry _savedPadding;
  EdgeInsets _contentPadding;

  set contentPadding(EdgeInsets value) {
    if (_contentPadding == value) return;
    _contentPadding = value;
    super.setPadding(_savedPadding.add(_contentPadding));
  }

  @override
  void setPadding(EdgeInsetsGeometry value) {
    super.setPadding(value.add(_contentPadding));
    _savedPadding = value;
  }

  BoxPainter? _painter;

  Decoration get decoration => _decoration;
  Decoration _decoration;

  set decoration(Decoration value) {
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;

  set configuration(ImageConfiguration value) {
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  TextRange getLineBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final rangeInChild = child.getLineBoundary(TextPosition(
      offset: position.offset - child.container.offset,
      affinity: position.affinity,
    ));
    return TextRange(
      start: rangeInChild.start + child.container.offset,
      end: rangeInChild.end + child.container.offset,
    );
  }

  @override
  Offset getOffsetForCaret(TextPosition position) {
    final child = childAtPosition(position);
    return child.getOffsetForCaret(TextPosition(
          offset: position.offset - child.container.offset,
          affinity: position.affinity,
        )) +
        (child.parentData as BoxParentData).offset;
  }

  @override
  TextPosition getPositionForOffset(Offset offset) {
    final child = childAtOffset(offset);
    final parentData = child.parentData as BoxParentData;
    final localPosition =
        child.getPositionForOffset(offset - parentData.offset);
    return TextPosition(
      offset: localPosition.offset + child.container.offset,
      affinity: localPosition.affinity,
    );
  }

  @override
  TextRange getWordBoundary(TextPosition position) {
    final child = childAtPosition(position);
    final nodeOffset = child.container.offset;
    final childWord = child
        .getWordBoundary(TextPosition(offset: position.offset - nodeOffset));
    return TextRange(
      start: childWord.start + nodeOffset,
      end: childWord.end + nodeOffset,
    );
  }

  @override
  TextPosition? getPositionAbove(TextPosition position) {
    assert(position.offset < container.length);

    final child = childAtPosition(position);
    final childLocalPosition =
        TextPosition(offset: position.offset - child.container.offset);
    final result = child.getPositionAbove(childLocalPosition);
    if (result != null) {
      return TextPosition(offset: result.offset + child.container.offset);
    }

    final sibling = childBefore(child);
    if (sibling == null) {
      return null;
    }

    final caretOffset = child.getOffsetForCaret(childLocalPosition);
    final testPosition = TextPosition(offset: sibling.container.length - 1);
    final testOffset = sibling.getOffsetForCaret(testPosition);
    final finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.container.offset +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  TextPosition? getPositionBelow(TextPosition position) {
    assert(position.offset < container.length);

    final child = childAtPosition(position);
    final childLocalPosition =
        TextPosition(offset: position.offset - child.container.offset);
    final result = child.getPositionBelow(childLocalPosition);
    if (result != null) {
      return TextPosition(offset: result.offset + child.container.offset);
    }

    final sibling = childAfter(child);
    if (sibling == null) {
      return null;
    }

    final caretOffset = child.getOffsetForCaret(childLocalPosition);
    final testOffset = sibling.getOffsetForCaret(const TextPosition(offset: 0));
    final finalOffset = Offset(caretOffset.dx, testOffset.dy);
    return TextPosition(
        offset: sibling.container.offset +
            sibling.getPositionForOffset(finalOffset).offset);
  }

  @override
  double preferredLineHeight(TextPosition position) {
    final child = childAtPosition(position);
    return child.preferredLineHeight(
        TextPosition(offset: position.offset - child.container.offset));
  }

  @override
  TextSelectionPoint getBaseEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    final baseNode = container.queryChild(selection.start, false).node;
    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.container == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    final basePoint = baseChild!.getBaseEndpointForSelection(
        localSelection(baseChild.container, selection, true));
    return TextSelectionPoint(
        basePoint.point + (baseChild.parentData as BoxParentData).offset,
        basePoint.direction);
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
          Offset(0, preferredLineHeight(selection.extent)) +
              getOffsetForCaret(selection.extent),
          null);
    }

    final extentNode = container.queryChild(selection.end, false).node;

    var extentChild = firstChild;
    while (extentChild != null) {
      if (extentChild.container == extentNode) {
        break;
      }
      extentChild = childAfter(extentChild);
    }
    assert(extentChild != null);

    final extentPoint = extentChild!.getExtentEndpointForSelection(
        localSelection(extentChild.container, selection, true));
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
  void paint(PaintingContext context, Offset offset) {
    _paintDecoration(context, offset);
    defaultPaint(context, offset);
  }

  void _paintDecoration(PaintingContext context, Offset offset) {
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);

    final decorationPadding = resolvedPadding! - _contentPadding;

    final filledConfiguration =
        configuration.copyWith(size: decorationPadding.deflateSize(size));
    final debugSaveCount = context.canvas.getSaveCount();

    final decorationOffset =
        offset.translate(decorationPadding.left, decorationPadding.top);
    _painter!.paint(context.canvas, decorationOffset, filledConfiguration);
    if (debugSaveCount != context.canvas.getSaveCount()) {
      throw '${_decoration.runtimeType} painter had mismatching save and  '
          'restore calls.';
    }
    if (decoration.isComplex) {
      context.setIsComplexHint();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  Rect getLocalRectForCaret(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition = TextPosition(
      offset: position.offset - child.container.offset,
      affinity: position.affinity,
    );
    final parentData = child.parentData as BoxParentData;
    return child.getLocalRectForCaret(localPosition).shift(parentData.offset);
  }

  @override
  TextPosition globalToLocalPosition(TextPosition position) {
    assert(container.containsOffset(position.offset),
        'The provided text position is not in the current node');
    return TextPosition(
      offset: position.offset - container.documentOffset,
      affinity: position.affinity,
    );
  }

  @override
  Rect getCaretPrototype(TextPosition position) {
    final child = childAtPosition(position);
    final localPosition = TextPosition(
      offset: position.offset - child.container.offset,
      affinity: position.affinity,
    );
    return child.getCaretPrototype(localPosition);
  }
}

class _EditableBlock extends MultiChildRenderObjectWidget {
  const _EditableBlock(
      {required this.block,
      required this.textDirection,
      required this.padding,
      required this.scrollBottomInset,
      required this.decoration,
      required this.contentPadding,
      required List<Widget> children,
      Key? key})
      : super(key: key, children: children);

  final Block block;
  final TextDirection textDirection;
  final VerticalSpacing padding;
  final double scrollBottomInset;
  final Decoration decoration;
  final EdgeInsets? contentPadding;

  EdgeInsets get _padding =>
      EdgeInsets.only(top: padding.top, bottom: padding.bottom);

  EdgeInsets get _contentPadding => contentPadding ?? EdgeInsets.zero;

  @override
  RenderEditableTextBlock createRenderObject(BuildContext context) {
    return RenderEditableTextBlock(
      block: block,
      textDirection: textDirection,
      padding: _padding,
      scrollBottomInset: scrollBottomInset,
      decoration: decoration,
      contentPadding: _contentPadding,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderEditableTextBlock renderObject) {
    renderObject
      ..setContainer(block)
      ..textDirection = textDirection
      ..scrollBottomInset = scrollBottomInset
      ..setPadding(_padding)
      ..decoration = decoration
      ..contentPadding = _contentPadding;
  }
}

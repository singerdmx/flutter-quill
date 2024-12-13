import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../common/structs/horizontal_spacing.dart';
import '../../../common/structs/vertical_spacing.dart';
import '../../../common/utils/font.dart';
import '../../../controller/quill_controller.dart';
import '../../../delta/delta_diff.dart';
import '../../../document/attribute.dart';
import '../../../document/nodes/block.dart';
import '../../../document/nodes/line.dart';
import '../../../editor_toolbar_shared/color.dart';
import '../../editor.dart';
import '../../embed/embed_editor_builder.dart';
import '../../raw_editor/builders/leading_block_builder.dart';
import '../box.dart';
import '../cursor.dart';
import '../default_leading_components/leading_components.dart';
import '../default_styles.dart';
import '../delegate.dart';
import '../link.dart';
import 'text_line.dart';
import 'text_selection.dart';
import 'utils/text_block_utils.dart';

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
  const EditableTextBlock({
    required this.block,
    required this.controller,
    required this.textDirection,
    required this.scrollBottomInset,
    required this.horizontalSpacing,
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
    required this.customRecognizerBuilder,
    required this.composingRange,
    this.checkBoxReadOnly,
    this.onLaunchUrl,
    this.customStyleBuilder,
    this.customLinkPrefixes = const <String>[],
    this.customLeadingBlockBuilder,
    super.key,
  });

  final Block block;
  final QuillController controller;
  final TextDirection textDirection;
  final double scrollBottomInset;
  final HorizontalSpacing horizontalSpacing;
  final VerticalSpacing verticalSpacing;
  final TextSelection textSelection;
  final Color color;
  final DefaultStyles? styles;
  final LeadingBlockNodeBuilder? customLeadingBlockBuilder;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final EdgeInsets? contentPadding;
  final EmbedsBuilder embedBuilder;
  final LinkActionPicker linkActionPicker;
  final ValueChanged<String>? onLaunchUrl;
  final CustomRecognizerBuilder? customRecognizerBuilder;
  final CustomStyleBuilder? customStyleBuilder;
  final CursorCont cursorCont;
  final Map<int, int> indentLevelCounts;
  final bool clearIndents;
  final Function(int, bool) onCheckboxTap;
  final bool readOnly;
  final bool? checkBoxReadOnly;
  final List<String> customLinkPrefixes;
  final TextRange composingRange;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final defaultStyles = QuillStyles.getStyles(context, false);
    return _EditableBlock(
      block: block,
      textDirection: textDirection,
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing,
      scrollBottomInset: scrollBottomInset,
      decoration:
          _getDecorationForBlock(block, defaultStyles) ?? const BoxDecoration(),
      contentPadding: contentPadding,
      children: _buildChildren(
        context,
        indentLevelCounts,
        clearIndents,
      ),
    );
  }

  BoxDecoration? _getDecorationForBlock(
      Block node, DefaultStyles? defaultStyles) {
    final attrs = block.style.attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      // Verify if the direction is RTL and avoid passing the decoration
      // to the left when need to be on right side
      if (textDirection == TextDirection.rtl) {
        return defaultStyles!.quote!.decoration?.copyWith(
          border: Border(
            right: BorderSide(width: 4, color: Colors.grey.shade300),
          ),
        );
      }
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
    final numberPointWidthBuilder =
        defaultStyles?.lists?.numberPointWidthBuilder ??
            TextBlockUtils.defaultNumberPointWidthBuilder;
    final indentWidthBuilder = defaultStyles?.lists?.indentWidthBuilder ??
        TextBlockUtils.defaultIndentWidthBuilder;

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
        _buildLeading(
          context: context,
          line: line,
          index: index,
          indentLevelCounts: indentLevelCounts,
          count: count,
        ),
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
          customRecognizerBuilder: customRecognizerBuilder,
          composingRange: composingRange,
        ),
        indentWidthBuilder(block, context, count, numberPointWidthBuilder),
        _getSpacingForLine(line, index, count, defaultStyles),
        textDirection,
        textSelection,
        color,
        enableInteractiveSelection,
        hasFocus,
        MediaQuery.devicePixelRatioOf(context),
        cursorCont,
        styles!.inlineCode!,
      );
      final nodeTextDirection = getDirectionOfNode(line, textDirection);
      children.add(
        Directionality(
          textDirection: nodeTextDirection,
          child: editableTextLine,
        ),
      );
    }
    return children.toList(growable: false);
  }

  Widget? _buildLeading({
    required BuildContext context,
    required Line line,
    required int index,
    required Map<int, int> indentLevelCounts,
    required int count,
  }) {
    final defaultStyles = QuillStyles.getStyles(context, false)!;
    final fontSize = defaultStyles.paragraph?.style.fontSize ?? 16;
    final attrs = line.style.attributes;
    final numberPointWidthBuilder =
        defaultStyles.lists?.numberPointWidthBuilder ??
            TextBlockUtils.defaultNumberPointWidthBuilder;

    // Of the color button
    final fontColor =
        line.toDelta().operations.first.attributes?[Attribute.color.key] != null
            ? hexToColor(
                line
                    .toDelta()
                    .operations
                    .first
                    .attributes?[Attribute.color.key],
              )
            : null;

    // Of the size button
    final size =
        line.toDelta().operations.first.attributes?[Attribute.size.key] != null
            ? getFontSizeAsDouble(
                line.toDelta().operations.first.attributes?[Attribute.size.key],
                defaultStyles: defaultStyles,
              )
            : null;

    // Of the alignment buttons
    // final textAlign = line.style.attributes[Attribute.align.key]?.value != null
    //     ? getTextAlign(line.style.attributes[Attribute.align.key]?.value)
    //     : null;
    final attribute =
        attrs[Attribute.list.key] ?? attrs[Attribute.codeBlock.key];
    final isUnordered = attribute == Attribute.ul;
    final isOrdered = attribute == Attribute.ol;
    final isCheck =
        attribute == Attribute.checked || attribute == Attribute.unchecked;
    final isCodeBlock = attrs.containsKey(Attribute.codeBlock.key);
    if (attribute == null) return null;
    final leadingConfig = LeadingConfig(
      attribute: attribute,
      attrs: attrs,
      indentLevelCounts: indentLevelCounts,
      index: isOrdered || isCodeBlock ? index : null,
      count: count,
      enabled: !isCheck ? null : !(checkBoxReadOnly ?? readOnly),
      style: () {
        if (isOrdered) {
          return defaultStyles.leading!.style.copyWith(
            fontSize: size,
            color: fontColor,
          );
        }
        if (isUnordered) {
          return defaultStyles.leading!.style.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: size,
            color: fontColor,
          );
        }
        if (isCheck) {
          return null;
        }
        return defaultStyles.code!.style.copyWith(
          color: defaultStyles.code!.style.color!.withValues(alpha: 0.4),
        );
      }(),
      width: () {
        if (isOrdered || isCodeBlock) {
          return numberPointWidthBuilder(fontSize, count);
        }
        if (isUnordered) {
          return numberPointWidthBuilder(fontSize, 1); // same as fontSize * 2
        }
        return null;
      }(),
      padding: () {
        if (isOrdered || isUnordered) {
          return fontSize / 2;
        }
        if (isCodeBlock) {
          return fontSize;
        }
        return null;
      }(),
      lineSize: isCheck ? fontSize : null,
      uiBuilder: isCheck ? defaultStyles.lists?.checkboxUIBuilder : null,
      value: attribute == Attribute.checked,
      onCheckboxTap: !isCheck
          ? (value) {}
          : (value) => onCheckboxTap(line.documentOffset, value),
    );
    if (customLeadingBlockBuilder != null) {
      final leadingBlockNodeBuilder = customLeadingBlockBuilder?.call(
        line,
        leadingConfig,
      );
      if (leadingBlockNodeBuilder != null) {
        return leadingBlockNodeBuilder;
      }
    }

    if (isOrdered) {
      return numberPointLeading(leadingConfig);
    }

    if (isUnordered) {
      return bulletPointLeading(leadingConfig);
    }

    if (isCheck) {
      return checkboxLeading(leadingConfig);
    }
    if (isCodeBlock) {
      return codeBlockLineNumberLeading(leadingConfig);
    }
    return null;
  }

  VerticalSpacing _getSpacingForLine(
    Line node,
    int index,
    int count,
    DefaultStyles? defaultStyles,
  ) {
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
        case 4:
          top = defaultStyles!.h4!.verticalSpacing.top;
          bottom = defaultStyles.h4!.verticalSpacing.bottom;
          break;
        case 5:
          top = defaultStyles!.h5!.verticalSpacing.top;
          bottom = defaultStyles.h5!.verticalSpacing.bottom;
          break;
        case 6:
          top = defaultStyles!.h6!.verticalSpacing.top;
          bottom = defaultStyles.h6!.verticalSpacing.bottom;
          break;
        default:
          throw ArgumentError('Invalid level $level');
      }
    } else {
      final VerticalSpacing lineSpacing;
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
    required super.textDirection,
    required EdgeInsetsGeometry padding,
    required super.scrollBottomInset,
    required Decoration decoration,
    super.children,
    EdgeInsets contentPadding = EdgeInsets.zero,
  })  : _decoration = decoration,
        _configuration = ImageConfiguration(textDirection: textDirection),
        _savedPadding = padding,
        _contentPadding = contentPadding,
        super(
          container: block,
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
        null,
      );
    }

    final baseNode = container
        .queryChild(
          selection.start,
          false,
        )
        .node;
    var baseChild = firstChild;
    while (baseChild != null) {
      if (baseChild.container == baseNode) {
        break;
      }
      baseChild = childAfter(baseChild);
    }
    assert(baseChild != null);

    final basePoint = baseChild!.getBaseEndpointForSelection(
      localSelection(
        baseChild.container,
        selection,
        true,
      ),
    );
    return TextSelectionPoint(
      basePoint.point + (baseChild.parentData as BoxParentData).offset,
      basePoint.direction,
    );
  }

  @override
  TextSelectionPoint getExtentEndpointForSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return TextSelectionPoint(
        Offset(0, preferredLineHeight(selection.extent)) +
            getOffsetForCaret(selection.extent),
        null,
      );
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
      localSelection(
        extentChild.container,
        selection,
        true,
      ),
    );
    return TextSelectionPoint(
      extentPoint.point + (extentChild.parentData as BoxParentData).offset,
      extentPoint.direction,
    );
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
      throw StateError(
        '${_decoration.runtimeType} painter had mismatching save and  '
        'restore calls.',
      );
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
    assert(container.containsOffset(position.offset) || container.length == 0,
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
      required this.horizontalSpacing,
      required this.verticalSpacing,
      required this.scrollBottomInset,
      required this.decoration,
      required this.contentPadding,
      required super.children});

  final Block block;
  final TextDirection textDirection;
  final HorizontalSpacing horizontalSpacing;
  final VerticalSpacing verticalSpacing;
  final double scrollBottomInset;
  final Decoration decoration;
  final EdgeInsets? contentPadding;

  EdgeInsets get _padding => EdgeInsets.only(
      left: horizontalSpacing.left,
      right: horizontalSpacing.right,
      top: verticalSpacing.top,
      bottom: verticalSpacing.bottom);

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

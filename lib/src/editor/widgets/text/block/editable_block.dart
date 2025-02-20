import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../common/structs/horizontal_spacing.dart';
import '../../../../common/structs/vertical_spacing.dart';
import '../../../../document/nodes/block.dart';
import 'render_editable_block.dart';

@internal
class EditableBlock extends MultiChildRenderObjectWidget {
  const EditableBlock({
    required this.block,
    required this.textDirection,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    required this.scrollBottomInset,
    required this.decoration,
    required this.contentPadding,
    required super.children,
    super.key,
  });

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

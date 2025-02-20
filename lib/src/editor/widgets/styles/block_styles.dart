import 'package:flutter/material.dart';
import '../../../common/structs/horizontal_spacing.dart';
import '../../../common/structs/vertical_spacing.dart';
import '../../style_widgets/style_widgets.dart';
import '../text/utils/text_block_utils.dart';

/// Style theme applied to a block of rich text, including single-line
/// paragraphs.
@immutable
class DefaultTextBlockStyle {
  const DefaultTextBlockStyle(
    this.style,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.lineSpacing,
    this.decoration,
  );

  /// Base text style for a text block.
  final TextStyle style;

  /// Horizontal spacing around a text block.
  final HorizontalSpacing horizontalSpacing;

  /// Vertical spacing around a text block.
  final VerticalSpacing verticalSpacing;

  /// Vertical spacing for individual lines within a text block.
  ///
  final VerticalSpacing lineSpacing;

  /// Decoration of a text block.
  ///
  /// Decoration, if present, is painted in the content area, excluding
  /// any [spacing].
  final BoxDecoration? decoration;
}

@immutable
class DefaultListBlockStyle extends DefaultTextBlockStyle {
  const DefaultListBlockStyle(
    super.style,
    super.horizontalSpacing,
    super.verticalSpacing,
    super.lineSpacing,
    super.decoration,
    this.checkboxUIBuilder, {
    this.indentWidthBuilder = TextBlockUtils.defaultIndentWidthBuilder,
    this.numberPointWidthBuilder =
        TextBlockUtils.defaultNumberPointWidthBuilder,
  });

  final QuillCheckboxBuilder? checkboxUIBuilder;
  final LeadingBlockIndentWidth indentWidthBuilder;
  final LeadingBlockNumberPointWidth numberPointWidthBuilder;
}

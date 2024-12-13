import 'package:flutter/material.dart';

import '../../common/structs/horizontal_spacing.dart';
import '../../common/structs/vertical_spacing.dart';
import '../../common/utils/platform.dart';
import '../../document/attribute.dart';
import '../../document/style.dart';
import '../style_widgets/checkbox_point.dart';
import 'text/utils/text_block_utils.dart';

class QuillStyles extends InheritedWidget {
  const QuillStyles({
    required this.data,
    required super.child,
    super.key,
  });

  final DefaultStyles data;

  @override
  bool updateShouldNotify(QuillStyles oldWidget) {
    return data != oldWidget.data;
  }

  static DefaultStyles? getStyles(BuildContext context, bool nullOk) {
    final widget = context.dependOnInheritedWidgetOfExactType<QuillStyles>();
    if (widget == null && nullOk) {
      return null;
    }
    assert(widget != null);
    return widget!.data;
  }
}

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

/// Theme data for inline code.
class InlineCodeStyle {
  InlineCodeStyle({
    required this.style,
    this.header1,
    this.header2,
    this.header3,
    this.header4,
    this.header5,
    this.header6,
    this.backgroundColor,
    this.radius,
  });

  /// Base text style for an inline code.
  final TextStyle style;

  /// Style override for inline code in header level 1.
  final TextStyle? header1;

  /// Style override for inline code in headings level 2.
  final TextStyle? header2;

  /// Style override for inline code in headings level 3.
  final TextStyle? header3;

  /// Style override for inline code in headings level 4.
  final TextStyle? header4;

  /// Style override for inline code in headings level 5.
  final TextStyle? header5;

  /// Style override for inline code in headings level 6.
  final TextStyle? header6;

  /// Background color for inline code.
  final Color? backgroundColor;

  /// Radius used when paining the background.
  final Radius? radius;

  /// Returns effective style to use for inline code for the specified
  /// [lineStyle].
  TextStyle styleFor(Style lineStyle) {
    if (lineStyle.containsKey(Attribute.h1.key)) {
      return header1 ?? style;
    }
    if (lineStyle.containsKey(Attribute.h2.key)) {
      return header2 ?? style;
    }
    if (lineStyle.containsKey(Attribute.h3.key)) {
      return header3 ?? style;
    }
    if (lineStyle.containsKey(Attribute.h4.key)) {
      return header4 ?? style;
    }
    if (lineStyle.containsKey(Attribute.h5.key)) {
      return header5 ?? style;
    }
    if (lineStyle.containsKey(Attribute.h6.key)) {
      return header6 ?? style;
    }
    return style;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! InlineCodeStyle) {
      return false;
    }
    return other.style == style &&
        other.header1 == header1 &&
        other.header2 == header2 &&
        other.header3 == header3 &&
        other.header4 == header4 &&
        other.header5 == header5 &&
        other.header6 == header6 &&
        other.backgroundColor == backgroundColor &&
        other.radius == radius;
  }

  @override
  int get hashCode => Object.hash(style, header1, header2, header3, header4,
      header5, header6, backgroundColor, radius);
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

@immutable
class DefaultStyles {
  const DefaultStyles({
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.paragraph,
    this.lineHeightNormal,
    this.lineHeightTight,
    this.lineHeightOneAndHalf,
    this.lineHeightDouble,
    this.bold,
    this.subscript,
    this.superscript,
    this.italic,
    this.small,
    this.underline,
    this.strikeThrough,
    this.inlineCode,
    this.link,
    this.color,
    this.placeHolder,
    this.lists,
    this.quote,
    this.code,
    this.indent,
    this.align,
    this.leading,
    this.sizeSmall,
    this.sizeLarge,
    this.sizeHuge,
    this.palette,
  });

  final DefaultTextBlockStyle? h1;
  final DefaultTextBlockStyle? h2;
  final DefaultTextBlockStyle? h3;
  final DefaultTextBlockStyle? h4;
  final DefaultTextBlockStyle? h5;
  final DefaultTextBlockStyle? h6;
  final DefaultTextBlockStyle? paragraph;
  final DefaultTextBlockStyle? lineHeightNormal;
  final DefaultTextBlockStyle? lineHeightTight;
  final DefaultTextBlockStyle? lineHeightOneAndHalf;
  final DefaultTextBlockStyle? lineHeightDouble;
  final TextStyle? bold;
  final TextStyle? subscript;
  final TextStyle? superscript;
  final TextStyle? italic;
  final TextStyle? small;
  final TextStyle? underline;
  final TextStyle? strikeThrough;

  /// Theme of inline code.
  final InlineCodeStyle? inlineCode;
  final TextStyle? sizeSmall; // 'small'
  final TextStyle? sizeLarge; // 'large'
  final TextStyle? sizeHuge; // 'huge'
  final TextStyle? link;
  final Color? color;
  final DefaultTextBlockStyle? placeHolder;
  final DefaultListBlockStyle? lists;
  final DefaultTextBlockStyle? quote;
  final DefaultTextBlockStyle? code;
  final DefaultTextBlockStyle? indent;
  final DefaultTextBlockStyle? align;
  final DefaultTextBlockStyle? leading;

  /// Custom palette of colors
  final Map<String, Color>? palette;

  static DefaultStyles getInstance(BuildContext context) {
    final themeData = Theme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context);
    final baseStyle = defaultTextStyle.style.copyWith(
      fontSize: 16,
      height: 1.15,
      decoration: TextDecoration.none,
    );
    const baseHorizontalSpacing = HorizontalSpacing(0, 0);
    const baseVerticalSpacing = VerticalSpacing(6, 0);
    final fontFamily = themeData.isCupertino ? 'Menlo' : 'Roboto Mono';

    final inlineCodeStyle = TextStyle(
      fontSize: 14,
      color: themeData.colorScheme.primary.withValues(alpha: 0.8),
      fontFamily: fontFamily,
    );

    return DefaultStyles(
      h1: DefaultTextBlockStyle(
          defaultTextStyle.style.copyWith(
            fontSize: 34,
            color: defaultTextStyle.style.color,
            letterSpacing: -0.5,
            height: 1.083,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
          baseHorizontalSpacing,
          const VerticalSpacing(16, 0),
          VerticalSpacing.zero,
          null),
      h2: DefaultTextBlockStyle(
          defaultTextStyle.style.copyWith(
            fontSize: 30,
            color: defaultTextStyle.style.color,
            letterSpacing: -0.8,
            height: 1.067,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
          baseHorizontalSpacing,
          const VerticalSpacing(8, 0),
          VerticalSpacing.zero,
          null),
      h3: DefaultTextBlockStyle(
        defaultTextStyle.style.copyWith(
          fontSize: 24,
          color: defaultTextStyle.style.color,
          letterSpacing: -0.5,
          height: 1.083,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        baseHorizontalSpacing,
        const VerticalSpacing(8, 0),
        VerticalSpacing.zero,
        null,
      ),
      h4: DefaultTextBlockStyle(
        defaultTextStyle.style.copyWith(
          fontSize: 20,
          color: defaultTextStyle.style.color,
          letterSpacing: -0.4,
          height: 1.1,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        baseHorizontalSpacing,
        const VerticalSpacing(6, 0),
        VerticalSpacing.zero,
        null,
      ),
      h5: DefaultTextBlockStyle(
        defaultTextStyle.style.copyWith(
          fontSize: 18,
          color: defaultTextStyle.style.color,
          letterSpacing: -0.2,
          height: 1.11,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        baseHorizontalSpacing,
        const VerticalSpacing(6, 0),
        VerticalSpacing.zero,
        null,
      ),
      h6: DefaultTextBlockStyle(
        defaultTextStyle.style.copyWith(
          fontSize: 16,
          color: defaultTextStyle.style.color,
          letterSpacing: -0.1,
          height: 1.125,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
        baseHorizontalSpacing,
        const VerticalSpacing(4, 0),
        VerticalSpacing.zero,
        null,
      ),
      lineHeightNormal: DefaultTextBlockStyle(
        baseStyle.copyWith(height: 1.15),
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      lineHeightTight: DefaultTextBlockStyle(
        baseStyle.copyWith(height: 1.30),
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      lineHeightOneAndHalf: DefaultTextBlockStyle(
        baseStyle.copyWith(height: 1.55),
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      lineHeightDouble: DefaultTextBlockStyle(
        baseStyle.copyWith(height: 2),
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      paragraph: DefaultTextBlockStyle(
        baseStyle,
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      bold: const TextStyle(fontWeight: FontWeight.bold),
      subscript: const TextStyle(
        fontFeatures: [
          FontFeature.liningFigures(),
          FontFeature.subscripts(),
        ],
      ),
      superscript: const TextStyle(
        fontFeatures: [
          FontFeature.liningFigures(),
          FontFeature.superscripts(),
        ],
      ),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      small: const TextStyle(fontSize: 12),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
      inlineCode: InlineCodeStyle(
        backgroundColor: Colors.grey.shade100,
        radius: const Radius.circular(3),
        style: inlineCodeStyle,
        header1: inlineCodeStyle.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
        header2: inlineCodeStyle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        header3: inlineCodeStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      link: TextStyle(
        color: themeData.colorScheme.secondary,
        decoration: TextDecoration.underline,
      ),
      placeHolder: DefaultTextBlockStyle(
          defaultTextStyle.style.copyWith(
            fontSize: 20,
            height: 1.5,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          baseHorizontalSpacing,
          VerticalSpacing.zero,
          VerticalSpacing.zero,
          null),
      lists: DefaultListBlockStyle(
        baseStyle,
        baseHorizontalSpacing,
        baseVerticalSpacing,
        const VerticalSpacing(0, 6),
        null,
        null,
      ),
      quote: DefaultTextBlockStyle(
        TextStyle(color: baseStyle.color!.withValues(alpha: 0.6)),
        baseHorizontalSpacing,
        baseVerticalSpacing,
        const VerticalSpacing(6, 2),
        BoxDecoration(
          border: Border(
            left: BorderSide(width: 4, color: Colors.grey.shade300),
          ),
        ),
      ),
      code: DefaultTextBlockStyle(
          TextStyle(
            color: Colors.blue.shade900.withValues(alpha: 0.9),
            fontFamily: fontFamily,
            fontSize: 13,
            height: 1.15,
          ),
          baseHorizontalSpacing,
          baseVerticalSpacing,
          VerticalSpacing.zero,
          BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(2),
          )),
      indent: DefaultTextBlockStyle(
        baseStyle,
        baseHorizontalSpacing,
        baseVerticalSpacing,
        const VerticalSpacing(0, 6),
        null,
      ),
      align: DefaultTextBlockStyle(
        baseStyle,
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      leading: DefaultTextBlockStyle(
        baseStyle,
        baseHorizontalSpacing,
        VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      ),
      sizeSmall: const TextStyle(fontSize: 10),
      sizeLarge: const TextStyle(fontSize: 18),
      sizeHuge: const TextStyle(fontSize: 22),
    );
  }

  DefaultStyles merge(DefaultStyles other) {
    return DefaultStyles(
      h1: other.h1 ?? h1,
      h2: other.h2 ?? h2,
      h3: other.h3 ?? h3,
      h4: other.h4 ?? h4,
      h5: other.h5 ?? h5,
      h6: other.h6 ?? h6,
      paragraph: other.paragraph ?? paragraph,
      bold: other.bold ?? bold,
      subscript: other.subscript ?? subscript,
      superscript: other.superscript ?? superscript,
      italic: other.italic ?? italic,
      small: other.small ?? small,
      underline: other.underline ?? underline,
      strikeThrough: other.strikeThrough ?? strikeThrough,
      inlineCode: other.inlineCode ?? inlineCode,
      link: other.link ?? link,
      color: other.color ?? color,
      placeHolder: other.placeHolder ?? placeHolder,
      lineHeightNormal: other.lineHeightNormal ?? lineHeightNormal,
      lineHeightTight: other.lineHeightTight ?? lineHeightTight,
      lineHeightOneAndHalf: other.lineHeightOneAndHalf ?? lineHeightOneAndHalf,
      lineHeightDouble: other.lineHeightDouble ?? lineHeightDouble,
      lists: other.lists ?? lists,
      quote: other.quote ?? quote,
      code: other.code ?? code,
      indent: other.indent ?? indent,
      align: other.align ?? align,
      leading: other.leading ?? leading,
      sizeSmall: other.sizeSmall ?? sizeSmall,
      sizeLarge: other.sizeLarge ?? sizeLarge,
      sizeHuge: other.sizeHuge ?? sizeHuge,
      palette: other.palette ?? palette,
    );
  }
}

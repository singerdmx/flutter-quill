import 'package:flutter/material.dart';
import '../../../document/attribute.dart';
import '../../../document/style.dart';

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

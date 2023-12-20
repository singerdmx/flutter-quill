import 'package:flutter/material.dart';

@immutable
class QuillIconTheme {
  const QuillIconTheme({
    this.padding,
    this.iconButtonSelectedStyle,
    this.iconButtonUnselectedStyle,
    // this.iconSelectedFillColor,
    // this.iconUnselectedFillColor,
  });

  final ButtonStyle? iconButtonUnselectedStyle;
  final ButtonStyle? iconButtonSelectedStyle;

  // final Color? iconSelectedFillColor;
  // final Color? iconUnselectedFillColor;

  ///The padding for icons
  final EdgeInsets? padding;
}

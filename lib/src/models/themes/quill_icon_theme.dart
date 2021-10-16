import 'package:flutter/material.dart';

class QuillIconTheme {
  const QuillIconTheme({
    this.iconSelectedColor,
    this.iconUnselectedColor,
    this.iconSelectedFillColor,
    this.iconUnselectedFillColor,
    this.disabledIconColor,
    this.disabledIconFillColor,
  });

  ///The color to use for selected icons in the toolbar
  final Color? iconSelectedColor;

  ///The color to use for unselected icons in the toolbar
  final Color? iconUnselectedColor;

  ///The fill color to use for the selected icons in the toolbar
  final Color? iconSelectedFillColor;

  ///The fill color to use for the unselected icons in the toolbar
  final Color? iconUnselectedFillColor;

  ///The color to use for disabled icons in the toolbar
  final Color? disabledIconColor;

  ///The fill color to use for disabled icons in the toolbar
  final Color? disabledIconFillColor;
}

import 'package:flutter/material.dart';

@immutable
class QuillIconTheme {
  const QuillIconTheme({
    this.iconButtonSelectedStyle,
    this.iconButtonUnselectedStyle,
    this.iconButtonSelectedData,
    this.iconButtonUnselectedData,
  });

  @Deprecated('Please use iconButtonUnselectedData instead')
  final ButtonStyle? iconButtonUnselectedStyle;
  @Deprecated('Please use iconButtonSelectedData instead')
  final ButtonStyle? iconButtonSelectedStyle;

  final IconButtonData? iconButtonUnselectedData;
  final IconButtonData? iconButtonSelectedData;
}

@immutable
class IconButtonData {
  const IconButtonData({
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
    this.selectedIcon,
  });

  final double? iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final double? splashRadius;
  final Color? color;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? disabledColor;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final String? tooltip;
  final bool? enableFeedback;
  final BoxConstraints? constraints;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;
}

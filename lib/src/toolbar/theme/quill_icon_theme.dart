import 'package:flutter/material.dart';

@immutable
class QuillIconTheme {
  const QuillIconTheme({
    this.iconButtonSelectedData,
    this.iconButtonUnselectedData,
  });

  final IconButtonData? iconButtonUnselectedData;
  final IconButtonData? iconButtonSelectedData;

  QuillIconTheme copyWith({
    IconButtonData? iconButtonUnselectedData,
    IconButtonData? iconButtonSelectedData,
  }) {
    return QuillIconTheme(
      iconButtonUnselectedData:
          iconButtonUnselectedData ?? this.iconButtonUnselectedData,
      iconButtonSelectedData:
          iconButtonSelectedData ?? this.iconButtonSelectedData,
    );
  }
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

  IconButtonData copyWith({
    double? iconSize,
    VisualDensity? visualDensity,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
    double? splashRadius,
    Color? color,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Color? disabledColor,
    MouseCursor? mouseCursor,
    bool? autofocus,
    String? tooltip,
    bool? enableFeedback,
    BoxConstraints? constraints,
    ButtonStyle? style,
    bool? isSelected,
    Widget? selectedIcon,
  }) {
    return IconButtonData(
      iconSize: iconSize ?? this.iconSize,
      visualDensity: visualDensity ?? this.visualDensity,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      splashRadius: splashRadius ?? this.splashRadius,
      color: color ?? this.color,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashColor: splashColor ?? this.splashColor,
      disabledColor: disabledColor ?? this.disabledColor,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      autofocus: autofocus ?? this.autofocus,
      tooltip: tooltip ?? this.tooltip,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      constraints: constraints ?? this.constraints,
      style: style ?? this.style,
      isSelected: isSelected ?? this.isSelected,
      selectedIcon: selectedIcon ?? this.selectedIcon,
    );
  }
}

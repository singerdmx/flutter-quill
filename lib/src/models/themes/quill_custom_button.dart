import 'package:flutter/material.dart';

class QuillCustomButton {
  const QuillCustomButton({
    this.icon,
    this.iconColor,
    this.onTap,
    this.tooltip,
    this.child,
  });

  ///The icon widget
  final IconData? icon;

  ///The icon color;
  final Color? iconColor;

  ///The function when the icon is tapped
  final VoidCallback? onTap;

  ///The customButton placeholder
  final Widget? child;

  /// The button tooltip.
  final String? tooltip;
}

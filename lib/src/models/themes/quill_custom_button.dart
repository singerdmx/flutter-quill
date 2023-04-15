import 'package:flutter/material.dart';

class QuillCustomButton {
  const QuillCustomButton({
    this.icon,
    this.onTap,
    this.tooltip,
  });

  ///The icon widget
  final IconData? icon;

  ///The function when the icon is tapped
  final VoidCallback? onTap;

  /// The button tooltip.
  final String? tooltip;
}

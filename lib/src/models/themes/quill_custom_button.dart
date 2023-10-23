import 'package:flutter/material.dart';

import '../../widgets/toolbar/base_toolbar.dart';

class QuillCustomButton extends QuillToolbarBaseButtonOptions {
  const QuillCustomButton({
    super.iconData,
    this.iconColor,
    this.onTap,
    super.tooltip,
    this.iconSize,
    this.child,
    super.iconTheme,
  });

  ///The icon color;
  final Color? iconColor;

  ///The function when the icon is tapped
  final VoidCallback? onTap;

  ///The customButton placeholder
  final Widget? child;

  final double? iconSize;
}

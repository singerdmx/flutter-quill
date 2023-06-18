import 'package:flutter/material.dart';

import '../../models/themes/quill_icon_theme.dart';
import '../toolbar.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      icon: Icon(icon, size: iconSize, color: iconColor),
      tooltip: tooltip,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: onPressed,
      afterPressed: afterButtonPressed,
      fillColor: iconTheme?.iconUnselectedFillColor ?? theme.canvasColor,
    );
  }
}

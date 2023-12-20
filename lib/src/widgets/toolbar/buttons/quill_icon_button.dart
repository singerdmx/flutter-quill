import 'package:flutter/material.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    required this.icon,
    required this.isSelected,
    this.afterPressed,
    this.tooltip,
    this.padding,
    super.key,
    this.iconSelectedStyle,
    this.iconUnselectedStyle,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget icon;

  final String? tooltip;
  final EdgeInsets? padding;
  final bool isSelected;

  final ButtonStyle? iconUnselectedStyle;
  final ButtonStyle? iconSelectedStyle;
  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return IconButton.filled(
        tooltip: tooltip,
        padding: padding,
        onPressed: onPressed,
        icon: icon,
        style: iconSelectedStyle,
      );
    }
    return IconButton(
      tooltip: tooltip,
      padding: padding,
      onPressed: onPressed != null
          ? () {
              onPressed?.call();
              afterPressed?.call();
            }
          : null,
      icon: icon,
      style: iconUnselectedStyle,
    );
  }
}

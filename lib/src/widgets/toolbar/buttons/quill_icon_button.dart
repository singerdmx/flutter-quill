import 'package:flutter/material.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    required this.icon,
    required this.isFilled,
    this.afterPressed,
    this.tooltip,
    this.padding,
    super.key,
    this.iconFilledStyle,
    this.iconStyle,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget icon;

  final String? tooltip;
  final EdgeInsets? padding;
  final bool isFilled;

  final ButtonStyle? iconStyle;
  final ButtonStyle? iconFilledStyle;
  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return IconButton.filled(
        padding: padding,
        onPressed: onPressed,
        icon: icon,
        style: iconStyle,
      );
    }
    return IconButton(
      padding: padding,
      onPressed: () {
        onPressed?.call();
        afterPressed?.call();
      },
      icon: icon,
      style: iconFilledStyle,
    );
  }
}

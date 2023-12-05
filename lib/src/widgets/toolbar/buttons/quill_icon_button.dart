import 'package:flutter/material.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    required this.icon,
    required this.isFilled,
    this.afterPressed,
    this.size = 40,
    this.tooltip,
    super.key,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget icon;

  final double size;
  final String? tooltip;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return IconButton.filled(onPressed: onPressed, icon: icon);
    }
    return IconButton(
      onPressed: onPressed,
      icon: icon,
    );
  }
}

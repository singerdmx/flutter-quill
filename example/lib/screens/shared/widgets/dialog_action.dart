import 'package:flutter/material.dart';

class AppDialogAction extends StatelessWidget {
  const AppDialogAction({
    required this.child,
    required this.onPressed,
    this.textStyle,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  final ButtonStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: textStyle,
      child: child,
    );
  }
}

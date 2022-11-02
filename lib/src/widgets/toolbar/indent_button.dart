import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class IndentButton extends StatefulWidget {
  const IndentButton({
    required this.icon,
    required this.controller,
    required this.isIncrease,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final QuillController controller;
  final bool isIncrease;
  final VoidCallback? afterButtonPressed;

  final QuillIconTheme? iconTheme;

  @override
  _IndentButtonState createState() => _IndentButtonState();
}

class _IndentButtonState extends State<IndentButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
      fillColor: iconFillColor,
      borderRadius: widget.iconTheme?.borderRadius ?? 2,
      onPressed: () {
        widget.controller.indentSelection(widget.isIncrease);
      },
      afterPressed: widget.afterButtonPressed,
    );
  }
}

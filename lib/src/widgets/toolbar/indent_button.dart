import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';
import 'quill_icon_button.dart';

class IndentButton extends StatefulWidget {
  const IndentButton({
    required this.icon,
    required this.controller,
    required this.isIncrease,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final QuillController controller;
  final bool isIncrease;

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
      onPressed: () {
        final indent = widget.controller
            .getSelectionStyle()
            .attributes[Attribute.indent.key];
        if (indent == null) {
          if (widget.isIncrease) {
            widget.controller.formatSelection(Attribute.indentL1);
          }
          return;
        }
        if (indent.value == 1 && !widget.isIncrease) {
          widget.controller
              .formatSelection(Attribute.clone(Attribute.indentL1, null));
          return;
        }
        if (widget.isIncrease) {
          widget.controller
              .formatSelection(Attribute.getIndentLevel(indent.value + 1));
          return;
        }
        widget.controller
            .formatSelection(Attribute.getIndentLevel(indent.value - 1));
      },
    );
  }
}

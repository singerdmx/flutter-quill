import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class ClearFormatButton extends StatefulWidget {
  const ClearFormatButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;

  final QuillIconTheme? iconTheme;
  final VoidCallback? afterButtonPressed;

  @override
  _ClearFormatButtonState createState() => _ClearFormatButtonState();
}

class _ClearFormatButtonState extends State<ClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final fillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * kIconButtonFactor,
      icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
      fillColor: fillColor,
      borderRadius: widget.iconTheme?.borderRadius ?? 2,
      onPressed: () {
        final attrs = <Attribute>{};
        for (final style in widget.controller.getAllSelectionStyles()) {
          for (final attr in style.attributes.values) {
            attrs.add(attr);
          }
        }
        for (final attr in attrs) {
          widget.controller.formatSelection(Attribute.clone(attr, null));
        }
      },
      afterPressed: widget.afterButtonPressed,
    );
  }
}

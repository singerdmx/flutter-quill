import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';
import 'quill_icon_button.dart';

class ClearFormatButton extends StatefulWidget {
  const ClearFormatButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;

  @override
  _ClearFormatButtonState createState() => _ClearFormatButtonState();
}

class _ClearFormatButtonState extends State<ClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color;
    final fillColor = theme.canvasColor;
    return QuillIconButton(
        highlightElevation: 0,
        hoverElevation: 0,
        size: widget.iconSize * kIconButtonFactor,
        icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        fillColor: fillColor,
        onPressed: () {
          for (final k
              in widget.controller.getSelectionStyle().attributes.values) {
            widget.controller.formatSelection(Attribute.clone(k, null));
          }
        });
  }
}

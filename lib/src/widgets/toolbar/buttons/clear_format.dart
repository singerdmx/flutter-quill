import 'package:flutter/material.dart';

import '../../../models/documents/attribute.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../toolbar.dart';

class QuillToolbarClearFormatButton extends StatefulWidget {
  const QuillToolbarClearFormatButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;

  final QuillIconTheme? iconTheme;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;

  @override
  _QuillToolbarClearFormatButtonState createState() =>
      _QuillToolbarClearFormatButtonState();
}

class _QuillToolbarClearFormatButtonState
    extends State<QuillToolbarClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final fillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillToolbarIconButton(
      tooltip: widget.tooltip,
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

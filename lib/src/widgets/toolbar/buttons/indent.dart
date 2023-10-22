import 'package:flutter/material.dart';

import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../toolbar.dart';

class QuillToolbarIndentButton extends StatefulWidget {
  const QuillToolbarIndentButton({
    required this.icon,
    required this.controller,
    required this.isIncrease,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final QuillController controller;
  final bool isIncrease;
  final VoidCallback? afterButtonPressed;

  final QuillIconTheme? iconTheme;
  final String? tooltip;

  @override
  _QuillToolbarIndentButtonState createState() =>
      _QuillToolbarIndentButtonState();
}

class _QuillToolbarIndentButtonState extends State<QuillToolbarIndentButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor =
        widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor;
    return QuillToolbarIconButton(
      tooltip: widget.tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * kIconButtonFactor,
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

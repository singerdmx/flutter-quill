import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FormulaButton extends StatelessWidget {
  const FormulaButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.iconTheme,
    this.dialogTheme,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;

  final double iconSize;

  final Color? fillColor;

  final QuillController controller;

  final QuillIconTheme? iconTheme;

  final QuillDialogTheme? dialogTheme;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    controller.replaceText(index, length, BlockEmbed.formula(''), null);
  }
}

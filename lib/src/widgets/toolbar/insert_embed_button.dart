import 'package:flutter/material.dart';

import '../../models/documents/nodes/embed.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../toolbar.dart';
import 'quill_icon_button.dart';

class InsertEmbedButton extends StatelessWidget {
  const InsertEmbedButton({
    required this.controller,
    required this.icon,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final IconData icon;
  final double iconSize;
  final Color? fillColor;
  final QuillIconTheme? iconTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      fillColor: iconFillColor,
      onPressed: () {
        final index = controller.selection.baseOffset;
        final length = controller.selection.extentOffset - index;
        controller.replaceText(index, length, BlockEmbed.horizontalRule, null);
      },
    );
  }
}

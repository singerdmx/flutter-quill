import 'package:flutter/material.dart';

import '../../../models/themes/quill_dialog_theme.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../search_dialog.dart';
import '../toolbar.dart';

class QuillToolbarSearchButton extends StatelessWidget {
  const QuillToolbarSearchButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.iconTheme,
    this.dialogBarrierColor = Colors.black54,
    this.dialogTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;
  final Color? fillColor;
  final Color dialogBarrierColor;
  final QuillIconTheme? iconTheme;

  final QuillDialogTheme? dialogTheme;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor =
        iconTheme?.iconUnselectedFillColor ?? (fillColor ?? theme.canvasColor);

    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize, color: iconColor),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * kIconButtonFactor,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _onPressedHandler(context),
      afterPressed: afterButtonPressed,
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final value = await showDialog<String>(
      barrierColor: dialogBarrierColor,
      context: context,
      builder: (_) => SearchDialog(
        controller: controller,
        dialogTheme: dialogTheme,
        text: '',
      ),
    );
    _searchSubmitted(value);
  }

  void _searchSubmitted(String? value) {
    // If we are doing nothing here then why we care about the result??
  }
}

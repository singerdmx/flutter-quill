import 'package:flutter/material.dart';

import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../toolbar.dart';
import 'search_dialog.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.fillColor,
    this.iconTheme,
    this.dialogTheme,
    this.afterButtonPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;
  final Color? fillColor;
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

    return QuillIconButton(
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
    await showDialog<String>(
      context: context,
      builder: (_) => SearchDialog(
          controller: controller, dialogTheme: dialogTheme, text: ''),
    ).then(_searchSubmitted);
  }

  void _searchSubmitted(String? value) {}
}

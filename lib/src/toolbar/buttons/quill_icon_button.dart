import 'package:flutter/material.dart';

import '../theme/quill_icon_theme.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    required this.icon,
    required this.isSelected,
    required this.iconTheme,
    this.afterPressed,
    this.tooltip,
    super.key,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget icon;

  final String? tooltip;
  final bool isSelected;

  final QuillIconTheme? iconTheme;
  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed != null
            ? () {
                onPressed?.call();
                afterPressed?.call();
              }
            : null,
        icon: icon,
        style: iconTheme?.iconButtonSelectedData?.style,
        visualDensity: iconTheme?.iconButtonSelectedData?.visualDensity,
        iconSize: iconTheme?.iconButtonSelectedData?.iconSize,
        padding: iconTheme?.iconButtonSelectedData?.padding,
        alignment: iconTheme?.iconButtonSelectedData?.alignment,
        splashRadius: iconTheme?.iconButtonSelectedData?.splashRadius,
        color: iconTheme?.iconButtonSelectedData?.color,
        focusColor: iconTheme?.iconButtonSelectedData?.focusColor,
        hoverColor: iconTheme?.iconButtonSelectedData?.hoverColor,
        highlightColor: iconTheme?.iconButtonSelectedData?.highlightColor,
        splashColor: iconTheme?.iconButtonSelectedData?.splashColor,
        disabledColor: iconTheme?.iconButtonSelectedData?.disabledColor,
        mouseCursor: iconTheme?.iconButtonSelectedData?.mouseCursor,
        autofocus: iconTheme?.iconButtonSelectedData?.autofocus ?? false,
        enableFeedback: iconTheme?.iconButtonSelectedData?.enableFeedback,
        constraints: iconTheme?.iconButtonSelectedData?.constraints,
        selectedIcon: iconTheme?.iconButtonSelectedData?.selectedIcon,
      );
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed != null
          ? () {
              onPressed?.call();
              afterPressed?.call();
            }
          : null,
      icon: icon,
      style: iconTheme?.iconButtonUnselectedData?.style,
      visualDensity: iconTheme?.iconButtonUnselectedData?.visualDensity,
      iconSize: iconTheme?.iconButtonUnselectedData?.iconSize,
      padding: iconTheme?.iconButtonUnselectedData?.padding,
      alignment: iconTheme?.iconButtonUnselectedData?.alignment,
      splashRadius: iconTheme?.iconButtonUnselectedData?.splashRadius,
      color: iconTheme?.iconButtonUnselectedData?.color,
      focusColor: iconTheme?.iconButtonUnselectedData?.focusColor,
      hoverColor: iconTheme?.iconButtonUnselectedData?.hoverColor,
      highlightColor: iconTheme?.iconButtonUnselectedData?.highlightColor,
      splashColor: iconTheme?.iconButtonUnselectedData?.splashColor,
      disabledColor: iconTheme?.iconButtonUnselectedData?.disabledColor,
      mouseCursor: iconTheme?.iconButtonUnselectedData?.mouseCursor,
      autofocus: iconTheme?.iconButtonUnselectedData?.autofocus ?? false,
      enableFeedback: iconTheme?.iconButtonUnselectedData?.enableFeedback,
      constraints: iconTheme?.iconButtonUnselectedData?.constraints,
      selectedIcon: iconTheme?.iconButtonUnselectedData?.selectedIcon,
    );
  }
}

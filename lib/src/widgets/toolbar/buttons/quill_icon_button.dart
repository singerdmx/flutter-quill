import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../../flutter_quill.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    required this.icon,
    required this.isFilled,
    this.afterPressed,
    this.tooltip,
    this.padding,
    super.key,
    this.iconFilledStyle,
    this.iconStyle,
    this.size = 40,
    this.iconTheme,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget icon;

  final String? tooltip;
  final EdgeInsets? padding;
  final bool isFilled;
  final ButtonStyle? iconStyle;
  final ButtonStyle? iconFilledStyle;
  final QuillIconTheme? iconTheme;

  /// Container size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget child;
    if (theme.useMaterial3) {
      child = isFilled
          ? IconButton.filled(
              padding: padding,
              icon: icon,
              style: iconFilledStyle,
              onPressed: _onPressed,
            )
          : IconButton(
              padding: padding,
              icon: icon,
              style: iconStyle,
              onPressed: _onPressed,
            );
    } else {
      child = UtilityWidgets.maybeTooltip(
        message: tooltip,
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(iconTheme?.borderRadius ?? 2),
          ),
          fillColor: iconFilledStyle?.backgroundColor?.resolve({}),
          elevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: _onPressed,
          child: icon,
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: child,
    );
  }

  void _onPressed() {
    onPressed?.call();
    afterPressed?.call();
  }
}

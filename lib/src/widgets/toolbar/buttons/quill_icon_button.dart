import 'package:flutter/material.dart';

import '../../../utils/widgets.dart';

class QuillToolbarIconButton extends StatelessWidget {
  const QuillToolbarIconButton({
    required this.onPressed,
    this.afterPressed,
    this.icon,
    this.size = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.borderRadius = 2,
    this.tooltip,
    super.key,
    this.iconFilledStyle,
    this.iconStyle,
  });

  final VoidCallback? onPressed;
  final VoidCallback? afterPressed;
  final Widget? icon;

  final double size;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final double borderRadius;
  final String? tooltip;

  final ButtonStyle? iconStyle;
  final ButtonStyle? iconFilledStyle;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: UtilityWidgets.maybeTooltip(
        message: tooltip,
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          fillColor: fillColor,
          elevation: 0,
          hoverElevation: hoverElevation,
          highlightElevation: hoverElevation,
          onPressed: () {
            onPressed?.call();
            afterPressed?.call();
          },
          child: icon,
        ),
      ),
    );
  }
}

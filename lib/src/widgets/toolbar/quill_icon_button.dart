import 'package:flutter/material.dart';
import '../../models/themes/quill_icon_theme.dart';

class QuillIconButton extends StatelessWidget {
  const QuillIconButton({
    required this.onPressed,
    this.icon,
    this.size = 40,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.iconTheme,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget? icon;
  final double size;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final QuillIconTheme? iconTheme;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: RawMaterialButton(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(iconTheme?.borderRadius ?? 2)),
        fillColor: fillColor,
        elevation: 0,
        hoverElevation: hoverElevation,
        highlightElevation: hoverElevation,
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}

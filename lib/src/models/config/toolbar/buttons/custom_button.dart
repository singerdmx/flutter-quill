import 'package:flutter/widgets.dart' show VoidCallback, Widget;

import 'base.dart';

class QuillToolbarCustomButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarCustomButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarCustomButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarBaseButtonOptions, QuillToolbarCustomButtonExtraOptions> {
  const QuillToolbarCustomButtonOptions({
    this.icon,
    this.iconButtonFactor,
    this.iconSize,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
    this.onPressed,
  });

  final double? iconButtonFactor;
  final double? iconSize;
  final VoidCallback? onPressed;
  final Widget? icon;
}

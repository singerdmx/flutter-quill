import 'package:flutter/widgets.dart' show Color;
import './../../shared_configurations.dart' show QuillSharedConfigurations;

import 'base.dart';

class QuillToolbarColorButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarColorButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    required this.iconColor,
    required this.iconColorBackground,
    required this.fillColor,
    required this.fillColorBackground,
  });

  final Color? iconColor;
  final Color? iconColorBackground;
  final Color fillColor;
  final Color fillColorBackground;
}

class QuillToolbarColorButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarColorButtonOptions, QuillToolbarColorButtonExtraOptions> {
  const QuillToolbarColorButtonOptions({
    this.dialogBarrierColor,
    this.iconSize,
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.controller,
    super.globalIconSize,
    super.iconTheme,
    super.tooltip,
  });

  final double? iconSize;

  /// By default will use the default `dialogBarrierColor` from
  /// [QuillSharedConfigurations]
  final Color? dialogBarrierColor;
}

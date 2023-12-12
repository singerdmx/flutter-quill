import 'package:flutter/widgets.dart' show TextStyle;

import '../../../../widgets/toolbar/base_toolbar.dart';

class QuillToolbarSelectHeaderStyleButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectHeaderStyleButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarSelectHeaderStyleButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectHeaderStyleButtonOptions,
        QuillToolbarSelectHeaderStyleButtonExtraOptions> {
  const QuillToolbarSelectHeaderStyleButtonOptions({
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    this.iconSize,
    this.iconButtonFactor,
    this.textStyle,
  });

  /// By default we will the toolbar axis from [QuillSimpleToolbarConfigurations]
  final double? iconSize;
  final double? iconButtonFactor;
  final TextStyle? textStyle;
}

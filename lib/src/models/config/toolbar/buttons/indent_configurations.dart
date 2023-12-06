import 'package:flutter/foundation.dart';

import 'base_configurations.dart';

class QuillToolbarIndentButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarIndentButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

@immutable
class QuillToolbarIndentButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarIndentButtonOptions, QuillToolbarIndentButtonExtraOptions> {
  const QuillToolbarIndentButtonOptions({
    super.iconData,
    super.afterButtonPressed,
    super.childBuilder,
    super.controller,
    super.iconTheme,
    super.tooltip,
    this.iconSize,
    this.iconButtonFactor,
  });

  final double? iconSize;
  final double? iconButtonFactor;
}

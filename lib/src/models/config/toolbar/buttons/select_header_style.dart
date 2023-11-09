import 'package:flutter/widgets.dart' show Axis;

import '../../../../widgets/toolbar/base_toolbar.dart';
import '../../../documents/attribute.dart';

class QuillToolbarSelectHeaderStyleButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectHeaderStyleButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarSelectHeaderStyleButtonsOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectHeaderStyleButtonsOptions,
        QuillToolbarSelectHeaderStyleButtonExtraOptions> {
  const QuillToolbarSelectHeaderStyleButtonsOptions({
    super.afterButtonPressed,
    super.childBuilder,
    super.controller,
    super.iconTheme,
    super.tooltip,
    this.axis,
    this.attributes,
    this.iconSize,
    this.iconButtonFactor,
  });

  /// Default value:
  /// const [
  ///   Attribute.header,
  ///   Attribute.h1,
  ///   Attribute.h2,
  ///   Attribute.h3,
  /// ]
  final List<Attribute>? attributes;

  /// By default we will the toolbar axis from [QuillToolbarConfigurations]
  final Axis? axis;
  final double? iconSize;
  final double? iconButtonFactor;
}

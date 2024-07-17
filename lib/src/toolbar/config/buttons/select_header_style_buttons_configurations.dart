import 'package:flutter/widgets.dart' show Axis;

import '../../../document/attribute.dart';
import '../../base_toolbar.dart';

class QuillToolbarSelectHeaderStyleButtonsExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectHeaderStyleButtonsExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarSelectHeaderStyleButtonsOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectHeaderStyleButtonsOptions,
        QuillToolbarSelectHeaderStyleButtonsExtraOptions> {
  const QuillToolbarSelectHeaderStyleButtonsOptions({
    super.afterButtonPressed,
    super.childBuilder,
    super.iconTheme,
    super.tooltip,
    this.axis,
    this.attributes,
    super.iconSize,
    super.iconButtonFactor,
  });

  /// Default value:
  ///
  /// ```dart
  /// const [
  ///   Attribute.header,
  ///   Attribute.h1,
  ///   Attribute.h2,
  ///   Attribute.h3,
  /// ]
  /// ```
  final List<Attribute>? attributes;

  /// By default we will the toolbar axis from [QuillSimpleToolbarConfigurations]
  final Axis? axis;
}
